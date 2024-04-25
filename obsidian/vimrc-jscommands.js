// DOCS https://github.com/esm7/obsidian-vimrc-support/blob/master/JsSnippets.md
//──────────────────────────────────────────────────────────────────────────────

/**
 * @param {string} key
 * @param {boolean|string|number} value
 */
// biome-ignore lint/correctness/noUnusedVariables: used by vimrc plugin
function addYamlKey(key, value) {
	const editor = view.editor;
	const /** @type {string[]} */ lines = editor.getValue().split("\n");
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
		lines.splice(frontmatterEnd, 0, yamlLine); // insert at frontmatter
		msg = `Added property "${key}" with value "${value}"`;
	} else {
		lines[keyLnum] = yamlLine; // update existing key
		msg = `Set property "${key}" to "${value}"`;
	}
	editor.setValue(lines.join("\n"));

	new Notice(msg);
}

//──────────────────────────────────────────────────────────────────────────────

// biome-ignore lint/correctness/noUnusedVariables: used by vimrc plugin
function toggleLineNumbers() {
	const vault = view.app.vault;
	vault.setConfig("showLineNumber", !vault.getConfig("showLineNumber"));
}

//──────────────────────────────────────────────────────────────────────────────

// biome-ignore lint/correctness/noUnusedVariables: used by vimrc plugin
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

// biome-ignore lint/correctness/noUnusedVariables: used by vimrc plugin
function openPluginDirectory() {
	const app = view.app;
	app.openWithDefaultApp(app.vault.configDir + "/plugins");
}

// biome-ignore lint/correctness/noUnusedVariables: used by vimrc plugin
function installPluginsFromPluginBrowser() {
	const app = view.app;
	app.workspace.protocolHandlers.get("show-plugin")({ id: " " });
}
