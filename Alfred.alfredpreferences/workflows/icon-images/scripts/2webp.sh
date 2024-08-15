#!/usr/bin/env zsh

input_images=("$@")

output_dir=$(dirname "$1")
cd "$output_dir" || return 1

for image in "${input_images[@]}"; do
	cwebp -quiet "$image" -o "${image:r}.webp"
done
