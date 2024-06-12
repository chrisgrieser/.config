declare const settings: {
	richHintsForKeystroke: number;
	hintShiftNonActive: boolean;
	modeAfterYank: string;
	caseSensitive: boolean;
	smartCase: boolean;
	enableEmojiInsertion: boolean;
	startToShowEmoji: number;
	theme: string;
};

//──────────────────────────────────────────────────────────────────────────────

// DOCS https://github.com/brookhong/Surfingkeys/blob/master/docs/API.md
declare const api: SurfingKeysAPI;
declare type SurfingKeysAPI = {
	Normal: {
		PassThrough(delay: number): void;
		feedkeys(keys: string): void;
	};
	Hints: {
		style(style: string): void;
	};
	Front: {
		showBanner(text: string): void;
		openOmnibar(options: object): void;
	};
	imap: (keys: string, jscode: string, scope?: RegExp, description?: string) => void;
	map: (keys: string, jscode: string, scope?: RegExp, description?: string) => void;
	unmap: (keys: string, scope?: RegExp) => void;
	removeSearchAlias: (alias: string) => void;
	mapkey: (keys: string, description: string, jscode: () => void, scope?: RegExp) => void;
	vmapkey: (keys: string, description: string, jscode: () => void, scope?: RegExp) => void;
	imapkey: (keys: string, description: string, jscode: () => void, scope?: RegExp) => void;
	aceVimMap: (keys: string, description: string, jscode: () => void, scope?: RegExp) => void;
	searchSelectedWith;
	RUNTIME;
};
