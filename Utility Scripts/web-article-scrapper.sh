#!/bin/zsh
# shellcheck disable=SC2028,SC2248,SC2030,SC2031

# input args / Config
INPUT_FILE="$1"
OUTPUT_FOLDER="$2"
if [[ ! -f "$INPUT_FILE" ]] ; then
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

# check presence of dependencies
if ! command mercury-parser &> /dev/null; then
	echo "mercury-parser not installed."
	echo "install: npm -g install @postlight/mercury-parser"
	exit 1
fi
if ! command turndown-cli &> /dev/null ; then
	echo "turndown-cli not installed."
	echo "install: npm -g install turndown-cli"
	exit 1
fi
if ! command yq &> /dev/null; then
	echo "yq not installed."
	echo "install: brew install yq"
	exit 1
fi
if ! command gather &> /dev/null ; then
	echo "gather-cli not installed."
	echo "Install from here: https://github.com/ttscoff/gather-cli"
	echo "(brew-tap requires 12gb Xcode install, so download the package instead…)"
	exit 1
fi

# Report file
echo "Tolerance: $TOLERANCE Words Difference" > "$REPORT_FILE"
echo "------------------------------" >> "$REPORT_FILE"

#-------------------------------------------------------------------------------
SUCCESS_COUNT=0
FAILURE_COUNT=0
# shellcheck disable=SC2002
cat "$INPUT_FILE" | while read -r line ; do

	# skip comments & empty lines
	if [[ -z "$line" ]] || [[ "$line" == \#* ]] ; then
		continue
	else
		URL="$line"
	fi

	# Check whether URL is alive
	HTTP_CODE=$(curl -sI "$URL" | head -n1 | sed -E 's/[[:space:]]*$//g')
	if [[ "$HTTP_CODE" != "HTTP/2 200" ]]; then
		echo "\033[1;31mURL is dead: $HTTP_CODE\033[0m"
		echo "$HTTP_CODE;$URL" >> "$REPORT_FILE"
		FAILURE_COUNT=$((FAILURE_COUNT + 1))
		continue
	fi

	# Scrapping via Mercury Reader
	parsed_data=$(mercury-parser "$URL")
	echo "$parsed_data" | yq .content > temp.html

	turndown-cli --head=2 --hr=2 --bullet=2 --code=2 temp.html &> /dev/null
	# shellcheck disable=SC1111
	output1=$(tr "’“”" "'\"\"" < temp.md | sed 's/\\\. /. /g' | tr -s " ")
	rm temp.html temp.md

	# Metadata via Mercury Reader
	title=$(echo "$parsed_data" | yq .title)
	author=$(echo "$parsed_data" | yq .author | sed 's/^[Bb]y //' )
	excerpt=$(echo "$parsed_data" | yq .excerpt)
	article_word_count=$(echo "$parsed_data" | yq .word_count)
	site=$(echo "$parsed_data" | yq .domain)
	date_published=$(echo "$parsed_data" | yq .date_published | cut -d"T" -f1)
	# try to parse date from URL
	if [[ "$date_published" == "null" ]]; then
		date_published=$(echo "$URL" | grep -Eo "\d{4}[/-]\d{1,2}[/-]\d{1,2}" | tr "/" "-")
	fi
	frontmatter=$(echo "---" ; echo "title: $title" ; echo "author: $author" ; echo "site: $site" ; echo "date: $date_published" ; echo "excerpt: $excerpt" ; echo "words: $article_word_count" ; echo "source: $URL" ; echo "---")

	safe_title=$(echo "$title" | tr "/:;.\\" "-----" | cut -c-$MAX_TITLE_LENGTH)
	year=$(echo "$date_published" | grep -Eo "\d{4}")
	file_name="${year}_${safe_title}.md"

	# Scrapping via Gather
	# (options to mirror the output from Mercury Parser)
	output2=$(gather --inline-links --no-include-source --no-include-title "$URL" | sed 's/---?/–/g' | tr -s " ")

	# Quality Control
	# using word count instead of diff for performance
	count1=$(echo "$output1" | wc -w) # counting words instead of characters since less prone to variation due to whitespace or formatting style
	count2=$(echo "$output2" | wc -w)
	count_diff=$((count1 - count2))
	[[ $count_diff -lt 0 ]] && count_diff=$((count_diff * -1 )) # absolute value

	if [[ $count_diff -gt $TOLERANCE ]]; then
		echo "\033[1;33mDifference of $count_diff words"
		echo "${count_diff}w_diff;$URL" >> "$REPORT_FILE"
		FAILURE_COUNT=$((FAILURE_COUNT + 1))
		continue # don't write output if above the tolerance threshhold
	fi

	echo -n "\033[1;32m" # green
	if [[ $count_diff -eq 0 ]]; then
		echo -n "No Difference"
	elif [[ $count_diff -eq 1 ]]; then
		echo -n "Difference of 1 word."
	else
		echo -n "Difference of $count_diff words."
	fi
	echo "\033[0m → Article saved as '$file_name'"

	SUCCESS_COUNT=$((SUCCESS_COUNT + 1))

	# Cleaning & Saving Output
	content="$output1" # use content from Mercury Reader (doesn't matter much)
	echo "$frontmatter\n\n$content" > "$DESTINATION/$file_name"
done

#-------------------------------------------------------------------------------

# Summary
echo "\033[0m---"
echo "\033[1;32m$SUCCESS_COUNT\033[0m article(s) scrapped, \033[1;31m$FAILURE_COUNT\033[0m article(s) failed."
