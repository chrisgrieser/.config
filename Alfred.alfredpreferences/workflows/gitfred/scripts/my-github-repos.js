#!/usr/bin/env osascript -l JavaScript
ObjC.import("stdlib");
const app = Application.currentApplication();
app.includeStandardAdditions = true;
//──────────────────────────────────────────────────────────────────────────────

/** @param {string} str */
function alfredMatcher(str) {
	const clean = str.replace(/[-_.]/g, " ");
	const camelCaseSeparated = str.replace(/([A-Z])/g, " $1");
	return [clean, camelCaseSeparated, str].join(" ") + " ";
}

/** @param {string} url */
function httpRequest(url) {
	const queryURL = $.NSURL.URLWithString(url);
	const requestData = $.NSData.dataWithContentsOfURL(queryURL);
	const requestString = $.NSString.alloc.initWithDataEncoding(requestData, $.NSUTF8StringEncoding).js;
	return requestString;
}

//──────────────────────────────────────────────────────────────────────────────

/** @type {AlfredRun} */
// biome-ignore lint/correctness/noUnusedVariables: Alfred run
function run() {
	// CONFIG
	const username = $.getenv("github_username");
	const localRepoFolder = $.getenv("local_repo_folder");
	const includeArchived = false;

	// determine local repos
	const localRepos = {};
	app.doShellScript(`mkdir -p "${localRepoFolder}"`);
	const localRepoPaths = app
		.doShellScript(`find ${localRepoFolder} -type d -maxdepth 2 -name ".git"`)
		.split("\r");
	for (const gitFolderPath of localRepoPaths) {
		const repo = {};
		repo.path = gitFolderPath.replace(/\.git\/?$/, "");
		const name = repo.path.replace(/.*\/(.*)\/$/, "$1");
		try {
			repo.dirty = app.doShellScript(`cd "${repo.path}" && git status --porcelain`) !== "";
		} catch (_error) {
			// error can occur with cloud sync issues
			repo.dirty = undefined;
		}
		localRepos[name] = repo;
	}

	//───────────────────────────────────────────────────────────────────────────
	// FETCH REMOTE REPOS

	// DOCS https://docs.github.com/en/free-pro-team@latest/rest/repos/repos?apiVersion=2022-11-28#list-repositories-for-a-user
	const apiURL = `https://api.github.com/users/${username}/repos?per_page=100`;
	const scriptFilterArr = JSON.parse(httpRequest(apiURL))
		.filter((/** @type {GithubRepo} */ repo) => includeArchived || !repo.archived)
		.sort(
			(
				/** @type {GithubRepo&{isLocal: boolean}} */ a,
				/** @type {GithubRepo&{isLocal: boolean}} */ b,
			) => {
				a.isLocal = localRepos[a.name];
				b.isLocal = localRepos[b.name];
				if (a.isLocal && !b.isLocal) return -1;
				if (!a.isLocal && b.isLocal) return 1;

				if (a.fork && !b.fork) return 1;
				if (!a.fork && b.fork) return -1;

				if (a.archived && !b.archived) return 1;
				if (!a.archived && b.archived) return -1;
				return b.stargazers_count - a.stargazers_count;
			},
		)
		.map((/** @type {GithubRepo&{local: {path: string}}} */ repo) => {
			let matcher = alfredMatcher(repo.name);
			let type = "";

			// changes when repo is local
			repo.local = localRepos[repo.name];
			const mainArg = repo.local?.path || repo.html_url;
			const terminalActionDesc = repo.local
				? "Open in Terminal"
				: "Shallow Clone"
			// open in terminal when local, clone when not
			const terminalArg = repo.local?.path || repo.html_url;
			if (repo.local) {
				if (localRepos[repo.name].dirty) type += "✴️ ";
				type += "📂 ";
				matcher += "local ";
			}

			// extra info
			if (repo.archived) {
				type += "🗄 ";
				matcher += "archived ";
			}
			if (repo.fork) {
				type += "🍴 ";
				matcher += "fork ";
			}
			if (repo.is_template) {
				type += "📄 ";
				matcher += "template ";
			}
			if (repo.private) {
				type += "🔒 ";
				matcher += "private ";
			}
			let subtitle = "";
			if (repo.stargazers_count > 0) subtitle += `⭐ ${repo.stargazers_count}  `;
			if (repo.open_issues > 0) subtitle += `🟢 ${repo.open_issues}  `;
			if (repo.forks_count > 0) subtitle += `🍴 ${repo.forks_count}  `;

			/** @type {AlfredItem} */
			const alfredItem = {
				title: `${type}${repo.name}`,
				subtitle: subtitle,
				match: matcher,
				arg: mainArg,
				mods: {
					fn: {
						subtitle: "fn: Delete Local Repo",
						valid: Boolean(repo.local),
					},
					ctrl: {
						subtitle: `⌃: ${terminalActionDesc}`,
						arg: terminalArg,
					},
					alt: {
						subtitle: "⌥: Copy GitHub URL",
						arg: repo.html_url,
					},
					cmd: {
						subtitle: "⌘: Open at GitHub",
						arg: repo.html_url,
					},
					shift: {
						subtitle: `⇧: Search Issues (${repo.open_issues} open)`,
						arg: repo.full_name,
						valid: repo.open_issues > 0,
					},
				},
			};
			return alfredItem;
		});

	return JSON.stringify({
		items: scriptFilterArr,
		variables: { ownerOfRepo: "1" },
	});
}
