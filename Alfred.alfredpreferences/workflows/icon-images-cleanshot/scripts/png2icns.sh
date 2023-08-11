#!/usr/bin/env zsh
# based on: https://news.ycombinator.com/item?id=36495008

#───────────────────────────────────────────────────────────────────────────────

input_png="$1"
output_dir=$(dirname "$input_png")
output_name="$(basename -s ".png" "$input_png").iconset"
cd "$output_dir"|| return 1

#───────────────────────────────────────────────────────────────────────────────

mkdir "$output_name"

cp "$input_png" "$output_name/icon_512x512@2x.png"
sips -z 16 16 "$input_png" --out "$output_name/icon_16x16.png"
sips -z 32 32 "$input_png" --out "$output_name/icon_16x16@2x.png"
sips -z 32 32 "$input_png" --out "$output_name/icon_32x32.png"
sips -z 64 64 "$input_png" --out "$output_name/icon_32x32@2x.png"
sips -z 128 128 "$input_png" --out "$output_name/icon_128x128.png"
sips -z 256 256 "$input_png" --out "$output_name/icon_128x128@2x.png"
sips -z 256 256 "$input_png" --out "$output_name/icon_256x256.png"
sips -z 512 512 "$input_png" --out "$output_name/icon_256x256@2x.png"
sips -z 512 512 "$input_png" --out "$output_name/icon_512x512.png"

iconutil -c icns "$output_name"
rm -rf "$output_name"
