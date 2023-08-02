#!/bin/zsh
# shellcheck disable=2164,2154

# INPUT
pdf_path="$*"
[[ -z "$pdf_path" ]] && pdf_path=$(osascript "./scripts/get-pdf-path.applescript")

#───────────────────────────────────────────────────────────────────────────────
# GUARD CLAUSES & CITEKEY RETRIEVAL

if [[ ! -f "$bibtex_library_path" ]]; then
	echo "⚠️ Library file does not exist."
	exit 1
elif [[ "$pdf_path" == "No file selected." ]]; then
	echo "⚠️ No file selected."
	exit 1
elif [[ "$pdf_path" == "More than one file selected." ]]; then
	echo "⚠️ More than one file selected."
	exit 1
elif [[ "$pdf_path" != *.pdf ]]; then
	echo "⚠️ Not a .pdf file."
	exit 1
fi

citekey=$(basename "$pdf_path" .pdf | sed -E 's/_.*//')
entry=$(grep --after-context=20 --max-count=1 --ignore-case "{$citekey," "$bibtex_library_path")
if [[ -z "$entry" ]]; then
	echo "⚠️ No entry with the citekey $citekey found in library file."
	exit 1
fi

if [[ "$extraction_engine" == "pdfannots" ]] && ! command -v pdfannots &>/dev/null; then
	echo "⚠️ pdfannots not installed."
	exit 1
elif [[ "$extraction_engine" == "pdfannots2json" ]] && ! command -v pdfannots2json &>/dev/null; then
	echo "⚠️ pdfannots2json not installed."
	exit 1
fi

#───────────────────────────────────────────────────────────────────────────────
# EXTRACTION
osascript -e 'display notification "⏳ Running Extraction…" with title "Annotation Extractor"'

if [[ "$extraction_engine" == "pdfannots" ]]; then
	annotations=$(pdfannots --no-group --format=json "$pdf_path")
else
	prevDir="$PWD"
	IMAGE_FOLDER="${output_path/#\~/$HOME}/attachments/image_temp"
	mkdir -p "$IMAGE_FOLDER" && cd "$IMAGE_FOLDER"

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
			mv -f "$image" ../"${citekey}_image${i}.png"
			i=$((i + 1))
		done
	fi

	rmdir "$IMAGE_FOLDER" # remove temp folder
	cd "$prevDir"
fi

#───────────────────────────────────────────────────────────────────────────────

# PROCESS ANNOTATIONS
osascript -l JavaScript "./scripts/process_annotations.js" \
	"$citekey" "$annotations" "$entry" "$output_path" "$extraction_engine"
