// https://code.visualstudio.com/docs/nodejs/working-with-javascript#_global-variables-and-type-checking
// https://www.typescriptlang.org/docs/handbook/declaration-files/by-example.html
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
			options: {
				defaultAnswer: string;
				buttons: string[];
				defaultButton: string;
			},
		): { textReturned: string };
	};
	(appname: string): {
		exists(path: string): boolean; // Finder
		createNote({ text: string }): void; // SideNotes
	};
};

declare function Path(filepath: string): string;

declare function delay(seconds: number): void;

// requires `ObjC.import("stdlib")`
declare const $: {
	getenv: (envVar: string) => string;
	NSFileManager: Object;
	NSUTF8StringEncoding: Object;
	NSFileModificationDate: Object;
	NSProcessInfo: Object;
	NSURL: string;
	// rome-ignore lint/suspicious/noExplicitAny: <explanation>
	NSString: any;
	NSData: string;
};
