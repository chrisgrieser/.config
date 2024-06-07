// @ts-nocheck
// EXAMPLE configs: https://github.com/brookhong/Surfingkeys/wiki/Example-Configurations
//──────────────────────────────────────────────────────────────────────────────

// biome-ignore format: unwieldy
// biome-ignore lint/correctness/noUnusedVariables: just to list them all
const { Hints, imap, imapkey, map, mapkey, removeSearchAlias, unmap, unmapAllExcept, vmapkey, vunmap, aceVimMap } = api;

//──────────────────────────────────────────────────────────────────────────────
// SETTINGS

// DOCS https://github.com/brookhong/Surfingkeys#edit-your-own-settings
settings.richHintsForKeystroke = 400; // like whichkey, value is delay till shown
settings.hintShiftNonActive = true; // vimium-like: holding shift while pressing hint opens in bg tab
settings.startToShowEmoji = 0; // length of chars to show emojis (acemode)

Hints.style("font-family: Arial; font-size: 12px;");

// disable surfingkey's pdf viewer
chrome.storage.local.set({ noPdfViewer: 1 });

//──────────────────────────────────────────────────────────────────────────────
// IGNORE LIST

// unmap jk on google for web search navigator (vimium-like controls for google only)
unmap("j", /google/);
unmap("k", /google/);

// unmap("?", /github.com/); // cheatsheet for github shortcuts
// unmap("?", /reddit.com/); // cheatsheet for reddit shortcuts

//──────────────────────────────────────────────────────────────────────────────
// Mappings

// Navigation & History

// HJKL SCROLL MOVEMENTS
settings.scrollStepSize = 300;
map("J", "P"); // page down
map("K", "U"); // page up
map("h", "S"); // History Back/Forward
map("l", "D");
map("H", "[["); // Next/Prev Page
map("L", "]]");

// WASD TAB MOVEMENTS
map("w", "x"); // close tab
map("s", "x"); // TODO yank & close
map("d", "E"); // goto tab right
map("a", "R"); // goto tab left
map("D", ">>"); // move tab to the right
map("A", "<<"); // move tab to the left

map("u", "X"); // reopen tab
map("yt", "yT"); // duplicate tab in background

map("q", "gx0"); // close tabs on left
map("e", "gx$"); // close tabs on right

//──────────────────────────────────────────────────────────────────────────────

map("<C-v>", "W"); // move tab to new window (vsplit with Hammerspoon)
map("M", ";gw"); // merge all windows

map("t", "T"); // choose tab via hint
// higher than this threshold, fuzzy find instead -> 1 -> always use fuzzy finder
settings.tabsThreshold = 1;

// Links
map("F", "C"); // Open Hint in new tab
map("yf", "ya"); // yank a link
map("ge", ";U"); // Edit current URL

// yank & clipboard
map("ye", "yv"); // yank text of an element
map("o", "cc"); // open URL from clipboard or selection

// find
map("-", "/");

// Misc
map("m", "<Alt-m>"); // mute tab
map("<D-r>", ";pm"); // markdown preview
map("gi", "I"); // enter insert field
unmap("a"); // open link (remapped)
map("i", "p"); // disable for one key
map(",", ";e"); // Settings

//──────────────────────────────────────────────────────────────────────────────
// Insert Mode & ACE editor

aceVimMap("<CR>", ":wq"); // save and close

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
unmap("D"); // scroll down (remapped)
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
