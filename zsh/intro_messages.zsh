# shellcheck disable=SC2164,SC1009,SC1073,SC1056

## don't show the intro messages on terminals with lower height (e.g. embedded ones)
[[ $(tput lines) -gt 20 ]] || return 0

if ! command -v cowsay &>/dev/null; then echo "cowsay not installed." && return 1; fi
if ! command -v fortune &>/dev/null; then echo "fortune not installed." && return 1; fi

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

width=$(($(tput cols) - 10))
[[ $width -gt $cow_maxwidth ]] && width=$cow_maxwidth

# turn the speech bubble into nicer box drawing characters, restore the cow to
# the traditional the characters there have been affected
fortune -n270 -s | cowsay -W$width "$random_emotion" |
	sed -E -e 's/^ _/ ╭/' -E -e 's/^ -/ ╰/' -E -e 's/_ $/──╮/' -E -e 's/- $/──╯/' \
	-E -e 's,[|/\\>]$,│,g' -E -e 's,^[|/\\<], │,g' -E -e 's/[_-]/─/g' \
	-e 's/\^──\^/^__^/' -e 's/\(──\)/(--)/' -e 's/\\───────/\\_______/' \
	-e 's/\|\|────w │/||----w |/' -e 's,\\/│,\\/\\,' -e 's/\|│/||/'

#───────────────────────────────────────────────────────────────────────────────
# show files in current directory
separator
inspect
