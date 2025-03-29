// @ts-nocheck // using pure javascript without the whole toolchain here
//──────────────────────────────────────────────────────────────────────────────
const obsidian = require("obsidian");
//──────────────────────────────────────────────────────────────────────────────

class NewFileInFolder extends obsidian.FuzzySuggestModal {
	activeFileDir = this.app.workspace.getActiveFile()?.path.replace(/\/[^/]+$/, "");

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
		const folders = this.app.vault
			.getAllFolders(false) // `false` = exclude vault root
			.filter((item) => {
				const excludedDir = this.app.vault.config.userIgnoreFilters.some((dir) => {
					if (dir.startsWith("/")) return item.path.match(new RegExp(dir.slice(1, -1)));
					return item.path.startsWith(dir); // non-regex dir
				});
				return !excludedDir;
			})
			.sort((a, b) => {
				if (a.path === this.activeFileDir) return -1;
				const depthA = a.path.split("/").length;
				const depthB = b.path.split("/").length;
				return depthA - depthB;
			});
		return folders;
	}

	getItemText(folder) {
		if (folder.path === this.activeFileDir) return folder.path + "  (📂 Current)";
		return folder.path;
	}

	async onChooseItem(folder) {
		let name = "Untitled";

		// ensure file name is unique
		while (true) {
			const fileAlreadyExists = this.app.vault.getFileByPath(`${folder.path}/${name}.md`);
			if (!fileAlreadyExists) break;
			name = name.replace(/\d*$/, (num) => {
				return num ? (Number.parseInt(num) + 1).toString() : " 1";
			});
		}

		// create, open, and rename
		const newFile = await this.app.vault.create(`${folder.path}/${name}.md`, "");
		await this.app.workspace.getLeaf().openFile(newFile);
		this.app.commands.executeCommandById("editor:save-file"); // trigger linter for frontmatter
		this.app.commands.executeCommandById("workspace:edit-file-title"); // rename
	}
}

async function updateStatusbar(plugin) {
	const { app, statusbar } = plugin;
	const activeFile = app.workspace.getActiveFile();
	if (!activeFile) {
		statusbar.style.setProperty("display", "none");
		return;
	}

	const text = await app.vault.cachedRead(activeFile);
	const openTasks = text.match(/- \[ \] |TODO/g);
	if (!openTasks) {
		statusbar.style.setProperty("display", "none");
		return;
	}

	statusbar.style.setProperty("display", "block");
	statusbar.style.setProperty("order", -1); // move to the very left
	statusbar.setText(`${openTasks.length} t`);
}

async function reloadPlugin(app, pluginId) {
	if (!pluginId) {
		new Notice("No plugin ID provided.");
		return;
	}
	await app.plugins.disablePlugin(pluginId);
	await app.plugins.enablePlugin(pluginId);

	console.clear();

	// clear current notices & post new notification
	const allNotices = activeDocument.body.getElementsByClassName("notice");
	for (const el of allNotices) el.hide();
	const pluginName = app.plugins.getPlugin(pluginId).manifest.name;
	new Notice(`"${pluginName}" reloaded.`);
}

function scrollIfNeeded(editor) {
	// biome-ignore lint/style/useNamingConvention: constant
	const DISTANCE_PERCENT = 30;

	if (!editor?.hasFocus()) return;
	const cursor = editor.getCursor()
	if (!cursor) return;
	const cursorOffSet = editor.posToOffset(cursor);
	const cursorCoord = editor.cm.coordsAtPos(cursorOffSet);
	if (!cursorCoord) return; // no coord = outside viewport

	const editorHeight = editor.getScrollInfo().clientHeight;
	const relativeCursorTop = Math.round((cursorCoord.top / editorHeight) * 100);
	if (relativeCursorTop < DISTANCE_PERCENT || relativeCursorTop > 100 - DISTANCE_PERCENT) {
		console.log("🪚 relativeCursorTop:", relativeCursorTop);
		editor.scrollIntoView({ from: cursor, to: cursor }, true);
	}
}

//──────────────────────────────────────────────────────────────────────────────

class StartupActionsPlugin extends obsidian.Plugin {
	statusbar = this.addStatusBarItem();

	onload() {
		console.info(this.manifest.name + " loaded.");

		// 1. statusbar
		this.app.workspace.onLayoutReady(() => updateStatusbar(this));
		this.registerEvent(this.app.workspace.on("file-open", () => updateStatusbar(this)));
		this.registerInterval(window.setInterval(() => updateStatusbar(this), 3000));

		// 2. "New file in folder" command
		this.addCommand({
			id: "new-file-in-folder",
			name: "New file in folder",
			icon: "file-plus",
			callback: () => new NewFileInFolder(this.app).open(),
		});

		// 3. hide window buttons
		if (!this.app.isMobile) electronWindow.setWindowButtonVisibility(false);

		// 4. register URIs
		this.app.workspace.onLayoutReady(() => {
			this.registerObsidianProtocolHandler("reload-plugin", async (uriParams) => {
				const pluginId = uriParams?.id;
				await reloadPlugin(this.app, pluginId);
			});

			this.registerObsidianProtocolHandler("reload-vault", () => {
				this.app.commands.executeCommandById("app:reload");
			});
		});

		// 5. scroll offset
		// "editor-selection-change" triggers on cursor movement
		this.app.workspace.on("editor-selection-change", (editor) => scrollIfNeeded(editor));
	}
}

//──────────────────────────────────────────────────────────────────────────────
module.exports = StartupActionsPlugin;
