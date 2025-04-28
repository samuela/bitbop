// Run with `nix develop -c packer build packer/ami.pkr.hcl`

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
  instance_type = "m7i.xlarge"
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

      //// Install Starship (cross-shell prompt)
      "curl -LsSf https://starship.rs/install.sh -o starship-install.sh",
      "echo \"56da063be2d93348b6181275b235108ad6dd39bc2c2faee053889f57666ac30a starship-install.sh\" | sha256sum --check",
      "sudo sh starship-install.sh --yes",
      "rm starship-install.sh",
      "echo 'eval \"$(starship init bash)\"' >> ~/.bashrc",

      //// Install uv (fast Python package installer)
      "curl -LsSf https://astral.sh/uv/install.sh -o uv-install.sh",
      "echo \"3a1bab070910da4186097de4af36b13a24cd6d467e6d1b984dc0a252c3e572a9 uv-install.sh\" | sha256sum --check",
      "sh uv-install.sh",
      "rm uv-install.sh",
      "echo 'eval \"$(uv generate-shell-completion bash)\"' >> ~/.bashrc",
      "echo 'eval \"$(uvx --generate-shell-completion bash)\"' >> ~/.bashrc",

      //// Install JAX and PyTorch into a uv environment
      <<-EOF
        sudo mkdir /opt/bitbop-default-venv
        sudo chown ubuntu /opt/bitbop-default-venv
        /home/ubuntu/.local/bin/uv venv /opt/bitbop-default-venv

        # As of 2025-04-27, installing pytorch before jax is necessary to avoid:
        #
        #   Loaded runtime CuDNN library: 9.7.1 but source was compiled with:
        #   9.8.0. CuDNN library needs to have matching major version and equal
        #   or higher minor version. If using a binary install, upgrade your
        #   CuDNN library.  If building from sources, make sure the library
        #   loaded at runtime is compatible with the version specified during
        #   compile configuration.
        /home/ubuntu/.local/bin/uv --directory=/opt/bitbop-default-venv/ pip install --upgrade \
          torch \
          torchvision \
          torchaudio \
          --index-url=https://download.pytorch.org/whl/cu128
        # Include pip package so that users can invoke "pip" directly instead of "uv pip" and have it work as they may
        # be expecting.
        /home/ubuntu/.local/bin/uv --directory=/opt/bitbop-default-venv/ pip install --upgrade \
          ipython \
          jupyter \
          matplotlib \
          pip \
          wandb \
          "jax[cuda12]"
      EOF
      ,
      "echo 'if [ -e \"/opt/bitbop-default-venv/bin/activate\" ]; then source /opt/bitbop-default-venv/bin/activate; fi' >> ~/.bashrc",

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
