// https://code.visualstudio.com/docs/nodejs/working-with-javascript#_global-variables-and-type-checking
// https://www.typescriptlang.org/docs/handbook/declaration-files/by-example.html
// https://github.com/JXA-userland/JXA/tree/master/packages/%40jxa/types/src
//──────────────────────────────────────────────────────────────────────────────

declare class macAppObj {
	includeStandardAdditions: boolean;
	openLocation(url: string): void;
	open(path: string): void;
	id(): number;
	name(): string;
	running(): boolean;
	frontmost(): boolean;
	activate(): void;
	quit(): void;
	launch(): void;
}

declare function Path(filepath: string): object;

declare const Application: {
	currentApplication: () => {
		doShellScript(script: string): string;
		includeStandardAdditions: boolean;
		openLocation(url: string): void;
		pathTo(what: "home folder"): string;
		read(path: string): string;
		setTheClipboardTo(str: string): void;
		theClipboard(): string;
		displayNotification(textToShow: string, options: { withTitle: string; subtitle: string }): void;
		displayDialog(
			textToShow: string,
			options: {
				defaultAnswer: string;
				buttons: string[];
				defaultButton: string;
				withIcon?: string;
				gaveUp?: boolean;
			},
		): {
			textReturned: string;
			buttonReturned: string;
		};
	};
	(name: "System Events"): macAppObj & {
		keystroke(key: string, modifiers?: { using: string[] });
		// rome-ignore lint/suspicious/noExplicitAny: TODO
		applicationProcesses: any;
		// rome-ignore lint/suspicious/noExplicitAny: TODO
		processes: any;
	};
	(name: "Reminders"): macAppObj & {
		defaultList(): { make(any) };
	};
	(name: "Finder"): macAppObj & {
		// paths need to be wrapped for Finder: `Path(str)`
		exists(wrappedPath: object): boolean;
		open (wrappedPath: object): void;
		reveal (wrappedPath: object): void; 
		finderWindows: {
			target: { url: () => string };
		};
	};
	(name: "SideNotes"): macAppObj & {
		currentNote(): {
			content(): string;
			title(): string;
			delete(): void;
		};
		createNote(options: macAppObj & {
			text: string;
			path?: string;
			// rome-ignore lint/suspicious/noExplicitAny: todo
			folder?: any;
			ispath?: boolean;
		}): void;
		folders: {
			byName(folderName: string): Object;
			length: number;
		};
	};
	(name: "Alfred"|"com.runningwithcrayons.Alfred"): macAppObj & {
		setConfiguration(envVar: string, options: Object): void;
		revealWorkflow(workflowId: string): void; // workflow id = name of workflow folder
	};
	(name: "Safari" | "Webkit"): macAppObj & {
		documents: { url(): string; name(): string }[];
	};
	(
		name: "Google Chrome" | "Chromium" | "Opera" | "Vivaldi" | "Brave Browser" | "Microsoft Edge" | "Arc",
	): macAppObj & {
		documents: { url(): string; name(): string }[];
	};
	(name: string): macAppObj;
};

//──────────────────────────────────────────────────────────────────────────────

declare const ObjC: {
	import: (package: "stdlib" | "Foundation") => void;
	unwrap: (string: string) => string;
};

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
	// rome-ignore lint/suspicious/noExplicitAny: too long
	NSURL: any;
	// rome-ignore lint/suspicious/noExplicitAny: too long
	NSString: any;
	// rome-ignore lint/suspicious/noExplicitAny: too long
	NSData: any;
};
