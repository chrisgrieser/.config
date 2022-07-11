#!/usr/bin/env zsh

cd ~/.config/karabiner/assets/complex_modifications/ || exit 1

for f in *.yaml ; do
  f=$(basename "$f" .yaml)
  yq -o=json '.' "$f.yaml" > "$f.json"
done

for f in *.yml ; do
  f=$(basename "$f" .yml)
  yq -o=json '.' "$f.yml" > "$f.json"
done

