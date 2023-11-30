# GUARD
# don't show the intro messages on terminals with lower height (e.g. embedded ones)
[[ $LINES -gt 20 ]] || return 0

#───────────────────────────────────────────────────────────────────────────────
# COW & FORTUNE

# turn the speech bubble into nicer box drawing characters, restore the cow to
# the traditional the characters there have been affected
fortune -n270 -s | cowsay -W70 |
	sed -Ee 's/^ _/ ╭/' -Ee 's/^ -/ ╰/' -Ee 's/_ $/──╮/' -Ee 's/- $/──╯/' \
	-Ee 's,[|/\\>]$,│,g' -Ee 's,^[|/\\<], │,g' -Ee 's/[_-]/─/g' \
	-e 's/\^──\^/^__^/' -e 's/\(──\)/(--)/' -e 's/\\───────/\\_______/' \
	-e 's/\|\|────w │/||----w |/' -e 's,\\/│,\\/\\,' -e 's/\|│/||/' \
	-e 's,  \\  ,    ,g'

#───────────────────────────────────────────────────────────────────────────────
# show files in current directory
_separator
_magic_dashboard
