// OBSIDIAN VIMRC GLOBALS
// these are globally available in jsfiles used by the Obsidian vimrc plugin
// https://github.com/esm7/obsidian-vimrc-support?tab=readme-ov-file#jscommand---jsfunction
declare const selection: EditorSelection;
declare const editor: Editor;
declare const view: View;

declare class Notice {
	constructor(msg: string, duration?: number);
	setMessage(msg: string): void;
}

// ELECTRON GLOBALS
declare const process: { versions: Record<string, string> };
declare const electronWindow: { openDevTools(): void };
// biome-ignore lint/suspicious/noExplicitAny: Electron DOM
declare const activeDocument: any;
// biome-ignore lint/suspicious/noExplicitAny: Electron window
declare const activeWindow: any;

//──────────────────────────────────────────────────────────────────────────────

// INFO importing `obsidian.d.ts` somehow breaks the typings, thus manually
// declaring everything we need here 💀
declare type EditorPosition = { ch: number; line: number };
declare type EditorRange = { from: EditorPosition; to: EditorPosition };
declare type EditorSelection = { head: EditorPosition; anchor: EditorPosition };
declare type TFile = { path: string; name: string };

declare type Editor = {
	exec(action: string): void;
	getCursor(): EditorPosition;
	setCursor(pos: EditorPosition | number, ch?: number): void;
	wordAt(EditorPosition): EditorRange;
	lineCount(): number;
	getValue(): string;
	setValue(value: string): void;
	getFoldOffsets(): number[];
	getLine(line: number): string;
	setLine(line: number, text: string): void;
	replaceSelection(replacement: string): void;
	replaceRange(replacement: string, from: EditorPosition, to?: EditorPosition, origin?: string);
	setSelection(anchor: EditorPosition, head: EditorPosition): void;
	getSelection(): string;
	getRange(from: EditorPosition, to: EditorPosition): string;
	offsetToPos(offset: number): EditorPosition;
	posToOffset(pos: EditorPosition): number;
	// biome-ignore lint/suspicious/noExplicitAny: code mirror instance, mostly for vim mode
	cm: any;
};

declare type View = {
	file: {
		path: string;
		name: string;
	};
	app: {
		commands: {
			executeCommandById(id: string): void;
		};
		metadataCache: {
			getFirstLinkpathDest(linkpath: string, sourcePath: string): TFile | null;
			getFileCache(file: TFile): {
				headings: {
					heading: string;
					position: { start: EditorPosition };
				}[];
				blocks: Record<string, { position: { start: EditorPosition } }>;
				frontmatter: Record<string, string | number | boolean>;
			};
		};
		customCss: {
			theme: string;
			themes: Record<string, string>;
			oldThemes: string[];
			setTheme(theme: string): void;
		};
		workspace: {
			protocolHandlers: {
				get(protocol: string): ({ id: string }) => void;
			};
			getLeaf(): {
				openFile(file: TFile): Promise<void>;
			};
		};
		openWithDefaultApp(path: string): void;
		vault: {
			getConfig(key: string): boolean | string | number;
			setConfig(key: string, value: boolean | string | number): void;
			configDir: string;
			adapter: {
				getFullPath(path: string): string;
			};
			getFileByPath(path: string): TFile;
			getMarkdownFiles(): TFile[];
		};
		plugins: {
			checkForUpdates(): Promise<void>;
			updates: Record<string, object>;
		};
		setting: {
			open(): void;
			openTabById(id: string): void;
			// biome-ignore lint/suspicious/noExplicitAny: too long…
			activeTab: any;
		};
		internalPlugins: {
			plugins: {
				workspaces: {
					disable(): Promise<void>;
					enable(): Promise<void>;
					instance: {
						loadWorkspace(name: string): void;
						saveWorkspace(name: string): void;
					};
				};
			};
		};
	};
};
