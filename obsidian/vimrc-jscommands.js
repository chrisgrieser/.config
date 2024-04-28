// DOCS https://github.com/esm7/obsidian-vimrc-support/blob/master/JsSnippets.md
//──────────────────────────────────────────────────────────────────────────────

/** @param {string} key @param {boolean|string|number} value */
function addYamlKey(key, value) {
	const lines = editor.getValue().split("\n");
	const frontmatterEnd = lines.slice(1).findIndex((line) => line === "---") + 1;
	if (frontmatterEnd === 0) {
		new Notice("No frontmatter found.");
		return;
	}

	const stringifiedValue = typeof value === "string" ? `"${value}"` : value.toString();
	const yamlLine = key + ": " + stringifiedValue;

	const keyLnum = lines
		.slice(0, frontmatterEnd + 1) // only check frontmatter
		.findIndex((line) => line.startsWith(key + ":"));
	let msg;
	if (keyLnum === -1) {
		// insert at frontmatter
		lines.splice(frontmatterEnd, 0, yamlLine); 
		msg = `Added property "${key}" with value "${value}"`;
	} else {
		// update existing key
		lines[keyLnum] = yamlLine; 
		msg = `Set property "${key}" to "${value}"`;
	}
	editor.setValue(lines.join("\n"));

	new Notice(msg);
}

function toggleLineNumbers() {
	const vault = view.app.vault;
	vault.setConfig("showLineNumber", !vault.getConfig("showLineNumber"));
}

function clearNotices() {
	// @ts-expect-error `activeDocument` available via vimrc plugin
	const allNotices = activeDocument.body.getElementsByClassName("notice");
	for (const el of allNotices) {
		el.hide();
	}
}

function inspectWordCount() {
	const text = editor
		.getValue()
		.replace(/^---\n.*?\n---\n/s, "") // remove yaml frontmatter
		.trim();
	const charCount = text.length;
	const wordCount = text.split(/\s+/).length;
	new Notice(`Characters: ${charCount} \nWords: ${wordCount}`);
}

//──────────────────────────────────────────────────────────────────────────────

async function updatePlugins() {
	const app = view.app;

	new Notice("Checking for updates…");
	await app.plugins.checkForUpdates();

	// Click "Update All" Button
	setTimeout(() => {
		// timeout to avoid race condition still happening somehow
		const updateCount = Object.keys(app.plugins.updates).length;
		if (updateCount > 0) {
			app.setting.open();
			app.setting.openTabById("community-plugins");
			app.setting.activeTab.containerEl.findAll(".mod-cta").last().click();
		}
	}, 1000);
}

function openPluginDirectory() {
	const app = view.app;
	app.openWithDefaultApp(app.vault.configDir + "/plugins");
}

function openSnippetDirectory() {
	const app = view.app;
	app.openWithDefaultApp(app.vault.configDir + "/snippets");
}

function installPluginsFromPluginBrowser() {
	const app = view.app;
	app.workspace.protocolHandlers.get("show-plugin")({ id: " " });
}

function cycleThemes() {
	const app = view.app;
	const currentTheme = app.customCss.theme;
	const installedThemes = Object.keys(app.customCss.themes);
	if (installedThemes.length === 0) {
		new Notice("Cannot cycle themes since no community theme is installed.");
		return;
	}
	installedThemes.push(""); // "" = default theme

	const indexOfNextTheme = (installedThemes.indexOf(currentTheme) + 1) % installedThemes.length;
	const nextTheme = installedThemes[indexOfNextTheme] || "";
	app.customCss.setTheme(nextTheme);
}

function openDynamicHighlightsSettings() {
	const setting = view.app.setting;
	setting.open();
	setting.openTabById("obsidian-dynamic-highlights");

	// edit first highlight item
	setting.activeTab.containerEl.find(".highlighter-container").find(".mod-cta").click();

	// focus query input and move cursor to start
	const input = setting.activeTab.containerEl.find(".query-wrapper").find("input");
	input.focus();
	input.scrollLeft = 0; // scroll to start
	input.setSelectionRange(1, 1); // move cursor to 2nd position
}
