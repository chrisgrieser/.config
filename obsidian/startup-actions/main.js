// @ts-nocheck
const obsidian = require("obsidian");
//──────────────────────────────────────────────────────────────────────────────

// CONFIG
const config = {
	opacity: {
		light: 0.95,
		dark: 0.85,
	},
};

//──────────────────────────────────────────────────────────────────────────────

class StartupActionsPlugin extends obsidian.Plugin {
	onload() {
		console.log(this.manifest.name + " loaded.");

		// OPACITY, depending on dark/light mode
		this.registerEvent(
			this.app.workspace.on("css-change", () => {
				const isDarkMode = document.querySelector("body.theme-light");
				const opacityValue = config.opacity[isDarkMode ? "dark" : "light"];
				electronWindow.setOpacity(opacityValue);
			}),
		);

		// Plugin reload URI
		this.registerObsidianProtocolHandler("reload-plugin", async (uriParams) => {
			const pluginId = uriParams?.id;
			if (pluginId) {
				await app.plugins.disablePlugin(pluginId);
				await app.plugins.enablePlugin(pluginId);
				new Notice(`Reloaded ${pluginId}.`);
			}
		});
	}
}

//──────────────────────────────────────────────────────────────────────────────
module.exports = StartupActionsPlugin;
