#!/usr/bin/env zsh

images=("$@")

for image in "${images[@]}"; do
	width=$(sips --getProperty pixelWidth "$image" | tail -n1 | cut -d: -f2 | tr -d " ")

	# scale only works for division, therefore dividing by 1 https://askubuntu.com/a/754356
	new_width=$(echo "scale = 0; $width * 0.7 / 1" | bc)

	filename_no_ext=${image%.*}
	ext=${image##*.}

	sips -Z "$new_width" "$image" --out "${filename_no_ext}_70%.$ext"
done
