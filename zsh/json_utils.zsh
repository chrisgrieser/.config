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

#───────────────────────────────────────────────────────────────────────────────

# $1: filepath or URL
# ensures either file or the downloaded url can be accessed at the same path
function file_or_url() {
	local tmp="/tmp/temp.json"
	if [[ -f "$1" ]]; then
		local filepath="$1"
		mv -f "$filepath" "$tmp"
	else
		local url="$1"
		curl --silent "$url" >"$tmp"
	fi
}

# json [s]chema
function jsons() {
	if ! command -v quicktype &>/dev/null; then print "\033[1;33mquicktype not installed.\033[0m" && return 1; fi
	local inputfile="$1"

	filename_no_ext=$(basename "$inputfile" .json)
	quicktype --lang=schema --out="${filename_no_ext}_schema.json" "$inputfile"
}

# json e[x]plore (via pager)
function jsonx() {
	if ! command -v fx &>/dev/null; then print "\033[1;33mfx not installed.\033[0m" && return 1; fi
	if ! [[ "$TERM_PROGRAM" == "WezTerm" ]]; then echo "Not using WezTerm." && return 1; fi

	local tmp="/tmp/temp.json"
	file_or_url "$1"

	curl --silent "$url" --output "$tmp"
	pane_id=$(wezterm cli spawn -- fx "$tmp") # open in new wezterm tab
	wezterm cli set-tab-title --pane-id="$pane_id" "json explore"
}

# json [t]ype (as typescript)
function jsont() {
	if ! command -v quicktype &>/dev/null; then print "\033[1;33mquicktype not installed.\033[0m" && return 1; fi
	if ! command -v bat &>/dev/null; then print "\033[1;33mbat not installed.\033[0m" && return 1; fi
	if ! [[ "$TERM_PROGRAM" == "WezTerm" ]]; then echo "Not using WezTerm." && return 1; fi

	local tmp="/tmp/temp.json"
	file_or_url "$1"
	quicktype --lang=typescript --just-types "$tmp" >> "/tmp/temp.ts"

	# open in new wezterm tab
	pane_id=$(wezterm cli spawn -- bat "/tmp/temp.ts")
	wezterm cli set-tab-title --pane-id="$pane_id" "json types"
}

# json [g]rep
function jsong() {
	if ! command -v fastgron &>/dev/null; then print "\033[1;33m fastgron not installed.\033[0m" && return 1; fi
	if ! command -v fzf &>/dev/null; then print "\033[1;33m fzf not installed.\033[0m" && return 1; fi
	if ! command -v yq &>/dev/null; then print "\033[1;33myq not installed.\033[0m" && return 1; fi

	local tmp="/tmp/temp.json"
	file_or_url "$1"
	local query="$2"

	# shellcheck disable=2016
	selection=$(fastgron --color --no-newline "$tmp" |
		tail -n +2 | # skip full object
		sed -E 's/^json\.?/./' | # rm "json" prefix, keep dot for yq. Array: `json[0]`, Object: `json.key`
		fzf --ansi --no-sort --query="$query" --info=inline \
			--height=60% --preview-window="45%" \
			--preview='yq {1} --colors --output-format=json "/tmp/temp.json"')

	[[ -z "$selection" ]] && return 0 # no selection made -> no exit 130

	key=$(echo -n "$selection" | cut -d" " -f1)

	# output value to the terminal & copy to clipboard
	echo -n "Copied value: "
	yq "$key" --color --output-format=json "$tmp"
	yq "$key" --output-format=json "$tmp" | pbcopy
}
