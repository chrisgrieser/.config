// @ts-nocheck // using pure javascript without the whole toolchain here
const obsidian = require("obsidian");
//──────────────────────────────────────────────────────────────────────────────

const config = {
	opacity: {
		light: 0.93,
		dark: 0.88,
	},
};

function setOpacity() {
	const isDarkMode = document.body.hasClass("theme-dark");
	const opacityValue = config.opacity[isDarkMode ? "dark" : "light"];
	electronWindow.setOpacity(opacityValue);
}

class StartupActionsPlugin extends obsidian.Plugin {
	onload() {
		console.info(this.manifest.name + " loaded.");

		// OPACITY, depending on dark/light mode
		if (!this.app.isMobile) {
			setOpacity();
			this.registerEvent(this.app.workspace.on("css-change", () => setOpacity()));
		}

		// URI to reload a plugin
		this.registerObsidianProtocolHandler("reload-plugin", async (uriParams) => {
			const pluginId = uriParams?.id;
			if (!pluginId) {
				new Notice("No plugin ID provided.");
				return;
			}
			await this.app.plugins.disablePlugin(pluginId);
			await this.app.plugins.enablePlugin(pluginId);
			const pluginName = this.app.plugins.getPlugin(pluginId).manifest.name;

			// clear current notices
			const allNotices = activeDocument.body.getElementsByClassName("notice");
			for (const el of allNotices) el.hide();

			new Notice(`"${pluginName}" reloaded.`);
		});
	}
}

//──────────────────────────────────────────────────────────────────────────────
module.exports = StartupActionsPlugin;
