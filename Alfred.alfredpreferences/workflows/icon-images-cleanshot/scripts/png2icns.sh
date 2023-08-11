#!/usr/bin/env zsh
# based on: https://news.ycombinator.com/item?id=36495008

input_pngs=("$@")

output_dir=$(dirname "$1")
cd "$output_dir" || return 1

for png in "${input_pngs[@]}"; do
	output_name="$(basename -s ".png" "$png").iconset"
	mkdir "$output_name"

	for size in 16 32 64 128 256 512; do
		sips -z $size $size "$png" --out "$output_name/icon_${size}x${size}.png"
		sips -z $size $size "$png" --out "$output_name/icon_${size}x${size}@2x.png"
	done
	iconutil -c icns "$output_name"

	rm -rf "$output_name"
done
