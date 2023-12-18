#!/bin/zsh
# shellcheck disable=2154

# INPUT
pdf_path="$*"
[[ -z "$pdf_path" ]] && pdf_path=$(osascript "./scripts/get-pdf-path.applescript")

#───────────────────────────────────────────────────────────────────────────────

# GUARD
if [[ -n "$bibtex_library_path" && ! -f "$bibtex_library_path" ]]; then
	echo "⚠️ Library file path not valid."
	exit 1
elif [[ -n "$output_path" && ! -d "$output_path" ]]; then
	echo "⚠️ Output path not valid."
	exit 1
elif [[ "$pdf_path" == "no-file" ]]; then
	echo "⚠️ No file selected."
	exit 1
elif [[ "$pdf_path" == "more-than-one-file" ]]; then
	echo "⚠️ More than one file selected."
	exit 1
elif [[ "$pdf_path" == "not-in-pdf-folder" ]]; then
	echo "⚠️ When using Highlights, the PDF must be located in the PDF folder."
	exit 1
elif [[ "$pdf_path" != *.pdf ]]; then
	echo "⚠️ Not a .pdf file."
	exit 1
elif [[ "$extraction_engine" == "pdfannots" ]] && ! command -v pdfannots &>/dev/null; then
	echo "⚠️ pdfannots not installed."
	exit 1
elif [[ "$extraction_engine" == "pdfannots2json" ]] && ! command -v pdfannots2json &>/dev/null; then
	echo "⚠️ pdfannots2json not installed."
	exit 1
fi

#───────────────────────────────────────────────────────────────────────────────
# DETERMINE CITEKEY & OUTPUT NAME

citekey=$(basename "$pdf_path" .pdf | sed -E 's/_.*//')
[[ -n "$bibtex_library_path" ]] &&
	entry=$(grep --after-context=20 --max-count=1 --ignore-case "{$citekey," "$bibtex_library_path")

# with citekey
if [[ -n "$entry" && -n "$bibtex_library_path" ]]; then
	osascript -e "display notification \"⏳ Running Extraction for $citekey…\" with title \"Annotation Extractor\""
	filename="$citekey"
	[[ -z "$output_path" ]] && output_path="$(dirname "$pdf_path")"

# without citekey
else
	osascript -e 'display notification "⏳ Running Extraction…" with title "Annotation Extractor"'
	output_path="$(dirname "$pdf_path")"
	filename="$(basename "$pdf_path" .pdf)_annos"
fi

#───────────────────────────────────────────────────────────────────────────────
# EXTRACTION

if [[ "$extraction_engine" == "pdfannots" ]]; then
	annotations=$(pdfannots --no-group --format=json "$pdf_path")
else
	prevDir="$PWD"
	IMAGE_FOLDER="$output_path/attachments/image_temp"
	mkdir -p "$IMAGE_FOLDER" && cd "$IMAGE_FOLDER" || exit 1

	annotations=$(pdfannots2json "$pdf_path" --image-output-path=./ --image-format="png")

	# IMAGE EXTRACTION
	# shellcheck disable=SC2012
	NUMBER_OF_IMAGES=$(ls | wc -l | tr -d " ")
	if [[ $NUMBER_OF_IMAGES -gt 0 ]]; then
		# HACK: fix zero-padding for low page numbers by giving all images 4 digits
		# see https://github.com/mgmeyers/pdfannots2json/issues/16
		for image in *; do
			leftPadded=$(echo "$image" | sed -E 's/-([[:digit:]])-/-000\1-/' | sed -E 's/-([[:digit:]][[:digit:]])-/-00\1-/' | sed -E 's/-([[:digit:]][[:digit:]][[:digit:]])-/-0\1-/')
			mv "$image" "$leftPadded"
		done

		# rename images
		i=1
		for image in *; do
			mv -f "$image" ../"${filename}_image${i}.png"
			i=$((i + 1))
		done
	fi

	# remove temp folder
	rmdir "$IMAGE_FOLDER"
	# remove attachment folder, if no images are extracted
	# (rmdir fails if folder is not empty)
	rmdir "$output_path/attachments"

	cd "$prevDir" || exit 1
fi

#───────────────────────────────────────────────────────────────────────────────

# PROCESS ANNOTATIONS
osascript -l JavaScript "./scripts/process_annotations.js" \
	"$filename" "$annotations" "$entry" "$output_path" "$extraction_engine"
