# shellcheck disable=SC2164,SC1009,SC1073,SC1056

# Quick Open File
# (or change directory if a folder is selected)
function o (){
	local INPUT="$*"

	# skip `fzf` if file is fully named (e.g. through tab-completion)
	[[ -f "$INPUT" ]] && { open "$INPUT" ; return }
	[[ -d "$INPUT" ]] && { z "$INPUT" ; return }

	local SELECTED
	SELECTED=$(fd --hidden | fzf \
	           -0 -1 \
	           --query "$INPUT" \
	           --preview "if [[ -d {} ]] ; then exa ; else ; bat --color=always --style=snip --wrap=character --tabs=2 --line-range=:\$FZF_PREVIEW_LINES --terminal-width=\$FZF_PREVIEW_COLUMNS {} ; fi" \
	           )
	[[ -z "$SELECTED" ]] && return 130 # abort if no selection

	if [[ -d "$SELECTED" ]] ; then
		z "$SELECTED" || return 1
	else
		open "$SELECTED"
	fi
}
