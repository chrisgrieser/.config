# 1. download docs as html
open "https://docs.python.org/download.html"

# 2. (manual) open zip & fetch `searchindex.js`

# 3. extract the json enclosed in `Search.setindex(…)`
sed -e 's/^Search.setIndex(//' -e 's/.$//' searchindex.js >searchindex.json

# 4. get only `indexentries` and `docnames` to reduce filesize by 50%
yq --inplace --input-format=json --output-format=json \
	'. |= pick(["indexentries", "docnames"])' searchindex.json

# 5. (manual) append python version name to the new json file

# TODO automate this process
