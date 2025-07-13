#!/usr/bin/env zsh
#───────────────────────────────────────────────────────────────────────────────

# INFO needs this added to `.zprofile` to work for neovide:
export PATH="$HOME/.local/neovim-downgrade/bin:$PATH"

#───────────────────────────────────────────────────────────────────────────────
# CONFIG
version="v0.11.2"

rm -rf "$HOME/.local/neovim-downgrade"
cd -q "$HOME/.local" || return 1
curl --location --output "neovim-downgrade.tar.gz" "https://github.com/neovim/neovim/releases/download/$version/nvim-macos-arm64.tar.gz"
xattr -c "neovim-downgrade.tar.gz"
tar xzvf "neovim-downgrade.tar.gz"
rm "neovim-downgrade.tar.gz"
mv "nvim-macos-arm64" "neovim-downgrade"
