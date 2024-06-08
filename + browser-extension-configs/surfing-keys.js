// @ts-nocheck
// EXAMPLE configs: https://github.com/brookhong/Surfingkeys/wiki/Example-Configurations
//──────────────────────────────────────────────────────────────────────────────

// biome-ignore format: unwieldy
// biome-ignore lint/correctness/noUnusedVariables: just to list them all
const { Hints, imap, imapkey, map, mapkey, removeSearchAlias, unmap, unmapAllExcept, vmapkey, vunmap, aceVimMap } = api;

//──────────────────────────────────────────────────────────────────────────────
// SETTINGS

// DOCS https://github.com/brookhong/Surfingkeys#edit-your-own-settings
settings.richHintsForKeystroke = 500; // like whichkey, value is delay till shown
settings.hintShiftNonActive = true; // vimium-like: holding shift while pressing hint opens in bg tab
settings.enableEmojiInsertion = true;
settings.startToShowEmoji = 1; // length of chars to show emojis (acemode)
settings.modeAfterYank = "normal";

settings.caseSensitive = false;
settings.smartCase = true;

Hints.style("font-family: Arial; font-size: 12px;");

// disable surfingkey's pdf viewer
// chrome.storage.local.set({ noPdfViewer: 1 });

//──────────────────────────────────────────────────────────────────────────────
// IGNORE LIST

unmap("j", /google/); // websearch navigator
unmap("k", /google/);
unmap("c", /google/); // Grepper

unmap("f", /crunchyroll/);
unmap("n", /crunchyroll/);
unmap("N", /crunchyroll/);

// have site-specific cheatsheets
unmap("?", /github\.com/);
unmap("?", /reddit\.com/);
unmap("?", /devdocs\.io/);

//──────────────────────────────────────────────────────────────────────────────

// HJKL: SCROLL MOVEMENTS
settings.scrollStepSize = 300;
map("J", "P"); // page down
map("K", "U"); // page up
map("h", "S"); // History Back/Forward
map("l", "D");
map("H", "[["); // Next/Prev Page
map("L", "]]");

map("gr", "ox"); // [g]o to [r]ecent item from history

//──────────────────────────────────────────────────────────────────────────────

// WASD: TAB MOVEMENTS
map("w", "x"); // close tab
map("m", "x"); // close tab
mapkey("s", "Copy URL & close tab", async () => {
	const url = window.location.href;
	await navigator.clipboard.writeText(url);
	window.close();
});
map("a", "E"); // goto tab right
map("d", "R"); // goto tab left
map("A", "<<"); // move tab to the left
map("D", ">>"); // move tab to the right

map("u", "X"); // reopen tab
map("yt", "yT"); // duplicate tab in background

map("q", "gx0"); // close tabs on left
map("e", "gx$"); // close tabs on right

map("t", "T"); // choose tab via hint
// higher than this threshold, fuzzy find instead -> 1 -> always use fuzzy finder
settings.tabsThreshold = 1;

//──────────────────────────────────────────────────────────────────────────────

// WINDOW
map("<Ctrl-v>", "W"); // move tab to new window (= vsplit with Hammerspoon)
map("M", ";gw"); // merge all windows

// Links
map("F", "C"); // Open Hint in new tab
map("c", ";U"); // Edit current URL

//──────────────────────────────────────────────────────────────────────────────

// YANK & CLIPBOARD
map("o", "cc"); // open URL from clipboard or selection
map("yf", "ya"); // yank a link
map("ye", "yv"); // yank text of an element
map("yw", "yY"); // yank all tabs in window
mapkey("ym", "Copy Markdown Link", () => {
	const mdLink = `[${document.title}](${window.location.href})`;
	navigator.clipboard.writeText(mdLink);
});
mapkey("yg", "Copy GitHub Link", () => {
	const url = window.location.href;
	if (url.startsWith("https://github.com/")) {
		const [_, repo] = url.match(/https:\/\/github\.com\/(.*?\/[^/]*)/) || [];
		if (!repo) return;
		navigator.clipboard.writeText(repo);
	} else {
		alert("Not at GitHub.");
	}
});

//──────────────────────────────────────────────────────────────────────────────

// find
map("-", "/");

// Misc
map("P", "oi"); // private window (incognito)
map("gi", "I"); // enter insert field
map("i", "p"); // disable for one key
map("p", "<Alt-p>"); // pin (INFO needs to be after mapping `i` to prevent recursion)
map(",", ";e"); // Settings

//──────────────────────────────────────────────────────────────────────────────
// INSERT MODE / ACE EDITOR

aceVimMap("<CR>", ":wq"); // save and close
aceVimMap("q", ":q!"); // abort

aceVimMap("<Space>", "ciw");
aceVimMap("H", "0");
aceVimMap("L", "$");
aceVimMap("j", "gj");
aceVimMap("k", "gk");
aceVimMap("U", "<C-r>");
aceVimMap("J", "6j");
aceVimMap("K", "6k");
aceVimMap("M", "gJ"); // mapping `to` gJ instead of `J` to prevent recursion, as there is no `noremap`

// text objects
aceVimMap("im", "iW");
aceVimMap("am", "aW");
aceVimMap("ir", "i[");
aceVimMap("ar", "a[");
aceVimMap("iq", 'i"');
aceVimMap("aq", 'a"');
aceVimMap("ie", "i`");
aceVimMap("ae", "a`");

imap("<Ctrl-a>", "<Ctrl-f>"); // boL

//──────────────────────────────────────────────────────────────────────────────
