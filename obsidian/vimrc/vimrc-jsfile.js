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
	const allNotices = activeDocument.body.getElementsByClassName("notice");
	for (const el of allNotices) {
		el.hide();
	}
}

function inspectWordCount() {
	const textNoFrontmatter = editor
		.getValue()
		.replace(/^---\n.*?\n---\n/s, "")
		.trim();
	const charCount = textNoFrontmatter.length;
	const charNoSpacesCount = textNoFrontmatter.replace(/%s+/g, "").length;
	const wordCount = textNoFrontmatter.split(/\s+/).length;

	const msg = [
		`Chars: ${charCount}`,
		`Chars (no spaces): ${charNoSpacesCount}`,
		`Words: ${wordCount}`,
	].join("\n");
	new Notice(msg, 5000);
}

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

function freezeInterface() {
	const delaySecs = 4;
	new Notice(`Will freeze Obsidian in ${delaySecs}s`, delaySecs * 1000);
	electronWindow.openDevTools(); // devtools need to be open for debugger to work
	// biome-ignore format: ugly
	setTimeout(() => { debugger }, delaySecs * 1000 + 200)
}

function cycleColorscheme() {
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

function openAppearanceSettings() {
	const setting = view.app.setting;
	setting.open();
	setting.openTabById("appearance");
	// scroll fully down to access snippets more quickly
	setting.activeTab.containerEl.scrollTop = setting.activeTab.containerEl.scrollHeight;
}

function openDynamicHighlightsSettings() {
	const setting = view.app.setting;
	setting.open();
	setting.openTabById("obsidian-dynamic-highlights");

	setTimeout(() => {
		// timeout to ensure highlight colors are loaded
		// edit first custom highlight item
		setting.activeTab.containerEl.find(".highlighter-container").find(".mod-cta").click();

		// focus query input and move cursor to start
		const input = setting.activeTab.containerEl.find(".query-wrapper").find("input");
		input.focus();
		input.scrollLeft = 0; // scroll to start
		input.setSelectionRange(0, 0); // move cursor to start
	}, 100);
}

/** @param {"load"|"save"} mode @param {string} workspaceName */
async function workspace(mode, workspaceName) {
	const workspacePlugin = view.app.internalPlugins.plugins.workspaces;
	await workspacePlugin.enable();

	if (mode === "load") workspacePlugin.instance.loadWorkspace(workspaceName);
	else if (mode === "save") workspacePlugin.instance.saveWorkspace(workspaceName);

	new Notice(`${mode === "load" ? "Loaded" : "Saved"} workspace "${workspaceName}".`);
}

//──────────────────────────────────────────────────────────────────────────────

/** @param {"next"|"prev"} which */
function gotoHeading(which) {
	const reverseLnum = (/** @type {number} */ line) => editor.lineCount() - line - 1;

	let currentLnum = editor.getCursor().line;
	if (which === "prev") currentLnum = reverseLnum(currentLnum);
	const allLines = editor.getValue().split("\n");
	if (which === "prev") allLines.reverse();
	const linesBelow = allLines.slice(currentLnum + 1);
	const linesAbove = allLines.slice(0, currentLnum);

	let headingLnum = linesBelow.findIndex((line) => line.match(/^#+ /));
	if (headingLnum > -1) headingLnum += currentLnum + 1; // account for previous slicing

	// wrap around if next heading not found
	if (headingLnum === -1) headingLnum = linesAbove.findIndex((line) => line.match(/^#+ /));

	if (headingLnum === -1) {
		new Notice("No heading found.");
	} else {
		if (which === "prev") headingLnum = reverseLnum(headingLnum);
		editor.setCursor(headingLnum, 0);
	}
}

/** @param {"above"|"below"} where */
function smartInsertBlank(where) {
	const lnum = editor.getCursor().line;
	const curLine = editor.getLine(lnum);
	let [indentAndText] = curLine.match(/^\s*[-*+] /) || // unordered list
		curLine.match(/^\s*>+ /) || // blockquote
		curLine.match(/^\s*\d+[.)] /) || // ordered list
		curLine.match(/^\s*/) || [""]; // just indent

	// increment ordered list
	const orderedList = indentAndText.match(/\d+/)?.[0];
	if (orderedList) {
		const inrecremented = (Number.parseInt(orderedList) + 1).toString();
		indentAndText = indentAndText.replace(/\d+/, inrecremented);
	}

	const targetLine = where === "above" ? lnum : lnum + 1;
	editor.replaceRange(indentAndText + "\n", { line: targetLine, ch: 0 });

	editor.setCursor(targetLine, indentAndText.length);
	activeWindow.CodeMirrorAdapter.Vim.enterInsertMode(editor.cm.cm); // = vim's `a`
}

// merge lines, but remove indentation, lists, and blockquotes
function smartMerge() {
	const lnum = editor.getCursor().line;
	const curLine = editor.getLine(lnum);
	const nextLine = editor.getLine(lnum + 1);
	const nextLineCleaned = nextLine
		.replace(/^\s*[-*+] /, "") // unordered list
		.replace(/^\s*>+ /, "") // blockquote
		.replace(/^\s*\d+[.)] /, "") // ordered list
		.trim(); // justIndent
	const mergedLine = curLine + " " + nextLineCleaned;

	const prevCursor = editor.getCursor(); // prevent cursor from moving
	editor.replaceRange(mergedLine, { line: lnum, ch: 0 }, { line: lnum + 1, ch: nextLine.length });
	editor.setCursor(prevCursor);
}

/** @param {"absolute"|"relative"|"filename"} segment */
function copyPathSegment(segment) {
	const toCopy =
		segment === "absolute"
			? view.app.vault.adapter.getFullPath(view.file.path)
			: segment === "relative"
				? view.file.path
				: view.file.name;
	navigator.clipboard.writeText(toCopy);
	new Notice("Copied:\n" + toCopy);
}

/** as opposed to simply using `yyp`, this does not fill the register.
 * In addition, the cursor position (column) is preserved. */
function duplicateLine() {
	const cursor = editor.getCursor();
	const line = editor.getLine(cursor.line);
	editor.replaceRange(line + "\n", { line: cursor.line + 1, ch: 0 });
	editor.setCursor(cursor.line + 1, cursor.ch);
}

function toggleLowercaseTitleCase() {
	const cursor = editor.getCursor();
	const { from, to } = editor.wordAt(cursor);
	const word = editor.getRange(from, to);

	const newFirstChar =
		word[0] === word[0].toUpperCase() ? word[0].toLowerCase() : word[0].toUpperCase();
	const newWord = newFirstChar + word.slice(1).toLowerCase();

	editor.replaceRange(newWord, from, to);
	editor.setCursor(cursor); // restore, as `replaceRange` moves cursor
}

// forward looking `gx`
/** @param {"current-tab"|"new-tab"} where */
function openNextLink(where) {
	function getLinkRange(/** @type {string} */ text) {
		const linkRegex = /(https?|obsidian):\/\/[^ )]+|\[\[.+?\]\]|\[.+?\]\(\)/;
		//        ^         (    url / obsidian URI   )( wikilink )(markdown link)
		const linkMatch = text.match(linkRegex);
		if (!linkMatch?.index) return { start: -1, end: -1 };
		const start = linkMatch.index;
		const end = start + linkMatch[0].length;
		return { start, end };
	}

	// check if cursor is on a link
	const cursor = editor.getCursor();
	const fullLine = editor.getLine(cursor.line);
	let linkStart;
	let linkEnd;
	let posInLine = 0;
	do {
		const { start, end } = getLinkRange(fullLine.slice(posInLine));
		linkStart = start;
		linkEnd = end;
		if (end > 0) posInLine += end;
	} while (linkEnd > 0 && linkEnd < cursor.ch);
	const cursorIsOnLink = cursor.ch >= linkStart && cursor.ch <= linkEnd;

	// if not, seek forwards for a link
	if (!cursorIsOnLink) {
		const offset = editor.posToOffset(cursor);
		const textAfterCursor = editor.getValue().slice(offset);
		const linkAfterCursorOffset = getLinkRange(textAfterCursor).start;
		if (linkAfterCursorOffset === -1) {
			new Notice("No link found.");
			return;
		}
		const linkPosition = editor.offsetToPos(offset + linkAfterCursorOffset);
		linkPosition.ch++;
		editor.setCursor(linkPosition);
	}

	const commandId = where === "new-tab" ? "editor:open-link-in-new-leaf" : "editor:follow-link";
	view.app.commands.executeCommandById(commandId);
}

/**
 * @param {string} vaultRelPath (just `/` for vault root)
 * @param {string} frontmatterKey
 * @param {string|number|boolean} frontmatterValue
 */
async function openRandomNoteIn(vaultRelPath, frontmatterKey, frontmatterValue) {
	vaultRelPath = vaultRelPath
		.replace(/\/*$/, "/") // ensure `/` at end
		.replace(/^\/$/, ""); // make vault root always true for `startsWith`
	const app = view.app;
	const currentFile = view.file.path;

	const files = app.vault.getMarkdownFiles().filter((f) => {
		const inFolder = f.path.startsWith(vaultRelPath);
		const notCurrent = f.path !== currentFile;
		const frontmatterCache = app.metadataCache.getFileCache(f).frontmatter;
		const hasProperty = frontmatterCache?.[frontmatterKey] === frontmatterValue;
		return inFolder && notCurrent && hasProperty;
	});
	if (files.length === 0) {
		new Notice(`No notes in ${vaultRelPath} with ${frontmatterKey}: ${frontmatterValue}.`);
		return;
	}
	const randomIndex = Math.floor(Math.random() * files.length);
	const randomFile = files[randomIndex];
	await app.workspace.getLeaf().openFile(randomFile);
}

//──────────────────────────────────────────────────────────────────────────────
// STUFF FOR DATAVIEWJS

function toggleJsLineComment() {
	const cursor = editor.getCursor();
	const text = editor.getLine(cursor.line);

	const [_, indent, comment, textWithoutComment] = text.match(/^(\s*)(\/\/ )?(.*)/) || [];
	const updatedText = comment ? indent + textWithoutComment : indent + "// " + textWithoutComment;
	cursor.ch = comment ? cursor.ch - 3 : cursor.ch + 3;

	editor.setLine(cursor.line, updatedText);
	editor.setCursor(cursor);
}

function appendJsComment() {
	const cursor = editor.getCursor();
	const text = editor.getLine(cursor.line);
	const updatedText = text + " // ";
	editor.setLine(cursor.line, updatedText);
	editor.setCursor(cursor.line, updatedText.length);
	activeWindow.CodeMirrorAdapter.Vim.enterInsertMode(editor.cm.cm); // = vim's `a`
}

function consoleLogFromWordUnderCursor() {
	const cursor = editor.getCursor();
	const cursorWordRange = editor.wordAt(cursor);
	const cursorWord = editor.getRange(cursorWordRange.from, cursorWordRange.to);
	const indent = editor.getLine(cursor.line).match(/^\s*/)?.[0] || "";
	const logLine = indent + `console.log(${cursorWord});`;

	editor.replaceRange(logLine + "\n", { line: cursor.line + 1, ch: 0 });
	editor.setCursor(cursor); // restore, as `replaceRange` moves cursor
}