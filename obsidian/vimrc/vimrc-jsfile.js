// DOCS https://github.com/esm7/obsidian-vimrc-support/blob/master/JsSnippets.md

function deleteLastChar() {
	const cursor = editor.getCursor();
	const updatedText = editor.getLine(cursor.line).replace(/\S\s*$/, "");
	editor.setLine(cursor.line, updatedText);
	editor.setCursor(cursor);
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
	}, 1500); // timeout to avoid race condition still happening somehow
}

function freezeInterface() {
	const delaySecs = 4;
	new Notice(`Will freeze Obsidian in ${delaySecs}s`, delaySecs * 1000);
	electronWindow.openDevTools(); // devtools need to be open for debugger to work

	// biome-ignore format: ugly
	setTimeout(() => { debugger }, delaySecs * 1000)
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

/**
 * @param {Editor} editor
 * @param {EditorPosition} oldCursor
 * @param {EditorPosition} newCursor
 */
function _setCursorAndAddToJumplist(editor, oldCursor, newCursor) {
	editor.setCursor(newCursor);

	// HACK set vim-mode-jumplist https://github.com/replit/codemirror-vim/blob/master/src/vim.js#L532
	activeWindow.CodeMirrorAdapter.Vim.getVimGlobalState_().jumpList.add(
		editor.cm.cm, // SIC two levels deep
		oldCursor,
		newCursor,
	);
}

/**
 * @param {"next"|"prev"} direction
 * @param {RegExp} pattern
 * @param {"wrap"=} wrap
 */
function gotoLineWithPattern(direction, pattern, wrap) {
	const reverseLnum = (/** @type {number} */ line) => editor.lineCount() - line - 1;

	const prevCursor = editor.getCursor();
	let currentLnum = prevCursor.line;
	if (direction === "prev") currentLnum = reverseLnum(currentLnum);
	const allLines = editor.getValue().split("\n");
	if (direction === "prev") allLines.reverse();
	const linesBelow = allLines.slice(currentLnum + 1);

	let lnumWithPattern = linesBelow.findIndex((line) => line.match(pattern));
	if (lnumWithPattern > -1) lnumWithPattern += currentLnum + 1; // account for previous slicing

	// wrap around if not found
	if (wrap && lnumWithPattern === -1) {
		const linesAbove = allLines.slice(0, currentLnum);
		lnumWithPattern = linesAbove.findIndex((line) => line.match(pattern));
	}

	if (lnumWithPattern === -1) {
		new Notice(`No line found with pattern ${pattern}`);
		return;
	}
	if (direction === "prev") lnumWithPattern = reverseLnum(lnumWithPattern);
	_setCursorAndAddToJumplist(editor, prevCursor, { line: lnumWithPattern, ch: 0 });
}

function gotoLastLinkInFile() {
	const pattern = "[[";
	const lastOccurrence = editor.getValue().lastIndexOf(pattern);
	const prevCursor = editor.getCursor();
	const newCursor = editor.offsetToPos(lastOccurrence);
	_setCursorAndAddToJumplist(editor, prevCursor, newCursor);
}

//──────────────────────────────────────────────────────────────────────────────

/** h1 -> h2, h2 -> h3, etc. */
/** @param {1|-1} dir */
function headingIncrementor(dir) {
	const { line: lnum, ch: col } = editor.getCursor();
	const curLine = editor.getLine(lnum);
	const cleanLine = curLine.replace(/^- |\*\*|__/g, ""); // remove other md formatting

	let updatedLine = cleanLine.replace(/^#* /, (match) => {
		if (dir === -1 && match !== "# ") return match.slice(1);
		if (dir === 1 && match !== "###### ") return "#" + match;
		return "";
	});
	if (updatedLine === cleanLine) updatedLine = (dir === 1 ? "## " : "###### ") + cleanLine;

	editor.setLine(lnum, updatedLine);
	const diff = updatedLine.length - curLine.length;
	editor.setCursor(lnum, col + diff); // keep cursor in same place
}

function cycleListTypes() {
	const { line: lnum, ch: col } = editor.getCursor();
	const curLine = editor.getLine(lnum);

	let updatedLine = curLine.replace(/^(\s*)([-*+>#.)[\]\d x]+) /, (_, indent, list) => {
		if (list.match(/^[-*+](?! \[)/)) return indent + "- [ ] "; // list -> open task
		if (list.startsWith("- [")) return indent + "1. "; // open task -> ordered
		if (list.match(/\d/)) return indent + ""; // ordered -> none
		return ""; // other like headings: remove
	});
	if (updatedLine === curLine) updatedLine = "- " + curLine; // none -> list

	const diff = updatedLine.length - curLine.length;
	editor.setLine(lnum, updatedLine);
	editor.setCursor(lnum, col + diff); // keep cursor in same place
}

/** @param {"above"|"below"} where */
function smartOpenLine(where) {
	const lnum = editor.getCursor().line;
	const curLine = editor.getLine(lnum);

	const [indentAndText] = curLine.match(/^\s*(>+|- \[[x ]\]|[-*+]|\d+[.)]) /) || [""];
	const newPrefix = indentAndText
		.replace(/\d+/, (n) => (Number.parseInt(n) + 1).toString()) // increment ordered list
		.replace(/\[x\]/, "[ ]"); // new tasks should be open

	const targetLine = where === "above" ? lnum : lnum + 1;
	const atEndOfFile = editor.lastLine() === lnum && where === "below";
	const extra = atEndOfFile ? "\n" : "";
	editor.replaceRange(extra + newPrefix + "\n", { line: targetLine, ch: 0 });

	editor.setCursor(targetLine, newPrefix.length);
	activeWindow.CodeMirrorAdapter.Vim.enterInsertMode(editor.cm.cm); // = vim's `a`
}

//──────────────────────────────────────────────────────────────────────────────

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
		.trim(); // remove indentation
	const mergedLine = curLineCleaned + " " + nextLineCleaned;

	const prevCursor = editor.getCursor(); // prevent cursor from moving
	editor.replaceRange(mergedLine, { line: lnum, ch: 0 }, { line: lnum + 1, ch: nextLine.length });
	editor.setCursor(prevCursor);
}

/** @param {"absolute"|"relative"|"filename"|"parent"} segment */
function copyPathSegment(segment) {
	let toCopy;
	if (segment === "absolute") toCopy = view.app.vault.adapter.getFullPath(view.file.path);
	else if (segment === "relative") toCopy = view.file.path;
	else if (segment === "filename") toCopy = view.file.name;
	else if (segment === "parent") toCopy = view.file.parent.path;
	else toCopy = "invalid segment argument";
	navigator.clipboard.writeText(toCopy);
	new Notice(`Copied ${segment}:\n` + toCopy);
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
	new Notice("Copied Obsidian URI:\n" + basename);
}

function toggleLowercaseTitleCase() {
	const cursor = editor.getCursor();
	const { from, to } = editor.wordAt(cursor);
	const word = editor.getRange(from, to);

	const newFirstChar =
		word[0] === word[0].toUpperCase() ? word[0].toLowerCase() : word[0].toUpperCase();
	const newWord = newFirstChar + word.slice(1).toLowerCase();

	editor.replaceRange(newWord, from, to);
	editor.setCursor(cursor); // restore position, as `replaceRange` moves cursor
}

/** forward looking `gx`
 * @param {"current-tab"|"new-tab"} where
 */
function openNextLink(where) {
	function rangeOfFirstLink(/** @type {string} */ text) {
		const linkRegex = /(https?|obsidian):\/\/[^ )]+|\[\[.+?\]\]|\[[^\]]*?\]\(.+?\)/;
		//                 (    URL / obsidian URI    ) (wikilink ) ( markdown link  )
		const linkMatch = text.match(linkRegex);
		if (!linkMatch || linkMatch.index === undefined) return { start: -1, end: -1 };
		const start = linkMatch.index;
		const end = start + linkMatch[0].length;
		return { start, end };
	}

	// check if cursor is currently on a link
	const cursor = editor.getCursor();
	const fullLine = editor.getLine(cursor.line);
	let linkStart;
	let linkEnd;
	let posInLine = 0;
	let cursorIsOnLink = false;
	while (true) {
		const { start, end } = rangeOfFirstLink(fullLine.slice(posInLine));
		const noLinkLeft = start === -1 && end === -1;
		if (noLinkLeft) break;
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
		_setCursorAndAddToJumplist(editor, cursor, linkPosition);
	}

	const commandId = where === "new-tab" ? "open-link-in-new-leaf" : "follow-link";
	view.app.commands.executeCommandById("editor:" + commandId);
}

async function fixWordUnderCursor() {
	const cursor = editor.getCursor();
	const wordRange = editor.wordAt(cursor);
	const wordUnderCursor = editor.getRange(wordRange.from, wordRange.to);

	const url = "https://suggestqueries.google.com/complete/search?output=chrome&q=";
	const response = await request(url + encodeURI(wordUnderCursor));
	const firstSuggestion = JSON.parse(response)[1][0];
	// using first word, since sometimes google suggests multiple words, but we
	// only want the first as the spellfix
	let fixedWord = firstSuggestion.match(/^\S+/)[0];
	// capitalize, if original word was also capitalized
	if (wordUnderCursor.charAt(0) === wordUnderCursor.charAt(0).toUpperCase()) {
		fixedWord = fixedWord.charAt(0).toUpperCase() + fixedWord.slice(1);
	}

	if (fixedWord === wordUnderCursor) {
		new Notice("Already correct.");
	} else {
		editor.replaceRange(fixedWord, wordRange.from, wordRange.to);
		editor.setCursor(cursor);
	}
}

/** Save/load a workspace using the Workspaces Core Plugin.
 * Enables the plugin before, and disables it afterward.
 * @param {"load"|"save"} action
 * @param {string} workspaceName
 */
async function workspace(action, workspaceName) {
	const workspacePlugin = view.app.internalPlugins.plugins.workspaces;
	await workspacePlugin.enable();

	if (action === "load") workspacePlugin.instance.loadWorkspace(workspaceName);
	else if (action === "save") workspacePlugin.instance.saveWorkspace(workspaceName);

	new Notice(`${action === "load" ? "Loaded" : "Saved"} workspace "${workspaceName}".`);
	setTimeout(() => workspacePlugin.disable(), 3000);
}

//──────────────────────────────────────────────────────────────────────────────

// CAVEAT slightly breaks `h` and `l` in tables
function origamiH() {
	const isAtBoL = editor.getCursor().ch === 0;
	const action = isAtBoL ? "toggleFold" : "goLeft";
	editor.exec(action);
}

function origamiL() {
	const currentLn = editor.getCursor().line;
	const folds = editor.getFoldOffsets();
	const foldedLines = [...folds].map((offset) => editor.offsetToPos(offset).line);

	const action = foldedLines.includes(currentLn) ? "toggleFold" : "goRight";
	editor.exec(action);
}

//──────────────────────────────────────────────────────────────────────────────

function inspectUnresolvedLinks() {
	const app = view.app;

	// UNRESOLVED
	const unresolvedCache = app.metadataCache.unresolvedLinks;
	const filesWithUnresolved = [];
	for (const [filepath, unresolvedLinks] of Object.entries(unresolvedCache)) {
		const unresolvedTargets = Object.keys(unresolvedLinks);
		if (unresolvedTargets.length === 0) continue;
		const basename = filepath.slice(0, -3);
		filesWithUnresolved.push(basename + ": " + unresolvedTargets.join(", "));
	}
	const msg1 =
		filesWithUnresolved.length > 0
			? "Unresolved links:\n- " + filesWithUnresolved.join("\n- ")
			: "No unresolved links.";
	new Notice(msg1, 0);

	// ORPHANS
	const ignoredFolders = ["Meta"]; // CONFIG
	const ignoredExtensions = ["md"];
	const resolvedLinkCache = app.metadataCache.resolvedLinks;
	const /** @type {Record<string, boolean>} */ allLinks = {};
	for (const [_, resolvedLinks] of Object.entries(resolvedLinkCache)) {
		for (const link of Object.keys(resolvedLinks)) {
			allLinks[link] = true;
		}
	}
	const orphans = app.vault
		.getFiles()
		.filter((f) => {
			const isOrphan = !allLinks[f.path];
			const nonMarkdown = !ignoredExtensions.includes(f.extension);
			const notInIgnoredFolder = ignoredFolders.every((folder) => !f.path.startsWith(folder));
			return isOrphan && nonMarkdown && notInIgnoredFolder;
		})
		.map((file) => "- " + file.path);
	const msg2 = orphans.length > 0 ? "Orphans:\n" + orphans.join("\n") : "No orphans.";
	new Notice(msg2, 0);
}

// biome-ignore lint/complexity/noExcessiveCognitiveComplexity: okay here
function toggleComment() {
	/** @type {Record<string, string|string[]>} */
	const commentChars = {
		md: ["<!--", "-->"],
		html: ["<!--", "-->"],
		js: "//",
		json: "//",
		ts: "//",
		swift: "//",
		css: ["/*", "*/"],
		lua: "--",
		applescript: "--",
		fallback: "#",
	};
	//───────────────────────────────────────────────────────────────────────────

	const app = view.app;
	const activeFile = app.workspace.getActiveFile();
	if (!activeFile) return;
	const cursor = editor.getCursor();
	const lnum = cursor.line;

	// determine if in codeblock
	let codeblockLang = "md"; // default: not in codeblock and thus markdown
	const sections = app.metadataCache.getFileCache(activeFile).sections;
	for (const section of sections) {
		const isInSection = lnum > section.position.start.line && lnum < section.position.end.line;
		if ((section.type === "code" || section.type === "yaml") && isInSection) {
			codeblockLang = "yaml";
			if (section.type === "code") {
				const codeblockStart = section.position.start.line;
				codeblockLang = editor.getLine(codeblockStart).match(/(?:```|~~~)(.*)/)?.[1] || "";
			}
			break;
		}
	}

	// toggle comment
	const line = editor.getLine(lnum);
	const commentStr = commentChars[codeblockLang || ""] || commentChars.fallback;
	let updatedLine = "";
	let columnShift = 0;

	if (typeof commentStr === "string") {
		updatedLine = line.startsWith(commentStr)
			? line.slice(commentStr.length).trim()
			: `${commentStr} ${line}`;
		columnShift = updatedLine.length - line.length;
	} else {
		const isCommented = line.startsWith(commentStr[0]) && line.endsWith(commentStr[1]);
		updatedLine = isCommented
			? line.slice(commentStr[0].length, -commentStr[1].length).trim()
			: `${commentStr[0]} ${line} ${commentStr[1]}`;
		columnShift = (commentStr[0].length + 1) * (isCommented ? -1 : 1);
	}
	editor.setLine(lnum, updatedLine);

	// keep cursor in same place
	cursor.ch += columnShift;
	editor.setCursor(cursor);
}
