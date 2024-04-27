// INFO these are globally available in jsfiles used by the Obsidian vimrc plugin
// see https://github.com/esm7/obsidian-vimrc-support?tab=readme-ov-file#jscommand---jsfunction

declare type EditorPosition = { ch: number; line: number };
declare type EditorRange = { from: EditorPosition; to: EditorPosition };

declare type Editor = {
	exec(action: string): void;
	getCursor(): EditorPosition;
	wordAt(EditorPosition): EditorRange;
	getValue(): string;
	setValue(value: string): void;
	getFoldOffsets(): number[];
	getLine(line: number): string;
	replaceSelection(value: string): void;
	setSelection(anchor: EditorPosition, head: EditorPosition): void;
	offsetToPos(offset: number): EditorPosition;
};

declare const selection: EditorRange;

declare const editor: Editor;

declare const view: {
	editor: Editor;
	app: {
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
		};
		openWithDefaultApp(path: string): void;
		vault: {
			getConfig(key: string): boolean | string | number;
			setConfig(key: string, value: boolean | string | number): void;
			configDir: string;
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
	};
};

declare class Notice {
	constructor(msg: string, duration?: number);
}
