// Trigger on `Alt+T`
document.querySelector("body")?.addEventListener("keydown", (event) => {
	if (!(event.altKey && event.key === "t")) return;

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
	navigator.clipboard.writeText(mdTimestamp);
});
