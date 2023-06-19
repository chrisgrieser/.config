// https://code.visualstudio.com/docs/nodejs/working-with-javascript#_global-variables-and-type-checking
// https://www.typescriptlang.org/docs/handbook/declaration-files/by-example.html
// https://github.com/JXA-userland/JXA
//──────────────────────────────────────────────────────────────────────────────

declare const ObjC: {
	import: (package: "stdlib" | "Foundation") => void;
	unwrap: (string: string) => string;
};

declare const Application: {
	currentApplication: () => {
		doShellScript(script: string): string;
		includeStandardAdditions: boolean;
		openLocation(url: string): void;
		pathTo(what: "home folder"): string;
		read(path: string): string;
		setTheClipboardTo(str: string): void;
		displayDialog(
			textToShow: string,
			options: { defaultAnswer: string; buttons: string[]; defaultButton: string },
		): { textReturned: string };
		displayNotification(textToShow: string, options: { withTitle: string; subtitle: string }): void;
	};
	(appname: string): {
		includeStandardAdditions: boolean;
		openLocation(url: string): void;
		id(): number;
		name(): string;
		running(): boolean;
		frontmost(): boolean;
		activate(): void;
		quit(): void;
		launch(): void;

		// command names https://qiita.com/zakuroishikuro/items/a7def965f49a2ab55be4
		commandsOfClass(): string[];
		elementsOfClass(className: string): string[];
		propertiesOfClass(className: string): string[];
		parentOfClass(className: string): string;

		// app-specific
		exists(path: string): boolean; // Finder
		createNote(options: { text: string; path?: string }): void; // SideNotes
		documents: { url(): string; name(): string }[]; // webkit browsers
		windows: { activeTab: { url(): string; name(): string } }[]; // chromium browsers

		// rome-ignore lint/suspicious/noExplicitAny: TODO
		applicationProcesses: any; // System Events
	};
};

declare function Path(filepath: string): string;

declare function delay(seconds: number): void;

// requires `ObjC.import("stdlib")`
declare const $: {
	getenv: (envVar: string) => string;
	// rome-ignore lint/suspicious/noExplicitAny: too long
	NSFileManager: any;
	// rome-ignore lint/suspicious/noExplicitAny: too long
	NSUTF8StringEncoding: any;
	// rome-ignore lint/suspicious/noExplicitAny: too long
	NSFileModificationDate: any;
	// rome-ignore lint/suspicious/noExplicitAny: too long
	NSProcessInfo: any;
	NSURL: string;
	// rome-ignore lint/suspicious/noExplicitAny: too long
	NSString: any;
	NSData: string;
};
