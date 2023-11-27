
# GUARD
# don't show the intro messages on terminals with lower height (e.g. embedded ones)
[[ $LINES -gt 20 ]] || return 0

if [[ ! -x "$(command -v cowsay)" ]]; then print "\e[1;33mcowsay not installed.\e[0m" && return 1; fi
if [[ ! -x "$(command -v fortune)" ]]; then print "\e[1;33mfortune not installed.\e[0m" && return 1; fi

#───────────────────────────────────────────────────────────────────────────────

# COW & FORTUNE
mode=(
	""   # standard
	"-b" # Borg Mode
	"-d" # dead
	"-g" # greedy
	"-p" # paranoia
	"-s" # stoned
	"-t" # tired
	"-w" # wake/wired
	"-y" # youthful
)

rand=$((RANDOM % ${#mode[@]}))
random_emotion=${mode[$rand]}
cow_maxwidth=70

# turn the speech bubble into nicer box drawing characters, restore the cow to
# the traditional the characters there have been affected
fortune -n270 -s | cowsay -W$cow_maxwidth "$random_emotion" |
	sed -Ee 's/^ _/ ╭/' -Ee 's/^ -/ ╰/' -Ee 's/_ $/──╮/' -Ee 's/- $/──╯/' \
	-Ee 's,[|/\\>]$,│,g' -Ee 's,^[|/\\<], │,g' -Ee 's/[_-]/─/g' \
	-e 's/\^──\^/^__^/' -e 's/\(──\)/(--)/' -e 's/\\───────/\\_______/' \
	-e 's/\|\|────w │/||----w |/' -e 's,\\/│,\\/\\,' -e 's/\|│/||/' \
	-e 's,  \\  ,    ,g'

#───────────────────────────────────────────────────────────────────────────────
# show files in current directory
_separator
_magic_dashboard
