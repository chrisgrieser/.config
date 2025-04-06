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
	const requestStr = $.NSString.alloc.initWithDataEncoding(requestData, $.NSUTF8StringEncoding).js;
	return requestStr;
}

//──────────────────────────────────────────────────────────────────────────────

/** @type {AlfredRun} */
// biome-ignore lint/correctness/noUnusedVariables: Alfred run
function run() {
	// CONFIG
	const username = $.getenv("github_username");
	const localRepoFolder = $.getenv("local_repo_folder");
	const cloneDepth = Number.parseInt($.getenv("clone_depth"));
	const shallowClone = cloneDepth > 0;

	// determine local repos
	/** @type {Record<string, {path: string; dirty: boolean|undefined}>} */
	const localRepos = {};
	app.doShellScript(`mkdir -p "${localRepoFolder}"`);
	const localRepoPaths = app
		.doShellScript(`find ${localRepoFolder} -type d -maxdepth 2 -name ".git"`)
		.split("\r");

	for (const gitFolderPath of localRepoPaths) {
		/** @type {{path: string; dirty: boolean|undefined}} */
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
	// `type=all` includes owned repos and member repos
	const response = httpRequest(`https://api.github.com/users/${username}/repos?type=all&per_page=100`);
	if (!response) {
		return JSON.stringify({
			items: [{ title: "No response from GitHub.", subtitle: "Try again later.", valid: false }],
		});
	}

	const scriptFilterArr = JSON.parse(response)
		.filter((/** @type {GithubRepo} */ repo) => !repo.archived)
		.sort(
			(
				/** @type {GithubRepo&{isLocal: boolean}} */ a,
				/** @type {GithubRepo&{isLocal: boolean}} */ b,
			) => {
				a.isLocal = Boolean(localRepos[a.name]);
				b.isLocal = Boolean(localRepos[b.name]);
				if (a.isLocal && !b.isLocal) return -1;
				if (!a.isLocal && b.isLocal) return 1;
				if (a.fork && !b.fork) return 1;
				if (!a.fork && b.fork) return -1;
				return b.stargazers_count - a.stargazers_count;
			},
		)
		// biome-ignore lint/complexity/noExcessiveCognitiveComplexity: fine here
		.map((/** @type {GithubRepo&{local: {path: string}|undefined}} */ repo) => {
			let matcher = alfredMatcher(repo.name);
			let type = "";
			let subtitle = "";
			repo.local = localRepos[repo.name];
			const memberRepo = repo.owner.login !== username;
			const mainArg = repo.local?.path || repo.html_url;

			// open in terminal when local, clone when not
			let termAct = "Open in Terminal";
			if (!repo.local) termAct = shallowClone ? `Shallow Clone (depth ${cloneDepth})` : "Clone";
			const terminalArg = repo.local?.path || repo.html_url;
			if (repo.local) {
				if (localRepos[repo.name]?.dirty) type += "✴️ ";
				type += "📂 ";
				matcher += "local ";
			}


			// extra info
			if (repo.fork) type += "🍴 ";
			if (repo.fork) matcher += "fork ";
			if (repo.is_template) type += "📄 ";
			if (repo.is_template) matcher += "template ";
			if (repo.stargazers_count > 0) subtitle += `⭐ ${repo.stargazers_count}  `;
			if (repo.open_issues > 0) subtitle += `🟢 ${repo.open_issues}  `;
			if (repo.forks_count > 0) subtitle += `🍴 ${repo.forks_count}  `;
			if (memberRepo) subtitle += `👤 ${repo.owner.login}  `;
			if (memberRepo) matcher += "member ";

			/** @type {AlfredItem} */
			const alfredItem = {
				title: `${type}${displayName}`,
				subtitle: subtitle,
				match: matcher,
				arg: mainArg,
				quicklookurl: mainArg,
				uid: repo.name,
				mods: {
					ctrl: {
						subtitle: "⌃: " + termAct,
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
						arg: "", // empty for next input
						variables: { repo: repo.full_name },
					},
				},
			};
			return alfredItem;
		});

	return JSON.stringify({
		items: scriptFilterArr,
		variables: { ownerOfRepo: "true" },
		cache: {
			seconds: 15, // short, since cloned repos should be available immediately
			loosereload: true,
		},
	});
}
