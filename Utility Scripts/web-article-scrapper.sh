#!/bin/zsh
# shellcheck disable=SC2028,SC2248

# input args / Config
URL="$1"
OUTPUT_FOLDER="$2"
[[ -z "$URL" ]] && exit 1
[[ -z "$OUTPUT_FOLDER" ]] && OUTPUT_FOLDER="."
TOLERANCE=20
MAX_TITLE_LENGTH=50
REPORT_FILE="$OUTPUT_FOLDER/report.log"

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
if ! command markdownlint &> /dev/null ; then
	echo "markdownlint not installed."
	echo "install: brew markdownlint-cli"
	exit 1
fi
if ! command gather &> /dev/null ; then
	echo "gather-cli not installed."
	echo "Install from here: https://github.com/ttscoff/gather-cli"
	echo "(brew tap requires 12gb Xcode install, so download the package instead…)"
	exit 1
fi

# Mercury Reader Version
parsed_data=$(mercury-parser "$URL")
echo "$parsed_data" | yq .content > temp.html

title=$(echo "$parsed_data" | yq .title)
safe_title=$(echo "$title" | tr "/:;.\\" "-----" | cut -c-$MAX_TITLE_LENGTH)
author=$(echo "$parsed_data" | yq .author)
date_published=$(echo "$parsed_data" | yq .date_published | cut -d"T" -f1)
excerpt=$(echo "$parsed_data" | yq .excerpt)
article_word_count=$(echo "$parsed_data" | yq .word_count)

frontmatter=$(echo "---" ; echo "title: $title" ; echo "author: $author" ; echo "date: $date_published" ; echo "excerpt: $excerpt" echo "word: $article_word_count" ; echo "source: $URL" ; echo "---" ; echo)
turndown-cli --head=2 --hr=2 --bullet=2 --code=2 temp.html &> /dev/null
output1=$(cat temp.md)
rm temp.html temp.md

# Gather Version
output2=$(gather --inline-links --no-include-source "$URL")

# Quality Control
if [[ ! -e "$REPORT_FILE" ]] ; then
	echo "Tolerance: $TOLERANCE Words Difference" > "$REPORT_FILE"
	echo "--------------------------------------" >> "$REPORT_FILE"
fi

count1=$(echo "$output1" | wc -w) # counting words instead of characters since less prone to variation due to whitespace or formatting style
count2=$(echo "$output2" | wc -w)
count_diff=$((count1 - count2))
[[ $count_diff -lt 0 ]] && count_diff=$((count_diff * -1 )) # absolute value

if [[ $count_diff -gt $TOLERANCE ]]; then
	echo "\033[1;33m Difference of $count_diff words"
	echo "$count_diff;$URL" >> "$REPORT_FILE"
	exit 0 # don't write output if over the tolerance level
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
content=$(echo "$output1"  | markdownlint --fix --quiet --stdin)
echo "$frontmatter\n$content" > "$OUTPUT_FOLDER/${safe_title}.md"
echo "✅ Article saved as '${safe_title}.md'"
