/* global api, settings, window, document */
// example configs: https://github.com/brookhong/Surfingkeys/wiki/Example-Configurations

// Compatibility Prefix
const { Hints, imap, imapkey, map, mapkey, removeSearchAlias, unmap, unmapAllExcept, vmapkey, vunmap, aceVimMap } = api;

//──────────────────────────────────────────────────────────────────────────────

// ---- SETTINGS ----
// https://github.com/brookhong/Surfingkeys#edit-your-own-settings
settings.richHintsForKeystroke = 400; // like whichkey, value is delay till shown
settings.hintShiftNonActive = true; // vimium-like: holding shift while pressing hint opens in bg tab
settings.startToShowEmoji = 0; // length of chars to show emojis (acemode)

Hints.style("font-family: Arial; font-size: 12px;");

//──────────────────────────────────────────────────────────────────────────────

// IGNORE LIST
unmap("j", /google/); // unmap jk on google for web search navigator (vimium-like controls for google only)
unmap("k", /google/);

unmap("?", /github.com/); // cheatsheet for github shortcuts

unmap("j", /reddit.com\/r\/\w+\/$/); // = in threads, use surfing-keys, in subreddit views, use reddit's controls
unmap("k", /reddit.com\/r\/\w+\/$/);
unmap("?", /reddit.com/); // cheatsheet for reddit shortcuts
unmap("l", /reddit.com/); // open reddit link
unmap("x", /reddit.com/); // toggle fold
unmap("a", /reddit.com/); // upvote
unmap("z", /reddit.com/); // downvote
unmap("r", /reddit.com/); // reply

//──────────────────────────────────────────────────────────────────────────────
// Mappings

// Navigation & History
map("J", "P"); // page down
map("K", "U"); // page up
settings.scrollStepSize = 300;

map("h", "S"); // History Back/Forward
map("l", "D");
map("gh", "[["); // Next/Prev Page
map("gl", "]]");

// tabs
map("H", "E"); // goto tab right
map("L", "R"); // goto tab left
map("b", "<<"); // move tab to the left
map("e", ">>"); // move tab to the right

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
mapkey("s", "Fullscreen", function () {
	if (window.fullScreen) {
		document.exitFullscreen();
	} else {
		document.documentElement.requestFullscreen();
	}
});

//──────────────────────────────────────────────────────────────────────────────
// Insert Mode & ACE editor

aceVimMap("<Space>", "ciw");
// HACK <S-Space> done via Karabiner, since not working here
aceVimMap("H", "0");
aceVimMap("L", "$");
aceVimMap("j", "gj");
aceVimMap("k", "gk");
aceVimMap("U", "<C-r>");
aceVimMap("J", "6j");
aceVimMap("K", "6k");
aceVimMap("M", "gJ"); // mapping to gJ instead of J to prevent recursion, as noremap does not seem to be available

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

// unmapping unused stuff to reduce noise in the cheatsheet

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
unmap("gr"); // read out loud

removeSearchAlias("b", "s");
removeSearchAlias("d", "s");
removeSearchAlias("g", "s");
removeSearchAlias("h", "s");
removeSearchAlias("w", "s");
removeSearchAlias("y", "s");
removeSearchAlias("s", "s");
removeSearchAlias("e", "s");
