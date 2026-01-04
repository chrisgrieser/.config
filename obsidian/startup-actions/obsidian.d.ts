// OBSIDIAN
declare class Notice {
	constructor(msg: string, duration?: number);
	setMessage(msg: string): void;
}

// ELECTRON
declare const process: { versions: Record<string, string> };
declare const electronWindow: { openDevTools(): void };
// biome-ignore lint/suspicious/noExplicitAny: Electron DOM
declare const activeDocument: any;
// biome-ignore lint/suspicious/noExplicitAny: Electron window
declare const activeWindow: any;

// NODE
declare const request: (url: string) => Promise<string>; // https://docs.obsidian.md/Reference/TypeScript+API/request

