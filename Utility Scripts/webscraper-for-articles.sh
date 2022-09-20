#!/bin/zsh
# shellcheck disable=SC2028,SC2248,SC2030,SC2031,SC2002

#-------------------------------------------------------------------------------

# check presence of dependencies
if ! command mercury-parser &> /dev/null; then
	echo "mercury-parser not installed."
	echo "install: npm -g install @postlight/mercury-parser"
fi
if ! command turndown-cli &> /dev/null; then
	echo "turndown-cli not installed."
	echo "install: npm -g install turndown-cli"
fi
if ! command yq &> /dev/null; then
	echo "yq not installed."
	echo "install: brew install yq"
fi
if ! command gather &> /dev/null; then
	echo "gather-cli not installed."
	echo "Install from here: https://github.com/ttscoff/gather-cli"
	echo "(brew-tap requires 12gb Xcode install, so download the package instead…)"
fi
if ! command readable &> /dev/null; then
	echo "readability-cli not installed."
	echo "install: npm install -g readability-cli"
fi
if ! command readable &> /dev/null || ! command mercury-parser &> /dev/null || ! command turndown-cli &> /dev/null || ! command yq &> /dev/null || ! command gather &> /dev/null; then
	exit 1
fi

# Report file
echo "REPORT" > "$REPORT_FILE"
echo "-------------------" >> "$REPORT_FILE"

#-------------------------------------------------------------------------------

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

PROGRESS_COUNT=0
SUCCESS_COUNT=0
ERROR_COUNT=0
WARNING_COUNT=0

# GREP ONLY URLS
INPUT=$(cat "$INPUT_FILE" | grep -Eo "https?://[a-zA-Z0-9./?=_%:-]*")
LINE_COUNT=$(echo "$INPUT" | wc -l | tr -d " ")

echo "$INPUT" | while read -r line ; do
	URL="$line"
	PROGRESS_COUNT=$((PROGRESS_COUNT + 1))
	echo -n "\033[0m$PROGRESS_COUNT/$LINE_COUNT: "

	# CHECK WHETHER URL IS ALIVE
	HTTP_CODE=$(curl -sI "$URL" | head -n1 | sed -E 's/[[:space:]]*$//g')
	if [[ "$HTTP_CODE" != "HTTP/2 200" ]]; then
		echo "\033[1;31mURL is dead: $HTTP_CODE\033[0m"
		echo "🟥;$HTTP_CODE;;;$URL" >> "$REPORT_FILE"
		ERROR_COUNT=$((ERROR_COUNT + 1))
		continue
	fi

	# SCRAPPING VIA GATHER
	# (options to mirror the output from Mercury Parser)
	output_gather=$(gather --inline-links --no-include-source --no-include-title "$URL" | sed 's/---?/–/g' | tr -s " ")

	# SCRAPPING VIA READABILITY-CLI
	readable --quite "$URL" | tr -s " " > temp.html
	turndown-cli --head=2 --hr=2 --bullet=2 --code=2 temp.html &> /dev/null
	output_readable=$(tr -s " "  < temp.md)

	# SCRAPPING VIA MERCURY READER
	parsed_data=$(mercury-parser "$URL")
	echo "$parsed_data" | yq .content > temp.html
	turndown-cli --head=2 --hr=2 --bullet=2 --code=2 temp.html &> /dev/null
	# shellcheck disable=SC1111
	output_mercury=$(tr "’“”" "'\"\"" < temp.md | sed 's/\\\. /. /g' | tr -s " ")
	rm temp.html temp.md

	# METADATA VIA MERCURY READER
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

	# QUALITY CONTROL
	# (using word count instead of diff for performance)
	count_mercury=$(echo "$output_mercury" | wc -w) # counting words instead of characters since less prone to variation due to whitespace or formatting style
	count_gather=$(echo "$output_gather" | wc -w)
	count_readable=$(echo "$output_readable" | wc -w)

	if [[ $count_gather -gt $count_readable ]] && [[ $count_gather -gt $count_mercury ]] ; then
		highest_count=$count_gather
	elif [[ $count_readable -gt $count_mercury ]] ; then
		highest_count=$count_readable
	else
		highest_count=$count_mercury
	fi
	if [[ $count_gather -lt $count_readable ]] && [[ $count_gather -lt $count_mercury ]] ; then
		lowest_count=$count_gather
	elif [[ $count_readable -lt $count_mercury ]] ; then
		lowest_count=$count_readable
	else
		lowest_count=$count_mercury
	fi
	count_diff=$((highest_count - lowest_count))

	if [[ $count_diff -gt $TOLERANCE ]]; then
		echo -n "\033[1;33mDifference of $count_diff words"
		WARNING_COUNT=$((WARNING_COUNT + 1))
		echo "🟨;Mercury: $count_mercury;Gather: $count_gather;Readable: $count_readable;$URL" >> "$REPORT_FILE"
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
		echo "🟩;Mercury: $count_mercury;Gather: $count_gather;Readable: $count_readable;$URL" >> "$REPORT_FILE"
	fi
	echo "\033[0m → '$file_name'"

	# SAVING OUTPUT
	# (use content from the parser which seems to get more content)
	# for using OSX sed to insert lines: https://stackoverflow.com/a/25632073
	# shellcheck disable=SC2086
	if [[ $count_gather -gt $count_readable ]] && [[ $count_gather -gt $count_mercury ]] ; then
		content="$output_gather"
		frontmatter=$(echo "$frontmatter" | sed '6i\
		              parser: Gather')
	elif [[ $count_readable -gt $count_mercury ]] ; then
		content="$output_readable"
		frontmatter=$(echo "$frontmatter" | sed '6i\
		              parser: Readability')
	else
		content="$output_mercury"
		frontmatter=$(echo "$frontmatter" | sed '6i\
		              parser: Mercury')
	fi

	echo "$frontmatter\n\n$content" > "$DESTINATION/$file_name"
done

#-------------------------------------------------------------------------------

# SUMMARY
echo "\033[0m---"
echo "\033[1;32m$SUCCESS_COUNT\033[0m articles scrapped"
echo "\033[1;33m$WARNING_COUNT\033[0m articles with significant parser difference"
echo "\033[1;31m$ERROR_COUNT\033[0m articles failed"
