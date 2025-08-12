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

/**
 * @param {string} url
 * @param {string[]} header
 * @return {string} response
 */
function httpRequestWithHeaders(url, header) {
	let allHeaders = "";
	for (const line of header) {
		allHeaders += ` -H "${line}"`;
	}
	const curlRequest = `curl --silent --location ${allHeaders} "${url}" || true`;
	console.log("curl command:", curlRequest);
	return app.doShellScript(curlRequest);
}

/** @param {number} starcount */
function shortNumber(starcount) {
	const starStr = starcount.toString();
	if (starcount < 2000) return starStr;
	return starStr.slice(0, -3) + "k";
}

//──────────────────────────────────────────────────────────────────────────────

/** @type {AlfredRun} */
// biome-ignore lint/correctness/noUnusedVariables: Alfred run
function run() {
	// get GITHUB_TOKEN
	const tokenShellCmd = $.getenv("github_token_shell_cmd").trim();
	const tokenFromZshenvCmd = "test -e $HOME/.zshenv && source $HOME/.zshenv ; echo $GITHUB_TOKEN";
	let githubToken = $.getenv("github_token_from_alfred_prefs").trim();
	if (!githubToken && tokenShellCmd) githubToken = app.doShellScript(tokenShellCmd).trim();
	if (!githubToken) app.doShellScript(tokenFromZshenvCmd);

	// CONFIG
	const username = $.getenv("github_username");
	const localRepoFolder = $.getenv("local_repo_folder");
	const cloneDepth = Number.parseInt($.getenv("clone_depth"));
	const shallowClone = cloneDepth > 0;
	const useAlfredFrecency = $.getenv("use_alfred_frecency") === "1";

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

	// DOCS https://docs.github.com/en/rest/repos/repos?apiVersion=2022-11-28#list-repositories-for-a-user
	let apiUrl = `https://api.github.com/users/${username}/repos?type=all&per_page=100&sort=updated`;
	const headers = ["Accept: application/vnd.github.json", "X-GitHub-Api-Version: 2022-11-28"];
	if (githubToken) {
		// DOCS https://docs.github.com/en/rest/repos/repos?apiVersion=2022-11-28#list-repositories-for-the-authenticated-user--parameters
		apiUrl = "https://api.github.com/user/repos?per_page=100&sort=updated";
		headers.push(`Authorization: BEARER ${githubToken}`);
	}

	const response = httpRequestWithHeaders(apiUrl, headers);
	if (!response) {
		return JSON.stringify({
			items: [{ title: "No response from GitHub.", subtitle: "Try again later.", valid: false }],
		});
	}
	const parsedRepos = JSON.parse(response);
	console.log("Repo count:", parsedRepos.length);

	const repos = parsedRepos
		.filter((/** @type {GithubRepo} */ repo) => !repo.archived) // github API does now allow filtering when requesting
		.sort(
			(
				/** @type {GithubRepo&{isLocal: boolean}} */ a,
				/** @type {GithubRepo&{isLocal: boolean}} */ b,
			) => {
				a.isLocal = Boolean(localRepos[a.name]);
				b.isLocal = Boolean(localRepos[b.name]);
				if (a.isLocal && !b.isLocal) return -1;
				if (!a.isLocal && b.isLocal) return 1;
				return 0; // use sorting from GitHub (updated status)
			},
		)
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
			if (repo.private) type += "🔒 ";
			if (repo.private) matcher += "private ";
			if (repo.stargazers_count > 0) subtitle += `⭐ ${shortNumber(repo.stargazers_count)}  `;
			if (repo.open_issues > 0) subtitle += `🟢 ${repo.open_issues}  `;
			if (repo.forks_count > 0) subtitle += `🍴 ${repo.forks_count}  `;
			if (memberRepo) subtitle += `👤 ${repo.owner.login}  `;
			if (memberRepo) matcher += "member ";

			/** @type {AlfredItem} */
			const alfredItem = {
				title: `${type}${repo.name}`,
				subtitle: subtitle,
				match: matcher,
				arg: mainArg,
				quicklookurl: repo.private ? undefined : mainArg,
				uid: useAlfredFrecency ? repo.full_name : undefined,
				mods: {
					ctrl: { subtitle: "⌃: " + termAct, arg: terminalArg },
					alt: { subtitle: "⌥: Copy GitHub URL", arg: repo.html_url },
					cmd: { subtitle: "⌘: Open at GitHub", arg: repo.html_url },
				},
			};
			return alfredItem;
		});

	return JSON.stringify({
		items: repos,
		variables: { ownerOfRepo: "true" },
		cache: { seconds: 15, loosereload: true }, // short, since cloned repos should be available immediately
	});
}
