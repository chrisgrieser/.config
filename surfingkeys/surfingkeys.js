// DOCS
// - API https://github.com/brookhong/Surfingkeys/blob/master/docs/API.md
// - FAQ https://github.com/brookhong/Surfingkeys/wiki/FAQ
// - default mappings https://github.com/brookhong/Surfingkeys/blob/master/src/content_scripts/common/default.js
// - example configs https://github.com/brookhong/Surfingkeys/wiki/Example-Configurations
//──────────────────────────────────────────────────────────────────────────────

// biome-ignore format: too long
const { Normal, Hints, Front, imap, map, mapkey, vmapkey, unmap, aceVimMap, removeSearchAlias, searchSelectedWith, RUNTIME, imapkey } = api;
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
settings.startToShowEmoji = 1;
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

map("h", "S"); // history back/forward
map("l", "D");
map("H", "[["); // next/prev Page
map("L", "]]");
map("z", ";fs"); // change focussed element

// WASD: TAB MOVEMENTS
map("w", "x"); // close tab
map("m", "x"); // close tab
mapkey("s", "Copy URL & close tab", async () => {
	RUNTIME("closeTab"); // cannot use `window.close()` b/c `Scripts may close only the windows that were opened by them.`
	const url = window.location.href;
	await copyAndNotify(url);
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
//mapkey("gr", "Recent sites", () => Front.openOmnibar({ type: "RecentlyClosed" }));
mapkey("gr", "History", () => Front.openOmnibar({ type: "History" }));

mapkey("t", "Quick switcher open tabs", () => Front.openOmnibar({ type: "Tabs" }));

// WINDOW
map("<Ctrl-v>", "W", null, "Move to new Window (split via Hammerspoon)");
map("M", ";gw", null, "Merge Windows");

// Links
mapkey("F", "Open multiple links via hint", () => {
	Hints.create("", Hints.dispatchMouseClick, { active: false, tabbed: true, multipleHits: true });
});
map("c", ";U"); // Edit current URL

// YANK & CLIPBOARD
mapkey("o", "Open from clipboard", async () => {
	const clipb = await navigator.clipboard.readText();
	if (clipb.startsWith("http")) window.open(clipb);
	else banner("Not a URL");
});

map("yf", "ya", null, "Yank link (via hint)");
map("yc", "yq", null, "Yank codeblock");
map("ye", "yv", null, "Yank element");
map("yw", "yY", null, "Yank all tabs in window");
map("yi", ";di", null, "Download Image");
mapkey("ym", "Copy markdown link", async () => {
	const mdLink = `[${document.title}](${window.location.href})`;
	await copyAndNotify(mdLink);
});

// custom function for notification-shortening
mapkey("yy", "Copy link", async () => await copyAndNotify(window.location.href));

mapkey("yq", "Copy selection as quote", async () => {
	const selection = window.getSelection()?.toString();
	if (!selection) return;
	const mdBlockquote = selection.replace(/^/gm, "> ");
	const url = window.location.href;
	const cleanTitle = document.title.replace(/\|.*/, "");
	const quote = `${mdBlockquote}\n> [${cleanTitle}](${url})`;
	await copyAndNotify(quote);
});

// MISC
mapkey("P", "Incognito window", () => RUNTIME("openIncognito", { url: window.location.href }));
map("p", "<Alt-p>", null, "Pin Tab");
mapkey("i", "Passthrough", () => Normal.PassThrough(1000));
map("x", "<Alt-s>", null, "Start/Pause Surfingkeys");

// HACK open config via hammerspoon, as browser is sandboxed and cannot open files
mapkey(",", "Open Surfingkeys config", () => window.open("hammerspoon://open-surfingkeys-config"));

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

for (const key of ["j", "k", "f", "N", "P", "0"]) {
	unmap(key, /youtube.com/);
}

// for BetterTouchTool Mappings
unmap("f", /crunchyroll.com/); // fullscreen
unmap("N", /crunchyroll.com/); // next episode
unmap("0", /crunchyroll.com/); // beginning

// cheatsheets on those websites
unmap("?", /(github|reddit|youtube).com|devdocs.io/);

// biome-ignore lint/suspicious/noEmptyBlockStatements: intentional to disable
mapkey("<Esc>", "Disable", () => {}, { domain: /devdocs\.io|reddit\.com/ });
// biome-ignore lint/suspicious/noEmptyBlockStatements: intentional to disable
imapkey("<Esc>", "Disable", () => {}, { domain: /devdocs\.io|reddit\.com/ });

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
// UNMAP REMAINING STUFF

const unusedKeys = [
	"[[",
	"]]",
	"<Ctrl-i>",
]

const unusedAlias = ["b", "d", "g", "h", "w", "y", "s", "e"]

for (const key of unusedKeys) {
	unmap(key);
}
for (const alias of unusedAlias) {
	removeSearchAlias(alias);
}
