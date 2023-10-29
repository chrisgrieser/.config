function yaml2json() {
	if [[ ! -x "$(command -v yq)" ]]; then print "\033[1;33myq not installed.\033[0m" && return 1; fi
	local inputfile="$1"

	filename_no_ext=${inputfile%.*} # not using `basename` since it could be yml or yaml
	# using `explode` to expand anchors & aliases
	# https://mikefarah.gitbook.io/yq/operators/anchor-and-alias-operators#explode-alias-and-anchor
	yq --output-format=json 'explode(.)' "$inputfile" >"${filename_no_ext}.json"
}

function json2yaml() {
	if [[ ! -x "$(command -v yq)" ]]; then print "\033[1;33myq not installed.\033[0m" && return 1; fi
	local inputfile="$1"

	filename_no_ext=$(basename "$inputfile" .json)
	yq --output-format=yaml '.' "$inputfile" >"$filename_no_ext.yaml"
}

function json2schema() {
	if [[ ! -x "$(command -v quicktype)" ]]; then print "\033[1;33mquicktype not installed.\033[0m" && return 1; fi
	local inputfile="$1"

	filename_no_ext=$(basename "$inputfile" .json)
	quicktype --lang=schema --out="${filename_no_ext}_schema.json" "$inputfile"
}

function yaml2schema() {
	if [[ ! -x "$(command -v quicktype)" ]]; then print "\033[1;33mquicktype not installed.\033[0m" && return 1; fi
	if [[ ! -x "$(command -v yq)" ]]; then print "\033[1;33myq not installed.\033[0m" && return 1; fi

	local inputfile="$1"
	filename_no_ext=${inputfile%.*} # not using `basename` since it could be yml or yaml
	local temp_json="$filename_no_ext.json"

	yq --output-format=json 'explode(.)' "$inputfile" >"$temp_json"
	quicktype --lang=schema --out="${filename_no_ext}_schema.json" "$temp_json"
	rm "$temp_json"
}

#───────────────────────────────────────────────────────────────────────────────

# Helper function, ensures either file, downloaded url, or stdin can be accessed
# at the same path
# $1: filepath or URL (if url from last time, use cache to reduce API calls)
# no $1: read from stdin
function file_url_or_stdin() {
	local tmp="/tmp/temp.json"
	if [[ -z "$1" ]]; then
		echo "$(</dev/stdin)" | tr -d "\n" >"$tmp"
	elif [[ -f "$1" ]]; then
		local filepath="$1"
		command cp -f "$filepath" "$tmp"
	else
		local url_temp="/tmp/temp_url.txt"
		local url="$1"
		local last_url
		[[ -f "$url_temp" ]] && last_url=$(cat "$url_temp")
		[[ "$last_url" == "$url" ]] && return # already cached

		# HACK using Chrome as user agent, as some APIs don't like curl
		command curl --progress-bar --header "User-Agent: Chrome/115.0.0.0" "$url" >"$tmp"
		echo "$url" >"$url_temp"
	fi
}

# fx, but in a new wezterm tab
function jless() {
	if [[ ! -x "$(command -v jless)" ]]; then print "\033[1;33mjless not installed.\033[0m" && return 1; fi
	if ! [[ "$TERM_PROGRAM" == "WezTerm" ]]; then echo "Not using WezTerm." && return 1; fi

	local tmp="/tmp/temp.json"
	file_url_or_stdin "$1"

	pane_id=$(wezterm cli spawn -- command jless --no-line-numbers "$tmp") # open in new wezterm tab
	wezterm cli set-tab-title --pane-id="$pane_id" "jless"
}

# [j]son e[x]plore
function jx() {
	if [[ ! -x "$(command -v fastgron)" ]]; then print "\033[1;33mfastgron not installed.\033[0m" && return 1; fi
	if [[ ! -x "$(command -v fzf)" ]]; then print "\033[1;33mfzf not installed.\033[0m" && return 1; fi
	if [[ ! -x "$(command -v yq)" ]]; then print "\033[1;33myq not installed.\033[0m" && return 1; fi

	local tmp="/tmp/temp.json"
	local query="$2"
	file_url_or_stdin "$1"

	# shellcheck disable=2016
	selection=$(fastgron --color --no-newline "$tmp" |
		sed '1d' |      # remove header
		cut -d"=" -f1 | # only key
		# .d[1] -> .d[] to aggregate for yq & also colorize the brackets []
		# `\x1b` escapes the color code https://superuser.com/a/380778
		sed $'s/\\[\x1b\\[1;32m[[:digit:]]*\x1b\\[1;34m\\]/\033[1;33m[]/g' |
		sort | uniq |                # remove duplicates
		sed -E 's/^json\.?/./' |     # rm "json" prefix, keep dot for yq (Array: `json[0]`, Object: `json.key`)
		sed $'s/\\./\033[1;31m./g' | # colorize dots
		fzf --ansi --no-sort --query="$query" --info=inline --exact \
			--height="80%" --preview-window="45%" --keep-right \
			--preview='yq {} --colors --output-format=json "/tmp/temp.json" | grep -v "null"')

	[[ -z "$selection" ]] && return 0 # no selection made -> no exit 130

	key=$(echo -n "$selection" | cut -d" " -f1)
	value=$(yq "$key" --output-format=json "$tmp")
	out="$key = $value"

	# output value to the terminal & copy to clipboard
	echo "Copied:"
	echo "$out"
	echo -n "$out" | pbcopy
}
