// ==UserScript==
// @name        Copy Link to Text Fragment
// @namespace   Violentmonkey Scripts
// @match       *://*/*
// @version     1.0
// @author      pseudometa
// @description 2024-10-27
// ==/UserScript==

// DOCS https://developer.mozilla.org/en-US/docs/Web/API/KeyboardEvent
document.addEventListener("keydown", (event) => {
	if (!(event.key === "y" && event.ctrlKey)) return;
	event.preventDefault();

	// DOCS https://developer.mozilla.org/en-US/docs/Web/URI/Fragment/Text_fragments
	const selection = window.getSelection().toString();
	const encodedSel = encodeURIComponent(selection).replaceAll("%0A", "&text="); // Replaces newlines with new fragment
	const url = window.location.href;
	const textFragementLink = url + "#:~:text=" + encodedSel;
	navigator.clipboard.writeText(textFragementLink);
	alert("Copied: " + textFragementLink);
});

