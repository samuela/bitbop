// Run with the `bb-build-ami` script in flake.nix.

packer {
  required_plugins {
    amazon = {
      version = ">= 1.2.8"
      source  = "github.com/hashicorp/amazon"
    }
  }
}

source "amazon-ebs" "ubuntu" {
  ami_name      = "bitbop-user-ami-ubuntu-24.04-{{timestamp}}"
  instance_type = "m7i-flex.xlarge"
  region        = "us-west-2"
  source_ami_filter {
    filters = {
      // Don't forget to update the NVIDIA driver installation code when
      // changing the Ubuntu version!
      name                = "ubuntu/images/*ubuntu-noble-24.04-amd64-server-*"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    most_recent = true
    // This is the owner id for Canonical
    owners = ["099720109477"]
  }
  launch_block_device_mappings {
    device_name           = "/dev/sda1"
    volume_size           = 32
    volume_type           = "gp3"
    delete_on_termination = true
  }
  ssh_username = "ubuntu"
}

build {
  sources = ["source.amazon-ebs.ubuntu"]

  provisioner "shell" {
    // Note: we're running as 'ubuntu' hence the use of sudo.
    inline = [
      "sudo apt-get update",
      "sudo apt-get upgrade -y",

      //// Configure motd
      // Remove the default motd scripts that we don't want. We'll add our
      // custom motd scripts in the user-data script.
      "sudo rm /etc/update-motd.d/00-*",
      "sudo rm /etc/update-motd.d/10-*",
      "sudo rm /etc/update-motd.d/50-*",
      "sudo rm /etc/update-motd.d/90-*",

      //// Increase /run/user/1000 tmpfs size
      // Some programs, eg nixglhost, require a larger /run/user/1000 tmpfs than
      // the default 10% of RAM which can be small on some instances.
      //
      // See https://askubuntu.com/questions/855740/how-do-i-increase-size-of-per-user-tmpfs-partition-run-user-id.
      "sudo mkdir -p /etc/systemd/logind.conf.d",
      "echo \"[Login]\nRuntimeDirectorySize=4G\" | sudo tee /etc/systemd/logind.conf.d/bitbop.conf",

      //// Install NVIDIA driver
      "sudo apt-get install -y linux-headers-$(uname -r)",
      // Make sure to update "ubuntu2404" to the correct version of Ubuntu when
      // updating the base image!
      "wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2404/x86_64/cuda-keyring_1.1-1_all.deb",
      "sudo dpkg -i cuda-keyring_1.1-1_all.deb",
      "sudo apt-get update",
      "sudo apt-get -y install cuda-drivers",
      "rm cuda-keyring_1.1-1_all.deb",

      //// Install docker
      "sudo apt-get update",
      "sudo apt-get -y install apt-transport-https ca-certificates curl software-properties-common",
      "curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -",
      "sudo add-apt-repository --yes 'deb [arch=amd64] https://download.docker.com/linux/ubuntu focal stable'",
      "sudo apt-get -y install docker-ce",
      "sudo usermod -aG docker ubuntu",

      //// Install Nix
      "curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install --no-confirm",

      // ~/.config/nixpkgs/config.nix
      "mkdir -p ~/.config/nixpkgs",
      "echo \"{ allowUnfree = true; cudaSupport = true; }\" > ~/.config/nixpkgs/config.nix",

      // /etc/nix/nix.conf
      // We're intentionally using `substituters` instead of
      // `trusted-substituters` since the latter only dictates that users *can*
      // use a substituter, and not that they will by default. See https://github.com/NixOS/nix/issues/6672#issuecomment-1921759878.
      "echo \"substituters = https://cache.nixos.org https://cuda-maintainers.cachix.org\" | sudo tee -a /etc/nix/nix.conf",
      "echo \"trusted-public-keys = cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY= cuda-maintainers.cachix.org-1:0dq3bujKpuEPMCX6U4WylrUDZ9JyUG0VpVZa7CNfq5E=\" | sudo tee -a /etc/nix/nix.conf",

      // Can't install home-manager here due to https://discourse.nixos.org/t/nix-channel-update-error-error-cannot-open-connection-to-remote-store-daemon-error-reading-from-file-connection-reset-by-peer/40342.

      //// Install miniconda
      "sudo mkdir -p /opt/miniconda3",
      "sudo chown ubuntu /opt/miniconda3/",
      "wget --quiet https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O ~/miniconda.sh",
      "bash ~/miniconda.sh -b -u -p /opt/miniconda3/",
      "rm ~/miniconda.sh",
      "/opt/miniconda3/bin/conda init --all",

      //// Install JAX and PyTorch into a conda environment
      "/opt/miniconda3/bin/conda create --name=bitbop",
      "echo \"conda activate bitbop\" >> ~/.bashrc",

      // Notes:
      //   1. See https://stackoverflow.com/a/75196825 as to why we need to set
      //      `CONDA_OVERRIDE_CUDA`.
      //   2. jaxlib currently (2024-01-29) only has wheels for 11.8. Cf https://anaconda.org/conda-forge/jaxlib/files
      //      for the latest status.
      //   3. Adding conda-forge::tensorflow=*=*cuda118* results in a conda bug
      //      (https://github.com/conda/conda/issues/13540).
      <<-EOF
      CONDA_OVERRIDE_CUDA="11.8" /opt/miniconda3/bin/conda install --yes --name=bitbop \
        ipython \
        jupyter \
        matplotlib \
        wandb \
        conda-forge::jaxlib=*=*cuda118* \
        conda-forge::jax \
        fastai::fastai \
        nvidia::cuda-nvcc=11.8 \
        pytorch::pytorch \
        pytorch::torchvision \
        pytorch::torchaudio \
        pytorch::pytorch-cuda=11.8
      EOF
      ,
      "/opt/miniconda3/bin/conda clean --all",

      //// Set up swap space
      // See https://www.digitalocean.com/community/tutorials/how-to-add-swap-space-on-ubuntu-20-04.
      "sudo fallocate -l 4G /swapfile",
      "sudo chmod 600 /swapfile",
      "sudo mkswap /swapfile",
      "sudo swapon /swapfile",
      "echo \"/swapfile none swap sw 0 0\" | sudo tee -a /etc/fstab",

      // One final update and upgrade. For some reason, there can be upgrades
      // available after the NVIDIA driver installation.
      "sudo apt-get update",
      "sudo apt-get upgrade -y",
    ]
  }
}
