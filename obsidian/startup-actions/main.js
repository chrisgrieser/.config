// @ts-nocheck // using pure javascript without the whole toolchain here
const obsidian = require("obsidian");

//──────────────────────────────────────────────────────────────────────────────

// CONFIG
const opacity = {
	light: 0.93,
	dark: 0.9,
};

//──────────────────────────────────────────────────────────────────────────────

class NewFileInFolder extends obsidian.FuzzySuggestModal {
	constructor(app) {
		super(app);
		this.setPlaceholder("Select folder to create new file in…");

		// navigate via `Tab` and `Shift-tab`
		this.scope.register([], "Tab", () => {
			document.dispatchEvent(new KeyboardEvent("keydown", { key: "ArrowDown" }));
		});
		this.scope.register(["Shift"], "Tab", () => {
			document.dispatchEvent(new KeyboardEvent("keydown", { key: "ArrowUp" }));
		});
	}

	getItems() {
		const excluded = this.app.vault.config.userIgnoreFilters;
		const folders = this.app.vault
			.getAllLoadedFiles()
			.filter((item) => {
				if (item.extension) return false; // not folder
				const rootDir = !item.parent;
				const excludedDir = excluded.some((dir) => {
					if (dir.startsWith("/")) return item.path.match(new RegExp(dir.slice(1, -1)));
					return item.path.startsWith(dir); // non-regex dir
				});
				return !rootDir && !excludedDir;
			})
			.sort((a, b) => {
				// by depth, then alphabetically
				const depthA = a.path.split("/").length;
				const depthB = b.path.split("/").length;
				return depthA - depthB || a.path.localeCompare(b.path);
			});
		return folders;
	}

	getItemText(folder) {
		return folder.path;
	}

	async onChooseItem(folder) {
		let name = "Untitled";
		while (true) {
			const fileAlreadyExists = this.app.vault.getFileByPath(`${folder.path}/${name}.md`);
			if (!fileAlreadyExists) break;
			name = name.replace(/\d*$/, (num) => {
				return num ? (Number.parseInt(num) + 1).toString() : " 1";
			});
		}
		const newFile = await this.app.vault.create(`${folder.path}/${name}.md`, "");
		await this.app.workspace.getLeaf().openFile(newFile);

		this.app.commands.executeCommandById("workspace:edit-file-title"); // rename
		this.app.commands.executeCommandById("editor:save-file"); // trigger linter for template
	}
}

async function updateStatusbar(plugin) {
	const { app, statusbarTaskCounter } = plugin;
	const activeFile = app.workspace.getActiveFile();
	if (!activeFile) {
		statusbarTaskCounter.style.cssText = "display: none";
		return;
	}

	const text = await app.vault.cachedRead(activeFile);
	const totalTasks = text.match(/^\s*- \[[x ]\] /gm)?.length;
	if (!totalTasks) {
		statusbarTaskCounter.style.cssText = "display: none";
		return;
	}
	const openTasks = text.match(/^\s*- \[ \]/gm)?.length || 0;

	statusbarTaskCounter.style.cssText = "display: block";
	statusbarTaskCounter.setText(`${openTasks}/${totalTasks} [x]`);
}

//──────────────────────────────────────────────────────────────────────────────

class StartupActionsPlugin extends obsidian.Plugin {
	statusbarTaskCounter = this.addStatusBarItem();

	onload() {
		console.info(this.manifest.name + " loaded.");

		this.registerEvent(this.app.workspace.on("file-open", () => updateStatusbar(this)));
		// initialize
		this.app.workspace.onLayoutReady(() => {
			updateStatusbar(this);
		});

		this.addCommand({
			id: "new-file-in-folder",
			name: "New file in folder",
			icon: "file-plus",
			callback: () => new NewFileInFolder(this.app).open(),
		});

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

		this.app.workspace.onLayoutReady(() => {
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

				// biome-ignore lint/suspicious/noConsole: intentional here
				console.clear();

				// clear current notices
				const allNotices = activeDocument.body.getElementsByClassName("notice");
				for (const el of allNotices) el.hide();

				new Notice(`"${pluginName}" reloaded.`);
			});

			this.registerObsidianProtocolHandler("reload-vault", () => {
				this.app.commands.executeCommandById("app:reload");
			});
		});
	}
}

//──────────────────────────────────────────────────────────────────────────────
module.exports = StartupActionsPlugin;
