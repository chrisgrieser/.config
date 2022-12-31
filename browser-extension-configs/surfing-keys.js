/* global api, settings, window, document */

// Compatibility Prefix
const { imap, imapkey, map, mapkey, removeSearchAlias, unmap, unmapAllExcept, vmapkey, vunmap } = api;

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
map("H", "[["); // Next/Prev Page
map("L", "]]");

// tabs
map("e", "R"); // one tab right
map("b", "E"); // one tab right
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
settings.tabsThreshold = 7; // higher than this threshold, fuzzy find instead

// Links
map("F", "C"); // Open Hint in new tab
map("yf", "ya"); // yank a link
map("ge", ";U"); // Edit current URL

// yank & clipboard
map("ye", "yv"); // yank text of an element
map("p", "cc"); // open URL from clipboard or selection

// find & visual
map("-", "/"); // find
map("+", "*"); // find selection

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
// Insert Mode
// imap("<Space>", "ciw") TODO look up requires syntax for this
// imap("<Shift-Space>", "daw")
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

// unmap(";ap");
// unmap(";di");
// unmap(";e");
// unmap(";fs");
// unmap(";gt");
// unmap(";gw");
// unmap(";j");
// unmap(";m");
// unmap(";pa");
// unmap(";pb");
// unmap(";pc");
// unmap(";pd");
// unmap(";pf");
// unmap(";ps");
// unmap(";u");
// unmap(";v");
// unmap(";w");
// unmap(";yQ");
// unmap("<Alt-m>");
// unmap("<Alt-p>");
// unmap("<Ctrl-Alt-i>");
// unmap("<Ctrl-h>");
// unmap("<Ctrl-j>");
// unmap("C");
// unmap("I");
// unmap("P");
// unmap("R");
// unmap("U");
// unmap("W");
// unmap("cS");
// unmap("cf");
// unmap("cp");
// unmap("cs");
// unmap("d");
// unmap("g#");
// unmap("g?");
// unmap("gT");
// unmap("ga");
// unmap("gb");
// unmap("gc");
// unmap("gf");
// unmap("gn");
// unmap("gs");
// unmap("gt");
// unmap("gxT");
// unmap("gxp");
// unmap("gxt");
// unmap("on");
// unmap("q");
// unmap("yG");
// unmap("yS");
// unmap("ya");
// unmap("yh");
// unmap("yj");
// unmap("yma");
// unmap("yq");
// unmap("yv");
// unmap("zb");
// unmap("zi");
// unmap("zo");
// unmap("zr");
// unmap("zt");
// unmap("zv");
unmap("$"); // scroll to right
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
unmap("D");
unmap("S"); // history back (remapped)
unmap("[[");
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
