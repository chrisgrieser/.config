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

[[ $((RANDOM % 2)) == 1 ]] && say_or_think="cowsay" || say_or_think="cowthink"

# shellcheck disable=SC2248
fortune -n270 -s | sed 's/--/\n--/g' | $say_or_think -W$width "$random_emotion"

#───────────────────────────────────────────────────────────────────────────────
# show files in current directory
separator
inspect
