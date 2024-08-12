# Collection of useful install scripts

## Neovim
I tend to spend a lot of time on Ubuntu VMs and always have to do a manual `neovim` installation since the one on `apt-get` is out of date and I don't want to use `snap`.

So, I decided to write a script to handle installation on MacOS (Arm), Ubuntu (Arm) and Ubuntu (x86). I also can't stand mouse support being enabled so it gets disabled by default.

To install it, just run the `nvim-setup/install-nvim.sh` script:

```bash
curl -sS https://raw.githubusercontent.com/wardyorgason/dev-scripts/main/nvim-setup/install-nvim.sh | bash
```