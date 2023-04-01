#!/usr/bin/env zsh

# INPUT
echo "Paste GitHub URL"
read -r github_url

echo "Enter tag for neovimcraft (Check tags at: https://neovimcraft.com/)"
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
	gh pr create --fill # --fill = use commit ino

	# open in web just to check
	gh pr view --web
}

function shallow_fork() {
	repo="$1"
	name=$(echo "$repo" | cut -d/ -f2)
	origin=$(git remote -v | grep origin | head -n1 | cut -d/ -f4- | cut -d. -f1)
	gh repo set-default "$origin"
	gh repo fork "$repo" --clone=false # separate clone command for shallow clone
	gh repo clone "$github_user/$name" -- --depth=1
	cd "./$name"
}

repo=$(echo "$github_url" | cut -d/ -f4-)
plugin_name=$(echo "$repo" | cut -d/ -f2)
github_user=$(echo "$repo" | cut -d/ -f1)
plugin_desc=$(curl -sL "https://api.github.com/repos/$repo" | grep "description" | head -n1 | cut -d'"' -f4)

#───────────────────────────────────────────────────────────────────────────────
# NEOVIMCRAFT
cd "$TEMP_DIR"
shallow_fork "neurosnap/neovimcraft"

# to avoid the installation of `deno` and the interactive `make resource`,
# enter the new plugin data automatically
target="data/manual.json"
to_add="},
    {
      \"type\": \"github\",
      \"username\": \"$github_user\",
      \"repo\": \"$plugin_name\",
      \"tags\": [
        \"plugin\",
        \"$tag\",
      ]
    }
  ]
}"

sed -i '' "$ d" "$target"
sed -i '' "$ d" "$target"
sed -i '' "$ d" "$target"
echo -n "$to_add" >>"$target"

commit_push_pr_view "Add $plugin_name"
echo "------------------------------------------------------------"

#───────────────────────────────────────────────────────────────────────────────
# AWESOME NEOVIM

cd "$TEMP_DIR"
shallow_fork "rockerBOO/awesome-neovim"

line_to_add="[$plugin_name]($github_url) – $plugin_desc"
echo "$line_to_add | pbcopy"
nvim "./README.md"

commit_push_pr_view "Add \`$repo\`"
echo "------------------------------------------------------------"

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
