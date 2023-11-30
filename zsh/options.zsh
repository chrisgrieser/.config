# DOCS https://zsh.sourceforge.io/Doc/Release/Options.html
#───────────────────────────────────────────────────────────────────────────────

# GENERAL
setopt INTERACTIVE_COMMENTS # comments in interactive mode, useful for copypasting
setopt CORRECT
setopt GLOB_DOTS # glob includes dotfiles
setopt PIPE_FAIL # exit if pipeline failed

# colorized
function command_not_found_handler() {
	print "\e[1;33mCommand not found: \e[1;31m$1\e[0m"
	return 127
}

#───────────────────────────────────────────────────────────────────────────────
# LANGUAGE

# sets English everywhere, fixes encoding issues
export LC_ALL="en_US.UTF-8"
export LANG="en_US.UTF-8"
export LC_CTYPE="en_US.UTF-8"
