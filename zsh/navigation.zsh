# DOCS https://blog.meain.io/2023/navigating-around-in-shell/
#───────────────────────────────────────────────────────────────────────────────

setopt AUTO_CD # pure directory = cd into it
# setopt AUTO_PUSHD
# setopt PUSHD_SILENT
# setopt PUSHD_TO_HOME

export CDPATH="$HOME/.config"

#───────────────────────────────────────────────────────────────────────────────

# INFO leading space to ignore it in history due to HIST_IGNORE_SPACE
alias ..=" cd .."
alias ...=" cd ../.."
alias ....=" cd ../../.."

#───────────────────────────────────────────────────────────────────────────────

# mkdir and cd
function mkcd {
	mkdir -p "$1" && cd "$1" || return 1
}

function cd() {
	builtin cd "$@" || return 1
	auto_venv
}

