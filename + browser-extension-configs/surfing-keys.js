// @ts-nocheck

// DOCS
// - API https://github.com/brookhong/Surfingkeys/blob/master/docs/API.md
// - FAQ https://github.com/brookhong/Surfingkeys/wiki/FAQ
// - default mappings https://github.com/brookhong/Surfingkeys/blob/master/src/content_scripts/common/default.js
// - example configs https://github.com/brookhong/Surfingkeys/wiki/Example-Configurations
//──────────────────────────────────────────────────────────────────────────────

// biome-ignore format: too long
const { Normal, Hints, Front, imap, map, mapkey, vmapkey, unmap, aceVimMap, removeSearchAlias, searchSelectedWith } = api;
const banner = api.Front.showBanner;

//──────────────────────────────────────────────────────────────────────────────
// SETTINGS

// DOCS https://github.com/brookhong/Surfingkeys#edit-your-own-settings
settings.richHintsForKeystroke = 600; // like whichkey, value is delay till shown
settings.hintShiftNonActive = true; // vimium-like: holding shift while pressing hint opens in bg tab
settings.modeAfterYank = "normal"; // = leave visual mode after yanking

settings.caseSensitive = false;
settings.smartCase = true;

// disable surfingkey's pdf viewer
// chrome.storage.local.set({ noPdfViewer: 1 });

//──────────────────────────────────────────────────────────────────────────────
// EMOJIS

settings.enableEmojiInsertion = true;
settings.startToShowEmoji = 1;
if (window.location.host === "github.com") settings.enableEmojiInsertion = false;

//──────────────────────────────────────────────────────────────────────────────
// THEME

Hints.style("font-family: Helvetica; font-size: 14px;");

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
unmap("N", /crunchyroll/);

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

mapkey("yg", "Copy GitHub Link", async () => {
	if (window.location.host !== "github.com") {
		banner("Not at GitHub.");
		return;
	}
	const url = window.location.href;
	const [_, repo] = url.match(/https:\/\/github\.com\/(.*?\/[^/]*)/) || [];
	if (!repo) return;
	await navigator.clipboard.writeText(repo);
	banner("Copied: " + repo);
});
mapkey("gI", "Open GitHub issues", () => {
	if (window.location.host !== "github.com") {
		banner("Not at GitHub.");
		return;
	}
	const url = window.location.href;
	const [_, repo] = url.match(/https:\/\/github\.com\/(.*?\/[^/]*)/) || [];
	window.location.href = `https://github.com/${repo}/issues`;
});

//──────────────────────────────────────────────────────────────────────────────

// HJKL: SCROLL MOVEMENTS
settings.scrollStepSize = 300;
map("J", "P"); // page down
map("K", "U"); // page up
map("h", "S"); // History Back/Forward
map("l", "D");
map("H", "[["); // Next/Prev Page
map("L", "]]");

// alt type: "History"
mapkey("gr", "Recent sites", () => Front.openOmnibar({ type: "RecentlyClosed" }));

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

mapkey("t", "Quick switcher open tabs", () => Front.openOmnibar({ type: "Tabs" }));

// WINDOW
map("<Ctrl-v>", "W"); // move tab to new window (= vsplit with Hammerspoon)
map("M", ";gw"); // merge all windows

// Links
map("F", "C"); // Open Hint in new tab
map("c", ";U"); // Edit current URL

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

// MISC
map("P", "oi"); // private window (incognito)
map("p", "<Alt-p>");
mapkey("i", "Passthrough", () => Normal.PassThrough(600));

mapkey(",", "Open Surfingkey Settings", () => {
	const filePath = "/Users/chrisgrieser/.config/+ browser-extension-configs/surfing-keys.js";
});

//──────────────────────────────────────────────────────────────────────────────
// VISUAL MODE
map("-", "/");

vmapkey("s", "Google Selection", () => searchSelectedWith("https://www.google.com/search?q="));

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

for (const alias of ["b", "d", "g", "h", "w", "y", "s", "e"]) {
	removeSearchAlias(alias);
}
