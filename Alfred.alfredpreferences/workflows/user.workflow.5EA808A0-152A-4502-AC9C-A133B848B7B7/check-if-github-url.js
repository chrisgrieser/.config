#!/usr/bin/env osascript -l JavaScript

function run(argv) {
	const url = argv[0];

	// check if repo-url and truncate non-repo part
	const githubURL = url.match(/^https?:\/\/github\.com\/[\w-]+\/[\w-]+/);
	if (!githubURL) return "Not a GitHub Repo.";
	return url;
}
