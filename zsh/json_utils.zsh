# Conversions
function yaml2json() {
	file_name=${1%.*} # remove ext. (not using `basename` since it could be yml or yaml)
	# using `explode` to expand anchors & aliases
	# https://mikefarah.gitbook.io/yq/operators/anchor-and-alias-operators#explode-alias-and-anchor
	yq --output-format=json 'explode(.)' "$1" >"${file_name}.json"
}

function json2yaml() {
	file_name=$(basename "$1" .json)
	yq --output-format=yaml '.' "$1" >"$file_name.yaml"
}

#───────────────────────────────────────────────────────────────────────────────
# json e[x]plore (via pager)
function jsonx() {
	if ! command -v fx &>/dev/null; then print "\033[1;33mfx not installed.\033[0m" && return 1; fi
	if ! [[ "$TERM_PROGRAM" == "WezTerm" ]]; then echo "Not using WezTerm." && return 1; fi

	local url="$*"
	curl --silent "$url" --output "/tmp/fx-curl.json"
	pane_id=$(wezterm cli spawn -- fx "/tmp/fx-curl.json")
	wezterm cli set-tab-title --pane-id="$pane_id" "curl-fx"
}

# json [t]ype (as typescript interfaces)
function jsont() {
	if ! command -v quicktype &>/dev/null; then print "\033[1;33mquicktype not installed.\033[0m" && return 1; fi
	if ! command -v bat &>/dev/null; then print "\033[1;33mbat not installed.\033[0m" && return 1; fi
	
	local url="$*"
	quicktype "$url" --lang=typescript --just-types | bat --language=typescript --style=plain
}

