// DOCS
// - API https://github.com/brookhong/Surfingkeys/blob/master/docs/API.md
// - FAQ https://github.com/brookhong/Surfingkeys/wiki/FAQ
// - default mappings https://github.com/brookhong/Surfingkeys/blob/master/src/content_scripts/common/default.js
// - example configs https://github.com/brookhong/Surfingkeys/wiki/Example-Configurations
//──────────────────────────────────────────────────────────────────────────────

// biome-ignore format: too long
const { Normal, Hints, Front, imap, map, mapkey, vmapkey, unmap, aceVimMap, removeSearchAlias, searchSelectedWith, RUNTIME } = api;
const banner = api.Front.showBanner;

/** @param {string} text */
async function copyAndNotify(text) {
	await navigator.clipboard.writeText(text);
	if (text.length > 50) text = text.slice(0, 50) + "…";
	banner("Copied: " + text);
}

//──────────────────────────────────────────────────────────────────────────────
// SETTINGS

// DOCS https://github.com/brookhong/Surfingkeys#edit-your-own-settings
settings.richHintsForKeystroke = 600; // like whichkey, value is delay till shown
settings.hintShiftNonActive = true; // vimium-like: holding shift while pressing hint opens in bg tab
settings.modeAfterYank = "normal"; // = leave visual mode after yanking

settings.caseSensitive = false;
settings.smartCase = true;

// disable surfingkey's pdf viewer
chrome.storage.local.set({ noPdfViewer: 1 });

//──────────────────────────────────────────────────────────────────────────────
// EMOJIS

settings.enableEmojiInsertion = true;
settings.startToShowEmoji = 2;
const alreadyHaveEmojis = [
	"github.com", // already has emoji picker
	"web.whatsapp.com",
	"web.telegram.org",
	"mail.google.com",
	"www.google.com", // also applies to google maps
];
if (alreadyHaveEmojis.includes(window.location.host)) settings.enableEmojiInsertion = false;

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

// HJKL: SCROLL MOVEMENTS
settings.scrollStepSize = 300;
map("J", "P"); // page down
map("K", "U"); // page up

map("h", "S"); // History Back/Forward
map("l", "D");
map("H", "[["); // Next/Prev Page
map("L", "]]");

// WASD: TAB MOVEMENTS
map("w", "x"); // close tab
map("m", "x"); // close tab
mapkey("s", "Copy URL & close tab", async () => {
	const url = window.location.href;
	await copyAndNotify(url);
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
map("yi", ";di", null, "Download Image");
mapkey("ym", "Copy Markdown Link", async () => {
	const mdLink = `[${document.title}](${window.location.href})`;
	await copyAndNotify(mdLink);
});

mapkey("yy", "Copy Link", async () => {
	// custom function for notification-shortening
	await copyAndNotify(window.location.href);
});

// MISC
mapkey("P", "Incognito window", () => RUNTIME("openIncognito", { url: window.location.href }));
map("p", "<Alt-p>", null, "Pin Tab");
mapkey("i", "Passthrough", () => Normal.PassThrough(1000));
map("x", "<Alt-s>", null, "Start/Pause Surfingkeys");

// HACK open config via hammerspoon, as browser is sandboxed and cannot open files
mapkey(",", "Open Surfingkeys config", () => window.open("h"));

//──────────────────────────────────────────────────────────────────────────────
// VISUAL MODE
map("-", "/");

vmapkey("s", "Search Selection with Google", () =>
	searchSelectedWith("https://www.google.com/search?q="),
);

//──────────────────────────────────────────────────────────────────────────────
// SITE-SPECIFIC SETTINGS

// Google extensions
unmap("j", /google.com/); // websearch navigator
unmap("k", /google.com/); // websearch navigator
unmap("c", /google.com/); // Grepper

for (const key of ["h", "j", "k", "l", "f", "i", "t", "N", "P"]) {
	unmap(key, /youtube.com/);
}

// for BetterTouchTool Mappings
unmap("f", /crunchyroll.com/);
unmap("N", /crunchyroll.com/);

// cheatsheets on those websites
unmap("?", /(github|reddit|youtube).com|devdocs.io/);

// biome-ignore lint/suspicious/noEmptyBlockStatements: intentional to disable
mapkey("<Esc>", "Disable", () => {}, { domain: /devdocs\.io/ });

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

mapkey(
	"yg",
	"Copy GitHub Link",
	async () => {
		const url = window.location.href;
		const [_, repo] = url.match(/https:\/\/github\.com\/(.*?\/[^/?]*)/) || [];
		await copyAndNotify(repo);
	},
	{ domain: /github\.com/ },
);
mapkey(
	"gI",
	"Open GitHub issues",
	() => {
		const url = window.location.href;
		const [_, repo] = url.match(/https:\/\/github\.com\/(.*?\/[^/]*)/) || [];
		window.location.href = `https://github.com/${repo}/issues`;
	},
	{ domain: /github\.com/ },
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
