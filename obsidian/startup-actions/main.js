// @ts-nocheck
const obsidian = require("obsidian");
//──────────────────────────────────────────────────────────────────────────────

const config = {
	opacity: {
		light: 0.92,
		dark: 0.86,
	},
};

//──────────────────────────────────────────────────────────────────────────────

function setOpacity() {
	const isDarkMode = document.querySelector("body.theme-dark");
	const opacityValue = config.opacity[isDarkMode ? "dark" : "light"];
	electronWindow.setOpacity(opacityValue);
}

class ExampleModal extends obsidian.FuzzySuggestModal {
	getItems() {
		return [
			{ name: "Item 1", description: "Item 1 description" },
			{ name: "Item 2", description: "Item 2 description" },
		];
	}

	getItemText(plugin) {
		return plugin.name;
	}

	onChooseItem(plugin, _event) {
		new Notice(`Selected ${plugin.name}`);
	}
}

class StartupActionsPlugin extends obsidian.Plugin {
	onload() {
		console.log(this.manifest.name + " loaded.");
		const app = this.app;

		// OPACITY, depending on dark/light mode
		setOpacity();
		this.registerEvent(this.app.workspace.on("css-change", () => setOpacity()));

		// URI to reload a plugin
		this.registerObsidianProtocolHandler("reload-plugin", async (uriParams) => {
			const pluginId = uriParams?.id;
			if (pluginId) {
				await app.plugins.disablePlugin(pluginId);
				await app.plugins.enablePlugin(pluginId);
				new Notice(`Reloaded ${pluginId}.`);
			}
		});

		this.addCommand({
			id: "example-modal",
			name: "Open Example Modal",
			callback: () => {
				new ExampleModal(app).open();
			},
		});
	}
}

//──────────────────────────────────────────────────────────────────────────────
module.exports = StartupActionsPlugin;
