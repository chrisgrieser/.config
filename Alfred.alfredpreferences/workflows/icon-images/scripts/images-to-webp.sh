#!/usr/bin/env zsh

if [[ ! -x "$(command -v cwebp)" ]]; then
	print "\`cwebp\` not installed. (Install via \`brew install webp\`)"
	return 1
fi

#───────────────────────────────────────────────────────────────────────────────


input_images=("$@")

output_dir=$(dirname "$1")
cd "$output_dir" || return 1

for image in "${input_images[@]}"; do
	cwebp "$image" -o "${image:r}.webp"
done
