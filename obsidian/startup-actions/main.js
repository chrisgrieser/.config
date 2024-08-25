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
	const isDarkMode = document.body.hasClass("theme-dark");
	const opacityValue = config.opacity[isDarkMode ? "dark" : "light"];
	electronWindow.setOpacity(opacityValue);
}

class PluginSettings extends obsidian.FuzzySuggestModal {
	constructor(app) {
		super(app);
		this.setPlaceholder("Search settings…");

		// navigate via `Tab` and `Shift-tab`
		this.scope.register([], "Tab", () => {
			document.dispatchEvent(new KeyboardEvent("keydown", { key: "ArrowDown" }));
		});
		this.scope.register(["Shift"], "Tab", () => {
			document.dispatchEvent(new KeyboardEvent("keydown", { key: "ArrowUp" }));
		});
	}

	getItems() {
		const settingsTabs = [
			{ id: "about", name: "General" },
			{ id: "file", name: "Files and links" },
			{ id: "editor", name: "Editor" },
			{ id: "appearance", name: "Appearance" },
			{ id: "hotkeys", name: "Hotkeys" },
			{ id: "core-plugins", name: "Core plugins" },
			{ id: "community-plugins", name: "Community plugins" },
		];

		const enabledCommunityPlugins = this.app.plugins.plugins;
		for (const [id, plugin] of Object.entries(enabledCommunityPlugins)) {
			if (!(plugin.settings || plugin.settingsList)) continue;
			settingsTabs.push({ id: id, name: plugin.manifest.name });
		}

		const corePlugins = this.app.internalPlugins.plugins;
		for (const [id, plugin] of Object.entries(corePlugins)) {
			if (!plugin.enabled || !plugin.instance.options) continue;
			settingsTabs.push({ id: id, name: plugin.instance.name });
		}
		return settingsTabs;
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
		console.info(this.manifest.name + " loaded.");
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
