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
	local url="$*"

	curl --silent "$url" --output "/tmp/jsonx.json"
	pane_id=$(wezterm cli spawn -- fx "/tmp/jsonx.json") # open in new wezterm tab
	wezterm cli set-tab-title --pane-id="$pane_id" "json explore"
}

# json [t]ype (as typescript)
function jsont() {
	if ! command -v quicktype &>/dev/null; then print "\033[1;33mquicktype not installed.\033[0m" && return 1; fi
	if ! command -v bat &>/dev/null; then print "\033[1;33mbat not installed.\033[0m" && return 1; fi
	if ! [[ "$TERM_PROGRAM" == "WezTerm" ]]; then echo "Not using WezTerm." && return 1; fi
	local url="$*"

	# insert URL at top
	echo -e "// $url\n" >"/tmp/jsont.ts" 

	# insert types
	types=$(quicktype "$url" --lang=typescript --just-types)
	echo "$types" >>"/tmp/jsont.ts"

	# open in new wezterm tab
	pane_id=$(wezterm cli spawn -- bat "/tmp/jsont.ts")
	wezterm cli set-tab-title --pane-id="$pane_id" "json types"
}

# json [g]rep
function jsong() {
	if ! command -v fastgron &>/dev/null; then print "\033[1;33m fastgron not installed.\033[0m" && return 1; fi
	if ! command -v fzf &>/dev/null; then print "\033[1;33m fzf not installed.\033[0m" && return 1; fi
	if ! command -v yq &>/dev/null; then print "\033[1;33myq not installed.\033[0m" && return 1; fi

	local url="$1"
	local query="$2"
	curl -sL "$url" > "/tmp/jsong.json"

	# shellcheck disable=2016 
	selection=$(fastgron --color --no-newline "/tmp/jsong.json" |
		cut -c5- | # #cut the leading "json"
		fzf --ansi --no-sort --query="$query" --info=inline \
		--preview-window="45%" --preview='yq {1} --colors "/tmp/jsong.json"')

	# no selection made -> no exit 130
	[[ -z "$selection" ]] && return 0 

	# selection made -> copy
	echo -n "$selection" | pbcopy
	echo "Copied: $selection"
}
