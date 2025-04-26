#!/usr/bin/env zsh
# https://github.com/philocalyst/infat

[[ -x "$(command -v infat)" ]] || brew install philocalyst/tap/infat

infat # without arg, applies `~/.config/infat/config.toml`

brew uninstall infat
brew untap philocalyst/tap
