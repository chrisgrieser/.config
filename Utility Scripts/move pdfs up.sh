#!/bin/zsh
# shellcheck disable=SC2164
# Reorganize PDFs by moving all pdfs one level up
# not usable anymore, but kept for documentation purposes

for folder in */*/; do
	cd "$folder"
	echo "$PWD"
	fd . --min-depth=2 | xargs -I {} mv {} . # move up when in author-folder
	rmdir ./*/ # remove all directories that are now empty
	cd ../..
done

# some directories contain hidden .DS_Store files, so have to be removed with this.
# glob "????" as a fail safe to only remove years
for folder in */*/; do
	cd "$folder"
	rm -rf ./????/
	cd ../..
done
