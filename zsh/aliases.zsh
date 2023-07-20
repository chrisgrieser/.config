# shellcheck disable=2139

#───────────────────────────────────────────────────────────────────────────────

# z & cd
# INFO leading space to ignore it in history due to HIST_IGNORE_SPACE
alias zz=' z -' # back to last dir
alias ..=" z .."
alias ...=" z ../.."
alias ....=" z ../../.."

# MAKE
# if there is no makefile in current dir, runs makefile located in git root
# also, add a pseudo-flag `--list|-l` which lists all recipes
function make() {
	if [[ "$1" == "--list" || "$1" == "-l" ]] && [[ -f "Makefile" || -f "makefile" ]]; then
		grep '^[^#[:space:]].*' ./?akefile | tr -d ":" | grep -v ".PHONY"
	elif [[ "$1" == "--list" || "$1" == "-l" ]]; then
		(cd "$(git rev-parse --show-toplevel)" && grep '^[^#[:space:]].*' ./?akefile | tr -d ":" | grep -v ".PHONY")
	elif [[ -f "Makefile" || -f "makefile" ]]; then
		command make --silent "$@"
	else
		(cd "$(git rev-parse --show-toplevel)" && command make --silent "$@")
	fi
}

# utils
# INFO leading space to ignore it in history due to HIST_IGNORE_SPACE
alias r=' exec zsh' # do not reload with source ~/.zshrc, https://github.com/ohmyzsh/ohmyzsh/wiki/FAQ#how-do-i-reload-the-zshrc-file
alias q=' exit'

# added verbosity
alias mv='mv -v'
alias ln='ln -v'
alias cp='cp -v'

# defaults
alias grep='grep --ignore-case --color'
alias ls='ls --color'  # colorize by default
alias which='which -a' # show all
alias mkdir='mkdir -p' # create intermediate directories
alias curl='curl --silent'

# misc
alias prose='ssh nanotipsforvim@prose.sh'
alias size="du -sh . ./* ./.* | sort -rh | sed 's/\\.\\///'" # size of files in current directory
#───────────────────────────────────────────────────────────────────────────────

alias pip="pip3"
# effectively alias `pip3 update` to `pip3 install --upgrade`
function pip3() {
	if [[ "$1" == "update" ]]; then
		shift
		set -- install --upgrade "$@"
	fi
	command pip3 "$@"
}

alias bkp='zsh "$DOTFILE_FOLDER/_utility-scripts/backup-script.sh"'

alias l='exa --all --long --no-user --header --icons --git --group-directories-first --sort=name'
alias tree='exa --tree --level=2 --icons --git-ignore'
alias treee='exa --tree --level=3 --icons --git-ignore'
alias treeee='exa --tree --level=4 --icons --git-ignore'
alias treeeee='exa --tree --level=5 --icons --git-ignore'

alias diff='diff2html --hwt="$DOTFILE_FOLDER/diff2html/diff2html-template.html"'
#───────────────────────────────────────────────────────────────────────────────
# https://www.thorsten-hans.com/5-types-of-zsh-aliases

# SUFFIX Alias
alias -s {yml,yaml}='yq'
alias -s json='fx'
alias -s {gif,png,jpg,jpeg,webp}='qlmanage -p'
alias -s {md,lua,js,ts,css,sh,zsh,applescript}='bat'

# GLOBAL ALIAS (to be used at the end, mostly)
alias -g G='| rg'
alias -g B='| bat'
alias -g C='| pbcopy ; echo "Copied."' # copy
alias -g N='| wc -l | tr -d " "'       # count lines

# "OK Json" seems to be a good GUI alternative, if needed
alias -g J='| fx' # json preview

# get field #n
for i in {1..9}; do
	alias -g F"$i"="| awk '{ print \$$i }'"
done

# highlights for them
ZSH_HIGHLIGHT_REGEXP+=(" F[1-9]" 'fg=magenta,bold')
ZSH_HIGHLIGHT_REGEXP+=(' G$' 'fg=magenta,bold')
ZSH_HIGHLIGHT_REGEXP+=(' G ' 'fg=magenta,bold')
ZSH_HIGHLIGHT_REGEXP+=(' J$' 'fg=magenta,bold')
ZSH_HIGHLIGHT_REGEXP+=(' C$' 'fg=magenta,bold')
ZSH_HIGHLIGHT_REGEXP+=(' B$' 'fg=magenta,bold')
ZSH_HIGHLIGHT_REGEXP+=(' N$' 'fg=magenta,bold')
