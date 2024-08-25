// @ts-nocheck
const obsidian = require("obsidian");
//──────────────────────────────────────────────────────────────────────────────

class StartupActionsPlugin extends obsidian.Plugin {
	onload() {
		console.log("My Personal Startup Action Plugin loaded.");

		// OPACITY
		electronWindow.setOpacity(0.94);
		this.registerEvent(
			this.app.workspace.on("css-change", () => {
				console.log("css change triggered");
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
