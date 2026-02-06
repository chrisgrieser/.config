export ZDOTDIR="$HOME/.config/zsh" # location of this zsh configuration
#───────────────────────────────────────────────────────────────────────────────

# NEOVIM
export EDITOR="nvim"
export PATH="$HOME/.local/share/nvim/mason/bin":$PATH # make mason tools available

# PANDOC
# does not have an environment var for this, so using `--data-dir` alias
alias pandoc='pandoc --data-dir="$HOME/.config/pandoc"'

# PASS
# https://git.zx2c4.com/password-store/about/
export PASSWORD_STORE_DIR="$HOME/.password-store"
export PASSWORD_STORE_CLIP_TIME=60
export PASSWORD_STORE_GENERATED_LENGTH=30       # some services break with longer passwords m(
# 1. many services break with special chars m(
# 2. exclude `lIO0` due to them looking too similar
export PASSWORD_STORE_CHARACTER_SET="[A-HJ-NP-Za-hj-np-z1-9]"

# GITHUB_TOKEN https://github.com/settings/tokens
# For security reasons, only export token for the processes that actually need
# it, and using a token with a scope as limited as possible.
function _export_github_token {
	GITHUB_TOKEN="$(cat "$HOME/Library/Mobile Documents/com~apple~CloudDocs/Tech/api-keys/github-token.txt")"
	export GITHUB_TOKEN
}
function export_openai_apikey {
	OPENAI_API_KEY="$(cat "$HOME/Library/Mobile Documents/com~apple~CloudDocs/Tech/api-keys/openai-api-key.txt")"
	export OPENAI_API_KEY
}
