#!/usr/bin/env zsh
export PATH=/usr/local/lib:/usr/local/bin:/opt/homebrew/bin/:$PATH
set -e

# CONFIG
output_file="stylelintrc (compiled).yml"
#───────────────────────────────────────────────────────────────────────────────

# download
curl "https://raw.githubusercontent.com/stylelint/stylelint-config-standard/main/index.js" \
	--output "standard.js" --silent
curl "https://raw.githubusercontent.com/stylelint/stylelint-config-recommended/main/index.js" \
	--output "recommended.js" --silent

# merge ES Modules and convert to JSON
node --experimental-detect-module --eval '
	import * as recommended from "./recommended.js"
	import * as standard from "./standard.js"
	const merged = Object.assign({}, recommended.default.rules, standard.default.rules)
	console.log(JSON.stringify(merged));
' > stylelint-standard.json

# convert to YAML
yq --output-format="yaml" stylelint-standard.json > stylelint-standard.yml

# merge with existing config, giving to values from the personal config
yq '.rules = load("stylelint-standard.yml") + .rules' personal-config.yml > "$output_file"

# PENDING stylelint-lsp upgrade
yq --inplace 'del(.rules.lightness-notation)' "$output_file"

# cleanup temp files
rm -f recommended.js standard.js stylelint-standard.json stylelint-standard.yml

echo "Done."
