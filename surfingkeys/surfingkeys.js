// DOCS
// - API https://github.com/brookhong/Surfingkeys/blob/master/docs/API.md
// - FAQ https://github.com/brookhong/Surfingkeys/wiki/FAQ
// - default mappings https://github.com/brookhong/Surfingkeys/blob/master/src/content_scripts/common/default.js
// - example configs https://github.com/brookhong/Surfingkeys/wiki/Example-Configurations
//──────────────────────────────────────────────────────────────────────────────

// biome-ignore format: too long
const { Normal, Hints, Front, imap, map, mapkey, vmapkey, unmap, aceVimMap, removeSearchAlias, searchSelectedWith, RUNTIME } = api;
const banner = api.Front.showBanner;

//──────────────────────────────────────────────────────────────────────────────
// SETTINGS

// DOCS https://github.com/brookhong/Surfingkeys#edit-your-own-settings
settings.richHintsForKeystroke = 600; // like whichkey, value is delay till shown
settings.hintShiftNonActive = true; // vimium-like: holding shift while pressing hint opens in bg tab
settings.modeAfterYank = "normal"; // = leave visual mode after yanking

settings.caseSensitive = false;
settings.smartCase = true;

//──────────────────────────────────────────────────────────────────────────────
// EMOJIS

settings.enableEmojiInsertion = true;
settings.startToShowEmoji = 2;
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
unmap("N", /crunchyroll|animeflix/);

mapkey(
	"gu",
	"go up to subreddit",
	() => {
		const redditRegex = /https:\/\/(new|old|www)\.reddit\.com\/r\/\w+/;
		const subredditUrl = window.location.href.match(redditRegex)?.[0];
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
map("z", "cs", null, "Change Scroll target");

map("h", "S"); // History Back/Forward
map("l", "D");
map("H", "[["); // Next/Prev Page
map("L", "]]");

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

// quick switcher
// type: "History"|"RecentlyClosed"
mapkey("gr", "Recent sites", () => Front.openOmnibar({ type: "RecentlyClosed" }));

mapkey("t", "Quick switcher open tabs", () => Front.openOmnibar({ type: "Tabs" }));

// WINDOW
map("<Ctrl-v>", "W", null, "Move to new Window (split via Hammerspoon)");
map("M", ";gw", null, "Merge Windows");

// Links
map("F", "C"); // Open Hint in new tab
map("c", ";U"); // Edit current URL

// YANK & CLIPBOARD
mapkey("o", "Open from clipboard", async () => {
	const clipb = await navigator.clipboard.readText();
	if (clipb.startsWith("http")) window.open(clipb);
	else banner("Not a URL");
});

map("yf", "ya", null, "Yank Link (via Hint)");
map("yc", "yq", null, "Yank Codeblock");
map("ye", "yv", null, "Yank Element");
map("yw", "yY", null, "Yank all tabs in window");
mapkey("ym", "Copy Markdown Link", async () => {
	const mdLink = `[${document.title}](${window.location.href})`;
	await navigator.clipboard.writeText(mdLink);
	banner("Copied: " + mdLink);
});

// MISC
mapkey("P", "Incognito window", () => RUNTIME("openIncognito", { url: window.location.href }));
map("p", "<Alt-p>", null, "pin");
mapkey("i", "Passthrough", () => Normal.PassThrough(600));

// HACK open config via hammerspoon, as browser is sandboxed and cannot open files
mapkey(",", "Open Surfingkeys config", () => window.open("hammerspoon://open-surfingkeys-config"));

//──────────────────────────────────────────────────────────────────────────────
// VISUAL MODE
map("-", "/");

vmapkey("s", "Search Selection with Google", () =>
	searchSelectedWith("https://www.google.com/search?q="),
);

//──────────────────────────────────────────────────────────────────────────────

// INSERT MODE / ACE EDITOR
aceVimMap("<CR>", ":wq"); // save and close
aceVimMap("q", ":q!"); // abort

aceVimMap("<Space>", "ciw");
// INFO <S-Space> needs to be remapped in Karabiner
aceVimMap("H", "g0");
aceVimMap("L", "g$");
aceVimMap("j", "gj");
aceVimMap("k", "gk");
aceVimMap("U", "<C-r>");
aceVimMap("J", "4j");
aceVimMap("K", "4k");
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

imap("<Ctrl-f>", "<Ctrl-i>"); // forward text to vim editor (conistent with terminal)

//──────────────────────────────────────────────────────────────────────────────

for (const alias of ["b", "d", "g", "h", "w", "y", "s", "e"]) {
	removeSearchAlias(alias);
}
