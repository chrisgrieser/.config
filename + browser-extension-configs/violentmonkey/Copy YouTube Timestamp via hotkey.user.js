// ==UserScript==
// @name        Copy YouTube Timestamp via hotkey
// @namespace   Violentmonkey Scripts
// @match       *://*.youtube.com/watch?v=*
// @version     1.0
// @author      pseudometa
// @icon        https://cdn-icons-png.flaticon.com/512/3670/3670147.png
// ==/UserScript==


//──────────────────────────────────────────────────────────────────────────────
document.addEventListener("keydown", async (event) => {
	if (!(event.ctrlKey && event.key === "t")) return;
	event.preventDefault();

	const timestamp = document.querySelector(".ytp-time-current")?.innerHTML;
	if (!timestamp) {
		alert("No timestamp found.");
		return;
	}

	// calculate total seconds as youtube uses that
	const time = timestamp.split(":");
	const ss = Number.parseInt(time.pop() || "0");
	const mm = Number.parseInt(time.pop() || "0");
	const hh = Number.parseInt(time.pop() || "0");
	const totalSecs = 3600 * hh + 60 * mm + ss;

	const url = `${window.location.href}&t=${totalSecs}s`;
	const mdTimestamp = `[${timestamp}](${url})`;
	await navigator.clipboard.writeText(mdTimestamp);
});
