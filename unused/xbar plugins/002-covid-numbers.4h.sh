#!/bin/zsh
export PATH=/usr/local/bin/:/opt/homebrew/bin/:$PATH

API_NUMBERS=$(curl -sL "https://api.corona-zahlen.org/germany")
INZ=$(echo "$API_NUMBERS" | jq .weekIncidence | cut -d "." -f1)
R=$(echo "$API_NUMBERS" | jq .r.rValue7Days.value)

echo "🦠 $INZ ($R)"
echo "---"
echo "7-Tage-Inz. (R)"

