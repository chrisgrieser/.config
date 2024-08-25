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

class PluginSettings extends obsidian.FuzzySuggestModal {
	// navigate via `Tab` and `Shift-tab`
	constructor(app) {
		super(app);
		this.scope.register([], "Tab", () => {
			document.dispatchEvent(new KeyboardEvent("keydown", { key: "ArrowDown" }));
		});
		this.scope.register(["Shift"], "Tab", () => {
			document.dispatchEvent(new KeyboardEvent("keydown", { key: "ArrowUp" }));
		});
	}

	getItems() {
		const record = this.app.plugins.plugins;
		const plugins = [];
		for (const id in record) {
			if (!record[id].settings && !record[id].manifest.settingsList) continue;
			plugins.push({ id: id, name: record[id].manifest.name });
		}
		return plugins;
	}

	getItemText(plugin) {
		return plugin.name;
	}

	onChooseItem(plugin, _event) {
		this.app.setting.open();
		this.app.setting.openTabById(plugin.id);
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
			id: "open-plugin-settings",
			name: "Open plugin settings",
			callback: () => new PluginSettings(this.app).open(),
		});
	}
}

//──────────────────────────────────────────────────────────────────────────────
module.exports = StartupActionsPlugin;
