#!/bin/zsh
# shellcheck disable=SC2028,SC2248,SC2030,SC2031,SC2002

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
ERROR_LOG="$OUTPUT_FOLDER/errors.log"
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
echo "URL Parsing Failues" > "$ERROR_LOG"
echo "-------------------" >> "$ERROR_LOG"

#-------------------------------------------------------------------------------

PROGRESS_COUNT=0
SUCCESS_COUNT=0
ERROR_COUNT=0
WARNING_COUNT=0

# skip comments & empty lines
INPUT=$(cat "$INPUT_FILE" | grep -vE "^$" | grep -vE "^#")
LINE_COUNT=$(echo "$INPUT" | wc -l | tr -d " ")

echo "$INPUT" | while read -r line ; do
	URL="$line"
	PROGRESS_COUNT=$((PROGRESS_COUNT + 1))
	echo -n "\033[0m$PROGRESS_COUNT/$LINE_COUNT: "

	# Check whether URL is alive
	HTTP_CODE=$(curl -sI "$URL" | head -n1 | sed -E 's/[[:space:]]*$//g')
	if [[ "$HTTP_CODE" != "HTTP/2 200" ]]; then
		echo "\033[1;31mURL is dead: $HTTP_CODE\033[0m"
		echo "$HTTP_CODE;$URL" >> "$ERROR_LOG"
		ERROR_COUNT=$((ERROR_COUNT + 1))
		continue
	fi

	# Scrapping via Mercury Reader
	parsed_data=$(mercury-parser "$URL")
	echo "$parsed_data" | yq .content > temp.html
	turndown-cli --head=2 --hr=2 --bullet=2 --code=2 temp.html &> /dev/null
	# shellcheck disable=SC1111
	output_mercury=$(tr "’“”" "'\"\"" < temp.md | sed 's/\\\. /. /g' | tr -s " ")
	# rm temp.html temp.md

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
	output_gather=$(gather --inline-links --no-include-source --no-include-title "$URL" | sed 's/---?/–/g' | tr -s " ")

	# Quality Control
	# (using word count instead of diff for performance)
	count_mercury=$(echo "$output_mercury" | wc -w) # counting words instead of characters since less prone to variation due to whitespace or formatting style
	count_gather=$(echo "$output_gather" | wc -w)
	count_diff=$((count_mercury - count_gather))
	[[ $count_diff -lt 0 ]] && count_diff=$((count_diff * -1 )) # absolute value

	if [[ $count_diff -gt $TOLERANCE ]]; then
		echo -n "\033[1;33mDifference of $count_diff words"
		WARNING_COUNT=$((WARNING_COUNT + 1))
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
	fi
	echo "\033[0m → '$file_name'"

	# Saving Output
	# (use content from the parser which seems to get more content)
	# for using OSX sed to insert lines: https://stackoverflow.com/a/25632073
	if [[ $count_gather -gt $count_mercury ]]; then
		content="$output_mercury"
		frontmatter=$(echo "$frontmatter" | sed '6i\
		              parser: Mercury')
	else
		content="$output_gather"
		frontmatter=$(echo "$frontmatter" | sed '6i\
		              parser: Gather')
	fi

	if [[ $count_diff -gt $TOLERANCE ]]; then
		frontmatter=$(echo "$frontmatter" | sed "7i\\
		              parser-diff: $count_diff words")
	else
		frontmatter=$(echo "$frontmatter" | sed '7i\
		              parser-diff: ok')
	fi

	echo "$frontmatter\n\n$content" > "$DESTINATION/$file_name"
done

#-------------------------------------------------------------------------------

# Summary
echo "\033[0m---"
echo "\033[1;32m$SUCCESS_COUNT\033[0m articles scrapped"
echo "\033[1;33m$WARNING_COUNT\033[0m articles with significant parser difference"
echo "\033[1;31m$ERROR_COUNT\033[0m articles failed"
