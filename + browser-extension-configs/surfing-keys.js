// @ts-nocheck
// DOCS https://github.com/brookhong/Surfingkeys/blob/master/docs/API.md
// EXAMPLE configs: https://github.com/brookhong/Surfingkeys/wiki/Example-Configurations
// DEFAULT mappings: https://github.com/brookhong/Surfingkeys/blob/master/src/content_scripts/common/default.js
//──────────────────────────────────────────────────────────────────────────────

const { Normal, Hints, Front, imap, map, mapkey, unmap, aceVimMap } = api;
const banner = api.Front.showBanner;

//──────────────────────────────────────────────────────────────────────────────
// SETTINGS

// DOCS https://github.com/brookhong/Surfingkeys#edit-your-own-settings
settings.richHintsForKeystroke = 500; // like whichkey, value is delay till shown
settings.hintShiftNonActive = true; // vimium-like: holding shift while pressing hint opens in bg tab
settings.enableEmojiInsertion = true;
settings.modeAfterYank = "normal"; // = leave visual mode after yanking

settings.caseSensitive = false;
settings.smartCase = true;

// disable surfingkey's pdf viewer
// chrome.storage.local.set({ noPdfViewer: 1 });

settings.startToShowEmoji = 1;

//──────────────────────────────────────────────────────────────────────────────
// THEME

Hints.style("font-family: Arial; font-size: 15px;");

// cssclasses: https://github.com/brookhong/Surfingkeys/blob/master/src/content_scripts/ui/frontend.css
settings.theme = `
   #sk_status, #sk_find {
      font-size: 1.2rem;
   }
	#sk_banner {
		top: unset !important;
		left: unset !important;
		width: unset !important;
		right: 0.7rem;
		bottom: 0.7rem;
		height: 1.2rem;
		font-size: 1rem;
		border-radius: 8px !important;
		border-top-style: solid !important;
	}
}`;

//──────────────────────────────────────────────────────────────────────────────
// SITE-SPECIFIC SETTINGS

// Google extensions
unmap("j", /google/); // websearch navigator
unmap("k", /google/); // websearch navigator
unmap("c", /google/); // Grepper

// for BetterTouchTool Mappings
unmap("f", /crunchyroll|animeflix/);
unmap("n", /crunchyroll/);
unmap("N", /crunchyroll/);

// site-specific cheatsheets
unmap("?", /github\.com/);
unmap("?", /reddit\.com/);
unmap("?", /devdocs\.io/);

// disable emojis on GitHub, since they already have them
if (document.origin === "https://github.com") settings.enableEmojiInsertion = false;

mapkey(
	"gu",
	"go up to subreddit",
	() => {
		const redditRegex = /https:\/\/(new|old|www)\.reddit\.com\/r\/\w+/;
		const subredditUrl = window.location.href.match(redditRegex)[0];
		if (subredditUrl) window.location.href = subredditUrl;
	},
	{ domain: /reddit\.com/ },
);

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
	banner("Copied: " + url);
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

mapkey("t", "Choose a tab", () => Front.openOmnibar({ type: "Tabs" }));

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
mapkey("ym", "Copy Markdown Link", async () => {
	const mdLink = `[${document.title}](${window.location.href})`;
	await navigator.clipboard.writeText(mdLink);
	banner("Copied: " + mdLink);
});
mapkey("yg", "Copy GitHub Link", async () => {
	const url = window.location.href;
	if (url.startsWith("https://github.com/")) {
		const [_, repo] = url.match(/https:\/\/github\.com\/(.*?\/[^/]*)/) || [];
		if (!repo) return;
		await navigator.clipboard.writeText(repo);
		banner("Copied: " + repo);
	} else {
		banner("Not at GitHub.");
	}
});

//──────────────────────────────────────────────────────────────────────────────

// FIND
map("-", "/");

//──────────────────────────────────────────────────────────────────────────────

// Misc
map("P", "oi"); // private window (incognito)
map("gi", "I"); // enter insert field
mapkey("i", "Passthrough", () => Normal.PassThrough(500));
map("p", "<Alt-p>"); // pin (INFO needs to be after mapping `i` to prevent recursion)
map(",", ";e"); // Settings

//──────────────────────────────────────────────────────────────────────────────
// INSERT MODE / ACE EDITOR

aceVimMap("<CR>", ":wq"); // save and close
aceVimMap("q", ":q!"); // abort

aceVimMap("<Space>", "ciw");
// INFO <S-Space> remapped in Karabiner
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

imap("<Ctrl-a>", "<Ctrl-f>"); // BoL

//──────────────────────────────────────────────────────────────────────────────
