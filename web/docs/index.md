---
sidebar_position: 1
---

# bitbop.io

## Auto-shutdown

bitbop.io periodically checks whether your instance is running and will shut it down if it has not had an active SSH session for 1 hour. This protects you from surprise bills and lowers total compute spend such that you only have to pay for what you use. Note that many tools, including VSCode, maintain SSH connection(s) when connected.

If you would like to temporarily disable auto-shutdown, eg to complete a training run, you can use [keep alive](#keep-alive).

## Keep-alive

You can use the `//keepalive` command to temporarily disable auto-shutdown. Running eg

```
ssh bitbop.io //keepalive 4.5h
```

will disable auto-shutdown for 4.5 hours. You can use

```
ssh bitbop.io //keepalive
```

to check how much time is left on your current keep-alive, and

```
ssh bitbop.io //keepalive unset
```

to unset any active keep-alive timer.

### Example keep-alive workflow

Let's say we have a script `train.py` that we estimate to take 6 hours to complete. We'd like to set it up to run overnight. We can use the following example workflow:

1. Start a [tmux](https://github.com/tmux/tmux) session.
2. Launch `python3 train.py ; sudo shutdown +30` to run `train.py` and then shut down the instance 30 minutes after `train.py` completes. By adding a 30 minute buffer, we give ourselves time to recover should `train.py` fail. Note that you can cancel the shutdown with `sudo shutdown -c`.
3. Detach from the tmux session with `Ctrl-b d`. This will keep the tmux session running in the background, including any process running in the tmux session.
4. Run `ssh bitbop.io //keepalive 7h` to disable auto-shutdown for 7 hours. By setting the keep-alive longer than the expected runtime, we ensure that the instance will not shut down before `train.py` completes.
