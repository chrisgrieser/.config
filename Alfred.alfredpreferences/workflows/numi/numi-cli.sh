#!/usr/bin/env zsh

# shellcheck disable=2154
query="$alfred_workflow_keyword$1"

if ! command -v numi-cli &>/dev/null; then
	result="numi-cli not installed"
	subtitle="↵ : Copy \`brew install nikolaeu/numi/numi-cli\` to the clipboard"
	arg="brew install nikolaeu/numi/numi-cli"
else
	# shellcheck disable=2154
	result=$(numi-cli --precision="$precision" -- "$query") # using `--` so negative numbers work
	subtitle="$query"
	arg="$result"
fi

cat <<EOF
{
	"items": [
		{
			"title": "$result",
			"subtitle": "$subtitle",
			"arg": "$arg",
		},
	]
}
EOF
