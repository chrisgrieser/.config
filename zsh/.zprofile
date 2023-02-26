# Fig pre block. Keep at the top of this file.
[[ -f "$HOME/.fig/shell/zprofile.pre.zsh" ]] && builtin source "$HOME/.fig/shell/zprofile.pre.zsh"
# Homebrew
if [[ $(uname -p) == "arm" ]]; then
	# M1 Mac
	eval "$(/opt/homebrew/bin/brew shellenv)"
else
	# Intel mac
	eval "$(/usr/local/bin/brew shellenv)"
fi

# Completions for Homebrew, https://docs.brew.sh/Shell-Completion#configuring-completions-in-zsh
FPATH="$(brew --prefix)/share/zsh/site-functions:${FPATH}"

# Fig post block. Keep at the bottom of this file.
[[ -f "$HOME/.fig/shell/zprofile.post.zsh" ]] && builtin source "$HOME/.fig/shell/zprofile.post.zsh"
