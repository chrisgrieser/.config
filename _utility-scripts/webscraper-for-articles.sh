#!/bin/zsh
# shellcheck disable=SC2028,SC2248,SC2030,SC2031,SC2002

#-------------------------------------------------------------------------------

# check presence of dependencies
if ! command postlight-parser &>/dev/null; then
	echo "postlight-parser not installed."
	echo "install: npm -g install @postlight/parser"
fi
if ! command turndown-cli &>/dev/null; then
	echo "turndown-cli not installed."
	echo "install: npm -g install turndown-cli"
fi
if ! command yq &>/dev/null; then
	echo "yq not installed."
	echo "install: brew install yq"
fi
if ! command readable &>/dev/null; then
	echo "readability-cli not installed."
	echo "install: npm install -g readability-cli"
fi
if ! command readable &>/dev/null || ! command postlight-parser &>/dev/null || ! command turndown-cli &>/dev/null || ! command yq &>/dev/null; then
	exit 1
fi

# Report file
echo "REPORT" >"$REPORT_FILE"
echo "-------------------" >>"$REPORT_FILE"

#-------------------------------------------------------------------------------

# input args / Config
INPUT_FILE="$1"
OUTPUT_FOLDER="$2"
if [[ ! -f "$INPUT_FILE" ]]; then
	echo "Incorrect input file."
	exit 1
fi
[[ -z "$OUTPUT_FOLDER" ]] && OUTPUT_FOLDER="."
TOLERANCE=15 # number of words treshhold
MAX_TITLE_LENGTH=45
REPORT_FILE="$OUTPUT_FOLDER/report.csv"
DESTINATION="$OUTPUT_FOLDER/files/"
mkdir -p "$DESTINATION"

#-------------------------------------------------------------------------------

PROGRESS_COUNT=0
SUCCESS_COUNT=0
ERROR_COUNT=0
WARNING_COUNT=0

# GREP ONLY URLS
INPUT=$(cat "$INPUT_FILE" | grep -Eo "https?://[a-zA-Z0-9./?=_%:-]*")
LINE_COUNT=$(echo "$INPUT" | wc -l | tr -d " ")

echo "$INPUT" | while read -r line; do
	URL="$line"
	PROGRESS_COUNT=$((PROGRESS_COUNT + 1))
	echo -n "\033[0m$PROGRESS_COUNT/$LINE_COUNT: "

	# CHECK WHETHER URL IS ALIVE
	HTTP_CODE=$(curl -sI "$URL" | head -n1 | sed -E 's/[[:space:]]*$//g')
	if [[ "$HTTP_CODE" != "HTTP/2 200" ]]; then
		echo "\033[1;31mURL is dead: $HTTP_CODE\033[0m"
		echo "🟥;$HTTP_CODE;;;$URL" >>"$REPORT_FILE"
		ERROR_COUNT=$((ERROR_COUNT + 1))
		continue
	fi

	# SCRAPPING VIA READABILITY-CLI
	readable --quite "$URL" | tr -s " " >temp.html
	turndown-cli --head=2 --hr=2 --bullet=2 --code=2 temp.html &>/dev/null
	output_readable=$(tr -s " " <temp.md)

	# SCRAPPING VIA POSTLIGHT READER
	parsed_data=$(postlight-parser "$URL")
	echo "$parsed_data" | yq .content >temp.html
	turndown-cli --head=2 --hr=2 --bullet=2 --code=2 temp.html &>/dev/null
	# shellcheck disable=SC1111
	output_postlight=$(tr "’“”" "'\"\"" <temp.md | sed 's/\\\. /. /g' | tr -s " ")
	rm temp.html temp.md

	# METADATA VIA POSTLIGHT READER
	title=$(echo "$parsed_data" | yq .title)
	author=$(echo "$parsed_data" | yq .author | sed 's/^[Bb]y //')
	excerpt=$(echo "$parsed_data" | yq .excerpt)
	article_word_count=$(echo "$parsed_data" | yq .word_count)
	site=$(echo "$parsed_data" | yq .domain)
	date_published=$(echo "$parsed_data" | yq .date_published | cut -d"T" -f1)
	# try to parse date from URL
	if [[ "$date_published" == "null" ]]; then
		date_published=$(echo "$URL" | grep -Eo "\d{4}[/-]\d{1,2}[/-]\d{1,2}" | tr "/" "-")
	fi
	frontmatter=$(
		echo "---"
		echo "title: $title"
		echo "author: $author"
		echo "site: $site"
		echo "date: $date_published"
		echo "excerpt: $excerpt"
		echo "words: $article_word_count"
		echo "source: $URL"
		echo "---"
	)

	safe_title=$(echo "$title" | tr "/:;.\\" "-----" | cut -c-$MAX_TITLE_LENGTH)
	year=$(echo "$date_published" | grep -Eo "\d{4}")
	file_name="${year}_${safe_title}.md"

	# QUALITY CONTROL
	# (using word count instead of diff for performance)
	count_postlight=$(echo "$output_postlight" | wc -w) # counting words instead of characters since less prone to variation due to whitespace or formatting style
	count_readable=$(echo "$output_readable" | wc -w)

	if [[ $count_readable -gt $count_postlight ]]; then
		highest_count=$count_readable
	else
		highest_count=$count_postlight
	fi
	if [[ $count_readable -lt $count_postlight ]]; then
		lowest_count=$count_readable
	else
		lowest_count=$count_postlight
	fi
	count_diff=$((highest_count - lowest_count))

	if [[ $count_diff -gt $TOLERANCE ]]; then
		echo -n "\033[1;33mDifference of $count_diff words"
		WARNING_COUNT=$((WARNING_COUNT + 1))
		echo "🟨;Postlight: $count_postlight;Readable: $count_readable;$URL" >>"$REPORT_FILE"
	else
		echo -n "\033[1;32m" # green
		if [[ $count_diff -eq 0 ]]; then
			echo -n "No Difference"
		elif [[ $count_diff -eq 1 ]]; then
			echo -n "Difference of 1 word."
		else
			echo -n "Difference of $count_diff words."
		fi
		SUCCESS_COUNT=$((SUCCESS_COUNT + 1))
		echo "🟩;Postlight: $count_postlight;Readable: $count_readable;$URL" >>"$REPORT_FILE"
	fi
	echo "\033[0m → '$file_name'"

	# SAVING OUTPUT
	# (use content from the parser which seems to get more content)
	# for using OSX sed to insert lines: https://stackoverflow.com/a/25632073
	# shellcheck disable=SC2086
	if [[ $count_readable -gt $count_postlight ]]; then
		content="$output_readable"
		frontmatter=$(echo "$frontmatter" | sed '6i\
		              parser: Readability')
	else
		content="$output_postlight"
		frontmatter=$(echo "$frontmatter" | sed '6i\
		              parser: Postlight')
	fi

	echo "$frontmatter\n\n$content" >"$DESTINATION/$file_name"
done

#-------------------------------------------------------------------------------

# SUMMARY
echo "\033[0m---"
echo "\033[1;32m$SUCCESS_COUNT\033[0m articles scrapped"
echo "\033[1;33m$WARNING_COUNT\033[0m articles with significant parser difference"
echo "\033[1;31m$ERROR_COUNT\033[0m articles failed"
