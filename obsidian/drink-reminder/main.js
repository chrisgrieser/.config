// @ts-nocheck // using pure javascript without the whole toolchain here
const obsidian = require("obsidian");
//------------------------------------------------------------------------------

const SETTINGS = {
	intervalSecs: 3600, // 1 hour
};

//------------------------------------------------------------------------------

class DrinkReminderPlugin extends obsidian.Plugin {
	progressStatusbar = this.addStatusBarItem();

	onload() {
		console.info(this.manifest.name + " loaded.");

		setInterval(() => new Notice("Drink water!"), SETTINGS.intervalSecs);
	}
}

module.exports = DrinkReminderPlugin;
