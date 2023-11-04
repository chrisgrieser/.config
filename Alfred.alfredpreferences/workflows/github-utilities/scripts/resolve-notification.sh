#!/usr/bin/env zsh

notification_url="$1"

# DOCS https://docs.github.com/en/rest/activity/notifications?apiVersion=2022-11-28#get-a-thread
url=$(curl -sL -H "Accept: application/vnd.github+json" \
	-H "Authorization: Bearer $GITHUB_TOKEN" \
	-H "X-GitHub-Api-Version: 2022-11-28" \
	"$notification_url" |
	grep "html_url.*" | head -n1 | cut -d '"' -f 4 # skip `jq` dependency
)

open "$url"
		# if (notif.subject.url) {
		# 	const idInRepo = notif.subject.url.match(/\d+$/);
		# 	const lastCommentId =
		# 		notif.subject.latest_comment_url && notif.subject.latest_comment_url !== notif.subject.url
		# 			? "#issuecomment-" + notif.subject.latest_comment_url.match(/\d+$/)
		# 			: "";
		# 	const type = notif.subject.type === "PullRequest" ? "pull" : "issues"; //codespell-ignore
		# 	url = `https://github.com/${notif.repository.full_name}/${type}/${idInRepo}${lastCommentId}`;
		# } else {
		# 	// discussions do not have a direct URL available :/
		# 	url = "https://github.com/notifications";
		# }
		#
