// @ts-nocheck
// DOCS https://github.com/esm7/obsidian-vimrc-support/blob/master/JsSnippets.md
//──────────────────────────────────────────────────────────────────────────────

// biome-ignore lint/correctness/noUnusedVariables: used by vimrc plugin
function origamiH() {
	// biome-ignore lint/correctness/noUndeclaredVariables: passed by vimrc plugin
	const editor = view.editor;
	const isAtBoL = editor.getCursor().ch === 0;
	const action = isAtBoL ? "toggleFold" : "goLeft";
	editor.exec(action);
}

// biome-ignore lint/correctness/noUnusedVariables: used by vimrc plugin
function origamiL() {
	// biome-ignore lint/correctness/noUndeclaredVariables: passed by vimrc plugin
	const editor = view.editor;

	const currentLn = editor.getCursor().line;
	const folds = editor.getFoldOffsets();
	const foldedLines = [...folds].map((offset) => editor.offsetToPos(offset).line);

	const action = foldedLines.includes(currentLn) ? "toggleFold" : "goRight";
	editor.exec(action);
}

//──────────────────────────────────────────────────────────────────────────────

// biome-ignore lint/correctness/noUnusedVariables: used by vimrc plugin
function addYamlKey(key, value) {
	// biome-ignore lint/correctness/noUndeclaredVariables: passed by vimrc plugin
	const editor = view.editor;
	const /** @type {string[]} */ lines = editor.getValue().split("\n");
	const frontmatterEnd = lines.slice(1).findIndex((line) => line === "---") + 1;
	if (frontmatterEnd === 0) {
		// biome-ignore lint/correctness/noUndeclaredVariables: available via Obsidian API
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

	// biome-ignore lint/correctness/noUndeclaredVariables: available via Obsidian API
	new Notice(msg);
}

//──────────────────────────────────────────────────────────────────────────────

// biome-ignore lint/correctness/noUnusedVariables: used by vimrc plugin
function toggleLineNumbers() {
	// biome-ignore lint/correctness/noUndeclaredVariables: passed by vimrc plugin
	const vault = view.app.vault;
	vault.setConfig("showLineNumber", !vault.getConfig("showLineNumber"));
}

// biome-ignore lint/correctness/noUnusedVariables: used by vimrc plugin
function insertHr() {
	// biome-ignore lint/correctness/noUndeclaredVariables: passed by vimrc plugin
	const editor = view.editor;
	editor.replaceSelection("\n---\n");
}

//──────────────────────────────────────────────────────────────────────────────

// biome-ignore lint/correctness/noUnusedVariables: used by vimrc plugin
async function updatePlugins() {
	// biome-ignore lint/correctness/noUndeclaredVariables: passed by vimrc plugin
	const app = view.app;
	// biome-ignore lint/correctness/noUndeclaredVariables: passed by vimrc plugin
	new Notice("Checking for updates…");
	await app.plugins.checkForUpdates();

	// Click "Update All" Button
	const updateCount = Object.keys(app.plugins.updates).length;
	if (updateCount > 0) {
		app.setting.open();
		app.setting.openTabById("community-plugins");
		app.setting.activeTab.containerEl.findAll(".mod-cta").last().click();
	}
}

// biome-ignore lint/correctness/noUnusedVariables: used by vimrc plugin
function openPluginDirectory() {
	// biome-ignore lint/correctness/noUndeclaredVariables: passed by vimrc plugin
	const app = view.app;
	app.openWithDefaultApp(app.vault.configDir + "/plugins");
}
