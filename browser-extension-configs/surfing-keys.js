/* global api, settings, window, document */

// Compatibility Prefix
const { imap, imapkey, map, mapkey, removeSearchAlias, unmap, unmapAllExcept, vmapkey, vunmap, aceVimMap } = api;

//──────────────────────────────────────────────────────────────────────────────

// ---- SETTINGS ----
// https://github.com/brookhong/Surfingkeys#edit-your-own-settings
settings.focusAfterClosed = "last";
settings.richHintsForKeystroke = 400; // like whichkey, value is delay till shown
settings.hintShiftNonActive = true; // vimium-like: holding shift while pressing hint opens in bg tab

//──────────────────────────────────────────────────────────────────────────────

// IGNORE LIST
settings.blocklistPattern = undefined; /* eslint-disable-line no-undefined */

unmap("j", /google/); // unmap jk on google for web search navigator (vimium-like controls for google only)
unmap("k", /google/);
unmap("?", /github/); // cheatsheet for github shortcuts

//──────────────────────────────────────────────────────────────────────────────
// ---- Mappings -----

// Navigation & History
map("J", "P"); // page down
map("K", "U"); // page up
settings.scrollStepSize = 300;

map("h", "S"); // History Back/Forward
map("l", "D");
map("gh", "[["); // Next/Prev Page
map("gl", "]]");

// tabs
map("H", "R"); // goto tab right
map("L", "E"); // goto tab left
map("B", "<<"); // move tab to the left
map("E", ">>"); // move tab to the right

map("i", "x"); // close tab
map("u", "X"); // reopen tab
map("yt", "yT"); // duplicate tab in background

unmap("w"); // so it can be mapped for window commands
map("wq", "gx0"); // close tabs on left
map("we", "gx$"); // close tabs on right
map("ww", "gxx"); // close all other tabs
map("wv", "W"); // move tab to new window (vsplit with Hammerspoon)
map("wm", ";gw"); // merge all windows to current one

map("t", "T"); // choose tab via hint
settings.tabsThreshold = 8; // higher than this threshold, fuzzy find instead

// Links
map("F", "C"); // Open Hint in new tab
map("yf", "ya"); // yank a link
map("ge", ";U"); // Edit current URL

// yank & clipboard
map("ye", "yv"); // yank text of an element
map("p", "cc"); // open URL from clipboard or selection

// find
map("-", "/"); // find

// Misc
map("B", "ab"); // bookmark
map("X", ";dh"); // delete bookmark
map("m", "<Alt-m>"); // mute tab
map("M", ";pm"); // markdown preview
map("gi", "I"); // enter insert field
unmap("a"); // open link (remapped)
map("a", "p"); // disable for one key
map(",", ";e"); // Settings

// toggle fullscreen
// mapkey("Z", "Fullscreen", function () {
// 	if (window.fullScreen) {
// 		document.exitFullscreen();
// 	} else {
// 		document.documentElement.requestFullscreen();
// 	}
// });

//──────────────────────────────────────────────────────────────────────────────
// Insert Mode & ACE editor

// BUG these seem not to be working: https://github.com/brookhong/Surfingkeys/discussions/1926
aceVimMap("<Space>", "ciw");
aceVimMap("<S-Space>", "daw");
aceVimMap("H", "0");
aceVimMap("L", "$");
aceVimMap("j", "gj");
aceVimMap("l", "gk");

imap("<Ctrl-a>", "<Ctrl-f>"); // boL

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

unmap("$"); // scroll to right
unmap("B"); // add bookmark (remapped)
unmap("*"); // find selected text (remapped)
unmap("/"); // find (remapped)
unmap("0"); // scroll to left
unmap(";U"); // edit URL (remapped)
unmap(";dh"); // delete bookmark (remapped)
unmap(";pj"); // restore settings from clipboard
unmap(";pm"); // markdown preview (remapped)
unmap(";pp"); // paste as html
unmap(";ql"); // show last action
unmap(";yh"); // yank history
unmap("<Alt-i>"); // pass through (remapped)
unmap("<Ctrl-'>"); // jump to vim-mark in new tab
unmap("<Ctrl-6>"); // switch to last tab (remapped)
unmap("<Ctrl-a>"); // BoL (remapped)
unmap("D"); // scroll donw (remapped)
unmap("S"); // history back (remapped)
unmap("[["); // page navigation (remapped)
unmap("]]"); // page navigation (remapped)
unmap("cc"); // paste link (remapped)
unmap("g$"); // last tab
unmap("g0"); // first tab
unmap("gx$"); // close tabs to right (remapped)
unmap("gx0"); // close tabs to left (remapped)
unmap("gxx"); // close other tabs (remapped)
unmap("yQ"); // copy omnibar query history
unmap("yT"); // duplicate tab in background (remapped)
unmap("ys"); // copy page source
