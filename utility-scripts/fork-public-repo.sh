#!/usr/bin/env zsh

# INPUT
echo "Enter Repo (format: owner/name)"
read -r REPO

echo "Enter tag for neovimcraft"
read -r tag

TEMP_DIR="$WD"

#───────────────────────────────────────────────────────────────────────────────
# PREPARATION
export PATH=/usr/local/lib:/usr/local/bin:/opt/homebrew/bin/:$PATH
if ! command -v gh &>/dev/null; then echo "⚠️ gh not installed." && return 1; fi
set -e # abort if any step fails

function commit_push_pr_view() {
	local msg="$1"
	git add .
	git commit -m "$msg"
	git push
	gh pr create --fill # --fill = use commit ino
	gh pr view
}

plugin_name=$(echo "$REPO" | cut -d/ -f2)
github_user=$(echo "$REPO" | cut -d/ -f1)
github_link="https://github.com/$REPO"

# desc can be inferred from github description (not using jq for portability)
plugin_desc=$(curl -sL "https://api.github.com/repos/$REPO" | grep "description" | head -n1 | cut -d'"' -f4)

#───────────────────────────────────────────────────────────────────────────────
# NEOVIMCRAFT
cd "$TEMP_DIR"
gh repo fork "neurosnap/neovimcraft" --clone=false # separate clone command for shallow clone
gh repo clone "$github_user/neovimcraft" -- --depth=1
cd "neovimcraft"

# TODO add to json manually (skip annoying deno installation) 
# https://github.com/neurosnap/neovimcraft/pull/290/files
to_add="},
    {
      \"type\": \"github\",
      \"username\": \"$github_user\",
      \"repo\": \"$plugin_name\",
      \"tags\": [
        \"plugin\",
        \"$tag\",
      ]"



commit_push_pr_view "Add $plugin_name"

#───────────────────────────────────────────────────────────────────────────────
# AWESOME NEOVIM

cd "$TEMP_DIR"
gh repo fork "rockerBOO/awesome-neovim" --clone=false 
gh repo clone "$plugin_name/awesome-neovim" -- --depth=1
cd "awesome-neovim"

line_to_add="[$plugin_name]($github_link) – $plugin_desc"
echo "$line_to_add | pbcopy"

# TODO Add to markdown
commit_push_pr_view "Add \`$REPO\`"

#───────────────────────────────────────────────────────────────────────────────
# THIS WEEK IN NEOVIM

cd "$TEMP_DIR"

gh repo fork "phaazon/this-week-in-neovim-contents" --clone=false 
gh repo clone "$plugin_name/this-week-in-neovim-contents" -- --depth=1
# INFO needs to switch to most recent branch :S

commit_push_pr_view "Add $plugin_name"

#───────────────────────────────────────────────────────────────────────────────
# FINISH
cd "$TEMP_DIR"
rm -r "neovimcraft"
rm -r "awesome-neovim"
rm -r "this-week-in-neovim-contents"

# open in reddit
echo "Done. Now Opening Reddit…"
sleep 0.1
echo "$plugin_desc" | pbcopy
open "https://www.reddit.com/r/neovim/submit?title=Introducing%3A$plugin_name"

