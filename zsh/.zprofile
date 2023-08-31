# Fig pre block. Keep at the top of this file.
[[ -f "$HOME/.fig/shell/zprofile.pre.zsh" ]] && builtin source "$HOME/.fig/shell/zprofile.pre.zsh"
# Homebrew Setup
if [[ $(uname -p) == "arm" ]]; then
	eval "$(/opt/homebrew/bin/brew shellenv)" # M1 Mac
else
	eval "$(/usr/local/bin/brew shellenv)" # Intel mac
fi

# Fig post block. Keep at the bottom of this file.
[[ -f "$HOME/.fig/shell/zprofile.post.zsh" ]] && builtin source "$HOME/.fig/shell/zprofile.post.zsh"
