#!/usr/bin/env zsh
# https://github.com/philocalyst/infat

[[ -x "$(command -v infat)" ]] || brew install philocalyst/tap/infat

brew un
brew uninstall infat
