#!/usr/bin/env osascript -l JavaScript

ObjC.import("stdlib");
const app = Application.currentApplication();
app.includeStandardAdditions = true;

/** @param {string} str */
function alfredMatcher(str) {
	const clean = str.replace(/[-_.]/g, " ");
	const camelCaseSeperated = str.replace(/([A-Z])/g, " $1");
	return [clean, camelCaseSeperated, str].join(" ") + " ";
}

/** @param {string} url */
function httpRequest(url) {
	const queryURL = $.NSURL.URLWithString(url);
	const requestData = $.NSData.dataWithContentsOfURL(queryURL);
	const requestString = $.NSString.alloc.initWithDataEncoding(requestData, $.NSUTF8StringEncoding).js;
	return requestString;
}

//──────────────────────────────────────────────────────────────────────────────

const username = $.getenv("github_username");
const apiURL = `https://api.github.com/users/${username}/repos?per_page=100`;

//──────────────────────────────────────────────────────────────────────────────

/** @param {string[]} argv */
// rome-ignore lint/correctness/noUnusedVariables: Alfred run
function run(argv) {
	// local repos
	const repoFolder = argv[0]; // local repo path passed from .zshenv
	const obsiPlugins = $.getenv("extra_folder_1").replace(/^~/, app.pathTo("home folder"));
	const locations = `"${repoFolder}" "${obsiPlugins}"`;
	console.log("locations:", locations);

	const localRepos = {};
	app
		.doShellScript(`find ${locations} -type d -maxdepth 2 -name ".git"`)
		.split("\r")
		.forEach((/** @type {string} */ gitFolderPath) => {
			const localRepo = {};
			localRepo.path = gitFolderPath.replace(/\.git\/?$/, "");
			const name = localRepo.path.replace(/.*\/(.*)\/$/, "$1");
			try {
				localRepo.dirty = app.doShellScript(`cd "${localRepo.path}" && git status --porcelain`) !== "";
			} catch (_error) {
				// error occurs with iCloud sync issues
				localRepo.dirty = undefined;
			}
			localRepos[name] = localRepo;
		});

	//───────────────────────────────────────────────────────────────────────────
	// fetch remote repos

	const scriptFilterArr = JSON.parse(httpRequest(apiURL))
		// sort local to the top, archived and forks to the bottom, then by stars
		.sort(
			(
				/** @type {{ isLocal: any; name: string | number; fork: any; archived: any; stargazers_count: number; }} */ a,
				/** @type {{ isLocal: any; name: string | number; fork: any; archived: any; stargazers_count: number; }} */ b,
			) => {
				a.isLocal = localRepos[a.name];
				b.isLocal = localRepos[b.name];
				if (a.isLocal && !b.isLocal) return -1;
				else if (!a.isLocal && b.isLocal) return 1;
				else if (a.fork && !b.fork) return 1;
				else if (!a.fork && b.fork) return -1;
				else if (a.archived && !b.archived) return 1;
				else if (!a.archived && b.archived) return -1;
				return b.stargazers_count - a.stargazers_count;
			},
		)
		.map(
			(
				/** @type {{ name: string; local: { path: any; }; html_url: any; archived: any; fork: any; is_template: any; stargazers_count: number; open_issues_count: number; forks_count: number; open_issues: number; full_name: any; }} */ repo,
			) => {
				let matcher = alfredMatcher(repo.name);
				let type = "";

				// additions when repo is local
				repo.local = localRepos[repo.name];
				const mainArg = repo.local?.path || repo.html_url;
				const terminalActionDesc = repo.local ? "Open in Terminal" : "Shallow Clone to Local Repo Folder";
				const terminalArg = repo.local?.path || repo.html_url; // open in terminal when local, clone when not
				if (repo.local) {
					if (localRepos[repo.name].dirty) type += "🔄 ";
					type += "📂 ";
					matcher += "local ";
				}

				// extra info
				if (repo.archived) {
					type += "🗄️ ";
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
				let subtitle = "";
				if (repo.stargazers_count > 0) subtitle += `⭐ ${repo.stargazers_count}  `;
				if (repo.open_issues_count > 0) subtitle += `🟢 ${repo.open_issues_count}  `;
				if (repo.forks_count > 0) subtitle += `🍴 ${repo.forks_count}  `;
				if (repo.name === username) {
					repo.name = "My GitHub Profile";
					matcher += "my github profile ";
				}

				return {
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
			},
		);
	return JSON.stringify({ items: scriptFilterArr });
}
