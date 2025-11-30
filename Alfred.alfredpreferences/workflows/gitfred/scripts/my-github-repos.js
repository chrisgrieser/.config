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
	console.log(curlRequest);
	return app.doShellScript(curlRequest);
}

/** @param {number} starcount */
function shortNumber(starcount) {
	const starStr = starcount.toString();
	if (starcount < 2000) return starStr;
	return starStr.slice(0, -3) + "k";
}

function getGithubToken() {
	const tokenShellCmd = $.getenv("github_token_shell_cmd");
	const tokenFromZshenvCmd = "test -e $HOME/.zshenv && source $HOME/.zshenv ; echo $GITHUB_TOKEN";
	let githubToken = $.getenv("github_token_from_alfred_prefs").trim();
	if (!githubToken && tokenShellCmd) {
		githubToken = app.doShellScript(tokenShellCmd + " || true").trim();
		if (!githubToken) console.log("GitHub token shell command failed.");
	}
	if (!githubToken) githubToken = app.doShellScript(tokenFromZshenvCmd);
	return githubToken;
}

//──────────────────────────────────────────────────────────────────────────────

/** @type {AlfredRun} */
// biome-ignore lint/correctness/noUnusedVariables: Alfred run
function run() {
	const githubToken = getGithubToken();
	const includePrivate = $.getenv("include_private_repos") === "1";
	const username = $.getenv("github_username");
	const localRepoFolder = $.getenv("local_repo_folder");
	const cloneDepth = Number.parseInt($.getenv("clone_depth"));
	const shallowClone = cloneDepth > 0;
	const useAlfredFrecency = $.getenv("use_alfred_frecency") === "1";
	const only100repos = $.getenv("only_100_recent_repos") === "1";

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
	if (githubToken && includePrivate) {
		// DOCS https://docs.github.com/en/rest/repos/repos?apiVersion=2022-11-28#list-repositories-for-the-authenticated-user--parameters
		apiUrl = "https://api.github.com/user/repos?per_page=100&sort=updated";
		headers.push(`Authorization: BEARER ${githubToken}`);
	}

	// Paginate through all repos
	/** @type {GithubRepo[]} */
	const allRepos = [];
	let page = 1;
	while (true) {
		const response = httpRequestWithHeaders(apiUrl + `&page=${page}`, headers);
		if (!response) {
			const item = { title: "No response from GitHub. Try again later.", valid: false };
			return JSON.stringify({ items: [item] });
		}
		const reposOfPage = JSON.parse(response);
		console.log(`repos page #${page}: ${reposOfPage.length}`);
		allRepos.push(...reposOfPage);
		page++;
		if (only100repos) break; // PERF only one request when user enabled this
		if (reposOfPage.length < 100) break; // GitHub returns less than 100 when on last page
	}

	// Create items for Alfred
	const repos = allRepos
		.filter((repo) => !repo.archived) // GitHub API doesn't allow filtering
		.sort((a, b) => {
			// sort local repos to the top
			const aIsLocal = Boolean(localRepos[a.name]);
			const bIsLocal = Boolean(localRepos[b.name]);
			if (aIsLocal && !bIsLocal) return -1;
			if (!aIsLocal && bIsLocal) return 1;
			return 0; // otherwise use sorting from GitHub (updated status)
		})
		.map((repo) => {
			let matcher = repo.name;
			let type = "";
			let subtitle = "";
			const localRepo = localRepos[repo.name];
			const memberRepo = repo.owner.login !== username;
			const mainArg = localRepo?.path || repo.html_url;

			// open in terminal when local, clone when not
			let termAct = "Open in Terminal";
			if (!localRepo) termAct = shallowClone ? `Shallow Clone (depth ${cloneDepth})` : "Clone";
			const terminalArg = localRepo?.path || repo.html_url;
			if (localRepo) {
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
			if (memberRepo) matcher += "member " + repo.owner.login + " ";

			/** @type {AlfredItem} */
			const alfredItem = {
				title: `${type}${repo.name}`,
				subtitle: subtitle,
				match: alfredMatcher(matcher),
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
		// short, since cloned repos should be available immediately
		cache: { seconds: 15, loosereload: true },
	});
}
