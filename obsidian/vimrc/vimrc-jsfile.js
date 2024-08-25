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
	for (const el of allNotices) el.hide();
}

function inspectWordCount() {
	const add1000Sep = (/** @type {number} */ num) =>
		num.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ".");

	const body = editor
		.getValue()
		.replace(/^---\n.*?\n---\n/s, "")
		.trim();
	const charCount = body.length;
	const charNoSpacesCount = body.replace(/\s+/g, "").length;
	const wordCount = body.split(/\s+/).length;

	const msg = [
		`Chars: ${add1000Sep(charCount)} (${add1000Sep(charNoSpacesCount)})`,
		`Words: ${add1000Sep(wordCount)}`,
	].join("\n");
	new Notice(msg, 5000);
}

async function updatePlugins() {
	const app = view.app;

	new Notice("Checking for updates…");
	await app.plugins.checkForUpdates();

	// Click "Update All" Button
	setTimeout(() => {
		const updateCount = Object.keys(app.plugins.updates).length;
		if (updateCount > 0) {
			app.setting.open();
			app.setting.openTabById("community-plugins");
			app.setting.activeTab.containerEl.findAll(".mod-cta").last().click();
		}
	}, 1000); // timeout to avoid race condition still happening somehow
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
	if (installedThemes.length === 0) return;
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
	const container = setting.activeTab.containerEl;
	container.scrollTop = container.scrollHeight;
}

function openCommunityPluginsSettings() {
	const setting = view.app.setting;
	setting.open();
	setting.openTabById("community-plugins");
}

function openDynamicHighlightsSettings() {
	const setting = view.app.setting;
	setting.open();
	setting.openTabById("obsidian-dynamic-highlights");

	// timeout to ensure highlight colors are loaded
	setTimeout(() => {
		// edit first custom highlight item
		setting.activeTab.containerEl.find(".highlighter-container").find(".mod-cta").click();

		// focus query input and move cursor to start
		const input = setting.activeTab.containerEl.find(".query-wrapper").find("input");
		input.focus();
		input.scrollLeft = 0; // scroll to start
		input.setSelectionRange(0, 0); // move cursor to start
	}, 100);
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

/** h1 -> h2, h2 -> h3, etc. */
function headingIncrementor() {
	const { line: lnum, ch: col } = editor.getCursor();
	const curLine = editor.getLine(lnum);

	let updatedLine = curLine.replace(/^#* /, (match) => {
		if (match === "###### ") return "";
		return match.trim() + "# ";
	});
	if (updatedLine === curLine) updatedLine = "## " + curLine;
	const diff = updatedLine.length - curLine.length;

	editor.setLine(lnum, updatedLine);
	editor.setCursor(lnum, col + diff); // keep cursor in same place
}

/** @param {"above"|"below"} where */
function smartOpenLine(where) {
	const lnum = editor.getCursor().line;
	const curLine = editor.getLine(lnum);
	let [indentAndText] = curLine.match(/^\s*>+ /) || // blockquote
		curLine.match(/^\s*- \[[x ]\] /) || // task
		curLine.match(/^\s*[-*+] /) || // unordered list
		curLine.match(/^\s*\d+[.)] /) || // ordered list
		curLine.match(/^\s*/) || [""]; // just indent

	// increment ordered list
	const orderedList = indentAndText.match(/\d+/)?.[0];
	if (orderedList) {
		const inrecremented = (Number.parseInt(orderedList) + 1).toString();
		indentAndText = indentAndText.replace(/\d+/, inrecremented);
	}

	const targetLine = where === "above" ? lnum : lnum + 1;
	const atEof = editor.lastLine() === lnum && where === "below";
	const extra = atEof ? "\n" : "";
	editor.replaceRange(extra + indentAndText + "\n", { line: targetLine, ch: 0 });

	editor.setCursor(targetLine, indentAndText.length);
	activeWindow.CodeMirrorAdapter.Vim.enterInsertMode(editor.cm.cm); // = vim's `a`
}

// merge lines, but remove indentation, lists, and blockquotes
function smartMerge() {
	const lnum = editor.getCursor().line;
	const curLine = editor.getLine(lnum);
	const nextLine = editor.getLine(lnum + 1);
	const curLineCleaned = curLine.replace(/ +$/, ""); // trim trailing spaces
	const nextLineCleaned = nextLine
		.replace(/^\s*- \[[x ]\] /, "") // task
		.replace(/^\s*[-*+] /, "") // unordered list
		.replace(/^\s*>+ /, "") // blockquote
		.replace(/^\s*\d+[.)] /, "") // ordered list
		.trim(); // justIndent
	const mergedLine = curLineCleaned + " " + nextLineCleaned;

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

function copyObsidianUriMdLink() {
	const app = view.app;
	const activeFile = app.workspace.getActiveFile();
	if (!activeFile) return;
	const filePathEnc = encodeURIComponent(activeFile.path);
	const basename = activeFile.basename;
	const vaultName = app.vault.getName();
	const vaultNameEnc = encodeURIComponent(vaultName);

	const obsidianUri = `obsidian://open?vault=${vaultNameEnc}&file=${filePathEnc}`;
	const mdLink = `[${basename} (${vaultName})](${obsidianUri})`;

	navigator.clipboard.writeText(mdLink);
	new Notice("Copied Obsidian URI to:\n" + basename);
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

/** forward looking `gx`
 * @param {"current-tab"|"new-tab"} where
 */
function openNextLink(where) {
	function rangeOfFirstLink(/** @type {string} */ text) {
		const linkRegex = /(https?|obsidian):\/\/[^ )]+|\[\[.+?\]\]|\[.*?\]\(.+?\)/;
		//                 (    url / obsidian URI    )( wikilink )(markdown link)
		const linkMatch = text.match(linkRegex);
		if (!linkMatch || linkMatch.index === undefined) return { start: -1, end: -1 };
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
	let cursorIsOnLink = false;
	while (true) {
		const { start, end } = rangeOfFirstLink(fullLine.slice(posInLine));
		if (start === -1) break; // no link left
		linkStart = posInLine + start;
		linkEnd = posInLine + end;
		cursorIsOnLink = linkStart <= cursor.ch && linkEnd >= cursor.ch;
		if (cursorIsOnLink) break;
		posInLine += end;
	}

	// if not, seek forwards for a link
	if (!cursorIsOnLink) {
		const offset = editor.posToOffset(cursor);
		const textAfterCursor = editor.getValue().slice(offset);
		const linkAfterCursorOffset = rangeOfFirstLink(textAfterCursor).start;
		if (linkAfterCursorOffset === -1) {
			new Notice("No link found.");
			return;
		}
		const linkPosition = editor.offsetToPos(offset + linkAfterCursorOffset);
		linkPosition.ch++; // Obsidian's "follow-link" command is off-by-one
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
		.replace(/^\/$/, ""); // make vault-root always true for `startsWith`
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
		new Notice(`No notes in "${vaultRelPath}" with "${frontmatterKey}: ${frontmatterValue}".`);
		return;
	}
	const randomIndex = Math.floor(Math.random() * files.length);
	const randomFile = files[randomIndex];
	await app.workspace.getLeaf().openFile(randomFile);
}
/** For use with the "Rephraser" form the "Writing Assistant" Alfred workflow,
 * which sends text to OpenAI, and returns the diff in form of highlights
 * (additions) and strikethroughs (deletions).
 * @param {"accept"|"reject"} action
 */
function highlightsAndStrikthrus(action) {
	const lnum = editor.getCursor().line;
	const lineText = editor.getLine(lnum);
	const updatedLine =
		action === "accept"
			? lineText.replace(/==/g, "").replace(/~~.*?~~/g, "")
			: lineText.replace(/~~/g, "").replace(/==.*?==/g, "");
	editor.setLine(lnum, updatedLine);
}

function gotoLastLinkInFile() {
	const lastOccurrence = editor.getValue().lastIndexOf("[[");
	editor.setCursor(editor.offsetToPos(lastOccurrence));
}

//──────────────────────────────────────────────────────────────────────────────
// STUFF FOR DATAVIEW_JS

function toggleJsLineComment() {
	const cursor = editor.getCursor();
	const lineText = editor.getLine(cursor.line);

	const [_, indent, hasComment, textWithoutComment] = lineText.match(/^(\s*)(\/\/ )?(.*)/) || [];
	const updatedText = indent + (hasComment ? " // " : "") + textWithoutComment;
	cursor.ch += hasComment ? -3 : 3;

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

//──────────────────────────────────────────────────────────────────────────────

/** reload plugin via: obsidian://reload-plugin?id=someid&vault=somevault */
function registerReloadUri() {
	const app = view.app;
	const plugin = app.plugins.getPlugin("obsidian-vimrc-support");
	new Notice("URI for reloading plugins registered.");

	plugin.registerObsidianProtocolHandler(
		"reload-plugin",
		async (/** @type {Record<string, any>} */ uriParams) => {
			const pluginId = uriParams?.id;
			if (pluginId) {
				await app.plugins.disablePlugin(pluginId);
				await app.plugins.enablePlugin(pluginId);
				new Notice(`Reloaded ${pluginId}.`);
			}
		},
	);
}
