# Conversions
function yaml2json() {
	if ! command -v yq &>/dev/null; then print "\033[1;33myq not installed.\033[0m" && return 1; fi
	local inputfile="$1"

	filename_no_ext=${inputfile%.*} # not using `basename` since it could be yml or yaml
	# using `explode` to expand anchors & aliases
	# https://mikefarah.gitbook.io/yq/operators/anchor-and-alias-operators#explode-alias-and-anchor
	yq --output-format=json 'explode(.)' "$inputfile" >"${filename_no_ext}.json"
}

function json2yaml() {
	if ! command -v yq &>/dev/null; then print "\033[1;33myq not installed.\033[0m" && return 1; fi
	local inputfile="$1"

	filename_no_ext=$(basename "$inputfile" .json)
	yq --output-format=yaml '.' "$inputfile" >"$filename_no_ext.yaml"
}

function json2schema() {
	if ! command -v quicktype &>/dev/null; then print "\033[1;33mquicktype not installed.\033[0m" && return 1; fi
	local inputfile="$1"

	filename_no_ext=$(basename "$inputfile" .json)
	quicktype --lang=schema --out="${filename_no_ext}_schema.json" "$inputfile"
}

#───────────────────────────────────────────────────────────────────────────────

# Helper function, ensures either file, downloaded url, or stdin can be accessed
# at the same path
# $1: filepath or URL; no $1: read from stdin
function file_url_or_stdin() {
	local tmp="/tmp/temp.json"
	if [[ -z "$1" ]]; then
		echo "$(</dev/stdin)" | tr -d "\n" >"$tmp"
	elif [[ -f "$1" ]]; then
		local filepath="$1"
		cp -f "$filepath" "$tmp"
	else
		local url="$1"
		curl --silent "$url" >"$tmp"
	fi
}

# fx, but in a new tab
function fx() {
	if ! command -v fx &>/dev/null; then print "\033[1;33mfx not installed.\033[0m" && return 1; fi
	if ! [[ "$TERM_PROGRAM" == "WezTerm" ]]; then echo "Not using WezTerm." && return 1; fi

	local tmp="/tmp/temp.json"
	file_url_or_stdin "$1"

	curl --silent "$url" --output "$tmp"
	pane_id=$(wezterm cli spawn -- fx "$tmp") # open in new wezterm tab
	wezterm cli set-tab-title --pane-id="$pane_id" "json explore"
}

# json to ts-types, in a new tab
function jt() {
	if ! command -v quicktype &>/dev/null; then print "\033[1;33mquicktype not installed.\033[0m" && return 1; fi
	if ! command -v bat &>/dev/null; then print "\033[1;33mbat not installed.\033[0m" && return 1; fi
	if ! [[ "$TERM_PROGRAM" == "WezTerm" ]]; then echo "Not using WezTerm." && return 1; fi

	local tmp="/tmp/temp.json"
	file_url_or_stdin "$1"
	quicktype --lang=typescript --just-types "$tmp" >>"/tmp/temp.ts"

	# open in new wezterm tab
	pane_id=$(wezterm cli spawn -- bat "/tmp/temp.ts")
	wezterm cli set-tab-title --pane-id="$pane_id" "json types"
}

# json e[x]plore
function jx() {
	if ! command -v fastgron &>/dev/null; then print "\033[1;33m fastgron not installed.\033[0m" && return 1; fi
	if ! command -v fzf &>/dev/null; then print "\033[1;33m fzf not installed.\033[0m" && return 1; fi
	if ! command -v yq &>/dev/null; then print "\033[1;33myq not installed.\033[0m" && return 1; fi

	local tmp="/tmp/temp.json"
	local query="$2"
	file_url_or_stdin "$1"

	# shellcheck disable=2016
	selection=$(fastgron --color --no-newline "$tmp" |
		tail -n +2 |
		sed -E 's/^json\.?/./' | # rm "json" prefix, keep dot for yq. Array: `json[0]`, Object: `json.key`
		fzf --ansi --no-sort --query="$query" --info=inline \
			--height="80%" --preview-window="45%" \
			--preview='yq {1} --colors --output-format=json "/tmp/temp.json"')

	[[ -z "$selection" ]] && return 0 # no selection made -> no exit 130

	key=$(echo -n "$selection" | cut -d" " -f1)

	# output value to the terminal & copy to clipboard
	echo -n "Copied value: "
	yq "$key" --colors --output-format=json "$tmp"
	yq "$key" --output-format=json "$tmp" | pbcopy
}
