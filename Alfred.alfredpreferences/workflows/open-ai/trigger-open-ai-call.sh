#!/usr/bin/env zsh

if ! command -v node &>/dev/null; then echo "node not installed. Install via \`brew install node\`" && return 1; fi
prompt=$1

# API Key accessed from .zshenv to keep it out of the dotfiles
node ./call-openai-api.mjs "$OPENAI_API_KEY" "$prompt"
