#!/bin/zsh
# shellcheck disable=SC2028,SC2248

# input args / Config
INPUT_FILE="$1"
OUTPUT_FOLDER="$2"
[[ -z "$URL" ]] && exit 1
[[ -z "$OUTPUT_FOLDER" ]] && OUTPUT_FOLDER="."
TOLERANCE=15 # number of words treshhold
MAX_TITLE_LENGTH=45
REPORT_FILE="$OUTPUT_FOLDER/report.csv"
DESTINATION="$OUTPUT_FOLDER/files/"

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

LINES=$(cat "$INPUT_FILE")
for  line in $LINES ; do
	# skip comments & empty lines
	if [[ -z "$line" ]] || [[ "$line" == \#* ]] ; then
		continue
	fi

	# Check whether URL is alive
	HTTP_CODE=$(curl -sI "$URL" | head -n1 | sed -E 's/[[:space:]]*$//g')
	if [[ "$HTTP_CODE" != "HTTP/2 200" ]]; then
		echo "\033[1;31mURL is dead: $HTTP_CODE\033[0m"
		echo "$HTTP_CODE;$URL" >> "$REPORT_FILE"
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
		echo "\033[1;33m Difference of $count_diff words"
		echo "${count_diff}w_diff;$URL" >> "$REPORT_FILE"
		continue # don't write output if above the tolerance threshhold
	fi

	if [[ $count_diff -eq 0 ]]; then
		echo "\033[1;32mNo Difference."
	elif [[ $count_diff -eq 1 ]]; then
		echo "\033[1;32mDifference of 1 word."
	else
		echo "\033[1;32mDifference of $count_diff words."
	fi
	echo -n "\033[0m" # reset coloring

	# Cleaning & Saving Output
	content="$output1" # use content from Mercury Reader (doesn't matter much)
	echo "$frontmatter\n\n$content" > "$DESTINATION/$file_name"
	echo "✅ Article saved as '$file_name'"
done


