// ==UserScript==
// @name        Disable <Esc> on reddit
// @namespace   Violentmonkey Scripts
// @match       https://*.reddit.com/r/*
// @version     1.0
// @author      pseudometa
// @description Prevent <esc> from going up to the subreddit (annoying for vimium users)
// @icon        https://www.redditstatic.com/desktop2x/img/favicon/android-icon-192x192.png
// ==/UserScript==

// DOCS https://developer.mozilla.org/en-US/docs/Web/API/KeyboardEvent
document.addEventListener("keydown", (event) => {
	if (event.key === "Escape") {
		event.preventDefault();
		event.stopPropagation();
		event.stopImmediatePropagation();
	}
});

