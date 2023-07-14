#!/usr/bin/env zsh
export PATH=/usr/local/lib:/usr/local/bin:/opt/homebrew/bin/:$PATH

if ! command -v numi-cli &>/dev/null; then
	result="numi-cli not installed"
	subtitle="↵ : Copy \`brew install nikolaeu/numi/numi-cli\` to the clipboard"
	arg="brew install nikolaeu/numi/numi-cli"
else
	# shellcheck disable=2154
	result=$(numi-cli --precision="$precision" -- "$1") # using `--` so negative numbers work
	subtitle="$1"
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
