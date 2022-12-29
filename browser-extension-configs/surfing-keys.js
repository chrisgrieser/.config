/* global api, settings, window, document */

// Compatibility Prefix
const {
	Clipboard,
	Front,
	Hints,
	Normal,
	RUNTIME,
	Visual,
	aceVimMap,
	addSearchAlias,
	cmap,
	getClickableElements,
	imap,
	imapkey,
	iunmap,
	map,
	mapkey,
	readText,
	removeSearchAlias,
	tabOpenLink,
	unmap,
	unmapAllExcept,
	vmapkey,
	vunmap,
} = api;

//──────────────────────────────────────────────────────────────────────────────

// ---- SETTINGS ----
// https://github.com/brookhong/Surfingkeys#edit-your-own-settings
// Hints.setCharacters("asdfgyuiopqwertnmzxcvb");
settings.focusAfterClosed = "last";
settings.scrollStepSize = 300;
settings.tabsThreshold = 7;
settings.modeAfterYank = "Normal";
settings.showModeStatus = false;

//──────────────────────────────────────────────────────────────────────────────

// ---- Mappings -----
map("J", "P"); // page down
map("K", "U"); // page up

map("e", "R"); // one tab right
map("b", "E"); // one tab right
map("i", "x"); // close tab
map("u", "X"); // reopen tab
map("wq", "gx0"); // close tabs on left
map("we", "gx$"); // close tabs on right
map("ww", "gx$"); // close all other tabs
map("<", "<<"); // move tab to the left
map(">", ">>"); // move tab to the right

map("F", "C"); // Open Hint in new tab

map("ye", "yv"); // yank text of an element

map("wv", "W"); // move tab to new window (vsplit with Hammerspoon)

map("gi", "i"); // enter insert field
map("a", "p"); // disable for one key

map("h", "S"); // History Back/Forward
map("l", "D");

map("H", "[["); // Next/Prev Page
map("L", "]]");

map("-", "/"); // find

map("ge", ";u"); // Edit current URL
map(",", ";e"); // Settings
map("t", "T"); // choose tab via hint

map("p", "cc"); // open URL from clipboard or selection
// Open Clipboard URL in current tab
// mapkey("P", "Open the clipboard's URL in the current tab", () => {
// 	Clipboard.read(function (response) {
// 		window.location.href = response.data;
// 	});
// });

// toggle fullscreen, mainly because of YouTube
mapkey("F", "Fullscreen", function () {
	if (window.fullScreen) {
		document.exitFullscreen();
	} else {
		document.documentElement.requestFullscreen();
	}
});

//──────────────────────────────────────────────────────────────────────────────

// IGNORE LIST
settings.blocklistPattern = undefined; /* eslint-disable-line no-undefined */

// unmap jk on google for web search navigator (vimium-like controls for google only)
unmap("j", /google/);
unmap("k", /google/);

//──────────────────────────────────────────────────────────────────────────────

// unmapping unused stuff
removeSearchAlias("b", "s");
removeSearchAlias("d", "s");
removeSearchAlias("g", "s");
removeSearchAlias("h", "s");
removeSearchAlias("w", "s");
removeSearchAlias("y", "s");
removeSearchAlias("s", "s");
removeSearchAlias("e", "s");
