// @ts-nocheck // using pure javascript without the whole toolchain here
const obsidian = require("obsidian");

//──────────────────────────────────────────────────────────────────────────────

// CONFIG

const opacity= {
	light: 0.93,
	dark: 0.90,
}

//──────────────────────────────────────────────────────────────────────────────

class PluginSettings extends obsidian.FuzzySuggestModal {
	constructor(app) {
		super(app);
		this.setPlaceholder("Search settings tabs…");

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
			{ id: "plugins", name: "Core plugins" },
			{ id: "community-plugins", name: "Community plugins" },
		];

		const corePluginsWithSettings = [];
		const corePlugins = this.app.internalPlugins.plugins;
		for (const [id, plugin] of Object.entries(corePlugins)) {
			if (!plugin.enabled || !plugin.instance.options) continue;
			corePluginsWithSettings.push({ id: id, name: plugin.instance.name });
		}
		corePluginsWithSettings.sort((a, b) => a.name.localeCompare(b.name));

		const communityPluginsWithSettings = [];
		const enabledCommunityPlugins = this.app.plugins.plugins;
		for (const [id, plugin] of Object.entries(enabledCommunityPlugins)) {
			if (!(plugin.settings || plugin.settingsList)) continue;
			communityPluginsWithSettings.push({ id: id, name: plugin.manifest.name });
		}
		communityPluginsWithSettings.sort((a, b) => a.name.localeCompare(b.name));

		return [...settingsTabs, ...corePluginsWithSettings, ...communityPluginsWithSettings];
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

		// OPACITY, depending on dark/light mode
		if (!this.app.isMobile) {
			function setOpacity() {
				const isDarkMode = document.body.hasClass("theme-dark");
				const opacityValue = opacity[isDarkMode ? "dark" : "light"];
				electronWindow.setOpacity(opacityValue);
			}
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

		this.addCommand({
			id: "open-plugin-settings",
			name: "Open plugin settings",
			icon: "cog",
			callback: () => new PluginSettings(this.app).open(),
		});
	}
}

//──────────────────────────────────────────────────────────────────────────────
module.exports = StartupActionsPlugin;
