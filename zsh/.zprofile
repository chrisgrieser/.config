# vim: filetype=bash
#───────────────────────────────────────────────────────────────────────────────

# INFO arm = M1 macs
brew_prefix=$([[ $(uname -p) == "arm" ]] && echo "/opt/homebrew" || echo "/usr/local")
eval "$($brew_prefix/bin/brew shellenv)" 
