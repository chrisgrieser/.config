#!/usr/bin/env osascript -l JavaScript

ObjC.import("stdlib");
const app = Application.currentApplication();
app.includeStandardAdditions = true;

/** @param {string} str */
function alfredMatcher(str) {
	const clean = str.replace(/[-()_.:#/\\;,[\]]/g, " ");
	const camelCaseSeperated = str.replace(/([A-Z])/g, " $1");
	return [clean, camelCaseSeperated, str].join(" ") + " ";
}

//──────────────────────────────────────────────────────────────────────────────

const username = $.getenv("github_username");
const apiURL = `https://api.github.com/users/${username}/repos?per_page=100`;

//──────────────────────────────────────────────────────────────────────────────

/** @param {string[]} argv */
// rome-ignore lint/correctness/noUnusedVariables: Alfred run
function run(argv) {
	// local repos
	let localRepoLocation = argv[0];
	const obsiPlugins = $.getenv("extra_folder_1")
		? $.getenv("extra_folder_1").replace(/^~/, app.pathTo("home folder"))
		: "";
	localRepoLocation = `"${localRepoLocation}" "${obsiPlugins}"`;
	const localRepos = app
		.doShellScript(
			`export PATH=/usr/local/bin/:/opt/homebrew/bin/:$PATH
			fd '\\.git$' --no-ignore --hidden --max-depth=2 ${localRepoLocation}`,
		)
		.split("\r")
		.map((/** @type {string} */ gitFolderPath) => {
			const localRepo = {};
			localRepo.path = gitFolderPath.replace(/\.git\/?$/, "");
			localRepo.name = localRepo.path.replace(/.*\/(.*)\//, "$1");
			try {
				localRepo.dirty = app.doShellScript(`cd "${localRepo.path}" && git status --porcelain`) !== "";
			} catch (_error) {
				// error occurs when there have been iCloud sync issues with the repo
				localRepo.dirty = undefined;
			}
			return localRepo;
		});

	//───────────────────────────────────────────────────────────────────────────

	const jsonArray = JSON.parse(app.doShellScript(`curl -sL "${apiURL}"`))
		// add in local repo
		.map((repo) => {
			repo.name = repo.full_name.split("/")[1];
			if (repo.id)
		})
		// sort archived and forks to the bottom, then sort by stars
		.sort((a, b) => {
			if (a.fork && !b.fork) return 1;
			else if (!a.fork && b.fork) return -1;
			else if (a.archived && !b.archived) return 1;
			else if (!a.archived && b.archived) return -1;
			return b.stargazers_count - a.stargazers_count;
		})
		.map((repo) => {
			let name = repo.full_name.split("/")[1];
			if (name === username) name = "My GitHub Profile";

			let matcher = alfredMatcher(name);
			let subtitle = "";
			if (repo.archived) {
				subtitle += "🗄️ ";
				matcher += "archived ";
			}
			if (repo.fork) {
				subtitle += "🍴 ";
				matcher += "fork ";
			}
			if (repo.stargazers_count > 0) subtitle += `⭐ ${repo.stargazers_count}  `;
			if (repo.open_issues_count > 0) subtitle += `🟢 ${repo.open_issues_count}  `;
			if (repo.forks_count > 0) subtitle += `🍴 ${repo.forks_count}  `;

			return {
				title: name,
				subtitle: subtitle,
				match: matcher,
				arg: repo.html_url,
				mods: {
					shift: {
						subtitle: `⇧: Search Issues (${repo.open_issues} open)`,
						arg: repo.full_name,
					},
				},
			};
		});
	return JSON.stringify({ items: jsonArray });
}
