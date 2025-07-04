// @ts-nocheck // using pure javascript without the whole toolchain here
//──────────────────────────────────────────────────────────────────────────────
// biome-ignore lint: unneeded since available in Obsidian 
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
		this.app.commands.executeCommandById("editor:save-file"); // triggers linter for frontmatter
		this.app.commands.executeCommandById("workspace:edit-file-title"); // rename
	}
}

async function updateTaskStatusbarAndFrontmatter(plugin) {
	const { app, taskStatusbar } = plugin;
	const activeFile = app.workspace.getActiveFile();
	if (!activeFile) {
		taskStatusbar.style.setProperty("display", "none");
		return;
	}

	const listItems = app.metadataCache.getFileCache(activeFile).listItems || [];
	const openTasks = listItems.filter((item) => item.task === " ").length;

	app.fileManager.processFrontMatter(activeFile, (fm) => {
		fm["open-tasks"] = openTasks > 0 ? openTasks : undefined;
	});
	if (openTasks > 0) {
		taskStatusbar.style.setProperty("display", "block");
		taskStatusbar.style.setProperty("order", -1); // move to the left
		taskStatusbar.setText(`${openTasks} t`);
	} else {
		taskStatusbar.style.setProperty("display", "none");
	}
}

function updateSpellStatusbar(plugin) {
	const { app, spellStatusbar } = plugin;
	if (app.vault.getConfig("spellcheck")) {
		spellStatusbar.style.setProperty("display", "block");
		spellStatusbar.style.setProperty("order", -2); // move to the *very* left
		spellStatusbar.setText("✓"); // utf checkmarks
	} else {
		spellStatusbar.style.setProperty("display", "none");
	}
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

function ensureScrolloffset(editor) {
	const distancePercent = 0.4; // CONFIG

	if (!editor.hasFocus()) return;
	const cursor = editor.getCursor();
	const cursorOffSet = editor.posToOffset(cursor);
	const cursorCoord = editor.cm.coordsAtPos(cursorOffSet);
	if (!cursorCoord) return; // cursor is outside viewport, e.g., due to mouse-scrolling

	const viewportHeight = editor.getScrollInfo().clientHeight;
	const viewportTop = editor.getScrollInfo().top;
	const excessAtTop = viewportHeight * distancePercent - cursorCoord.top;
	const excessAtBottom = cursorCoord.bottom - viewportHeight * (1 - distancePercent);
	if (excessAtTop > 0) {
		// INFO editor.scrollTo()'s y is referring to the top of `.cm-scroller`
		// which can be retrieved from editor.getScrollInfo().top. It's an
		// absolute value marking the top of the file (beyond the viewport).
		editor.scrollTo(null, viewportTop - excessAtTop);
	}
	if (excessAtBottom > 0) {
		editor.scrollTo(null, viewportTop + excessAtBottom);
	}
}

//──────────────────────────────────────────────────────────────────────────────

class StartupActionsPlugin extends obsidian.Plugin {
	tasksAreUpdating = false;
	taskStatusbar = this.addStatusBarItem();
	spellStatusbar = this.addStatusBarItem();
	scrollRef = null;

	onload() {
		console.info(this.manifest.name + " loaded.");

		// 1a. statusbar: tasks
		this.app.workspace.onLayoutReady(() => updateTaskStatusbarAndFrontmatter(this));
		this.registerEvent(
			this.app.workspace.on("file-open", () => updateTaskStatusbarAndFrontmatter(this)),
		);
		this.registerEvent(
			this.app.metadataCache.on("resolved", () => updateTaskStatusbarAndFrontmatter(this)),
		);

		// 1b. statusbar: spellcheck
		this.app.workspace.onLayoutReady(() => updateSpellStatusbar(this));
		this.registerEvent(this.app.vault.on("config-changed", () => updateSpellStatusbar(this)));

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
		// use via: obsidian://reload-plugin?id=plugin_id&vault=vault_name
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
		this.registerEvent(this.app.workspace.on("editor-selection-change", ensureScrolloffset));
	}
}

//──────────────────────────────────────────────────────────────────────────────
module.exports = StartupActionsPlugin;
