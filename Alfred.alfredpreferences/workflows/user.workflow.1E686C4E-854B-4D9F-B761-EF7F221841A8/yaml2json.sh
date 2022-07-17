#!/usr/bin/env zsh
export PATH=/usr/local/lib:/usr/local/bin:/opt/homebrew/bin/:$PATH
cd ~/.config/karabiner/assets/complex_modifications/ || exit 1

for f in *.yaml ; do
  f=$(basename "$f" .yaml)
  yq -o=json '.' "$f.yaml" > "$f.json"
done

