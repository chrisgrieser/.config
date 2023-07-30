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

	menuBars: {
		menuBarItems: {
			byName(menuName: string): {
				menuItems: {
					byName(itemName: string): {
						click(): void;
					};
				};
			}[];
		};
	}[];
}

declare class SideNotesFolder {
	notes: SideNotesNote[];
}
declare class SideNotesNote {
	content(): string;
	title(): string;
	delete(): void;
	text(): string;
}

declare class finderItem {
	creationDate: Date;
	modificationDate: Date;
	name: string; // basename
	nameExtension: string;
	kind: string;
	size: number;
	url: string; // file-url, contains file-path
}

// rome-ignore lint/suspicious/noExplicitAny: no idea how to see the actual type
declare type PathObj = any;
declare function Path(filepath: string): PathObj;

declare const Application: {
	currentApplication: () => {
		doShellScript(script: string): string;
		includeStandardAdditions: boolean;
		openLocation(url: string): void;
		pathTo(what: "home folder"): string;
		read(path: string): string;
		setTheClipboardTo(str: string): void;
		theClipboard(): string;
		displayNotification(textToShow: string, options: { withTitle: string; subtitle?: string }): void;
		displayAlert(
			textToShow: string,
			options?: {
				message?: string;
				defaultAnswer?: string;
				buttons?: string[];
				defaultButton?: string;
				withIcon?: string;
				gaveUp?: boolean;
			},
		): {
			textReturned: string;
			buttonReturned: string;
		};
		displayDialog(
			textToShow: string,
			options?: {
				message?: string;
				defaultAnswer?: string;
				buttons?: string[];
				defaultButton?: string;
				withIcon?: string;
				gaveUp?: boolean;
			},
		): {
			textReturned: string;
			buttonReturned: string;
		};
	};
	(name: "System Events"): macAppObj & {
		aliases: finderItem[]; // hashmap of all paths, e.g. .aliases["/some/path/file.txt"]
		keystroke(key: string, modifiers?: { using: string[] });
		keyCode(keycode: number, modifiers?: { using: string[] });
		// rome-ignore lint/suspicious/noExplicitAny: later
		applicationProcesses: any;
		// rome-ignore lint/suspicious/noExplicitAny: later
		processes: any;
	};
	(name: "Reminders"): macAppObj & {
		defaultList(): {
			make(any);
			// rome-ignore lint/suspicious/noExplicitAny: later
			reminders: any;
		};
	};
	(name: "Finder"): macAppObj & {
		// PathObj and finderItems are not the same, but are apparently both accepted
		exists(path: PathObj | finderItem): boolean;
		open(path: PathObj | finderItem): void;
		reveal(path: PathObj | finderItem): void;
		select(path: PathObj | finderItem | PathObj[] | finderItem[]): void;
		selection(): finderItem[];
		finderWindows: undefined | { target: finderItem }; // undefined if Finder is not fromtmost
	};
	(name: "SideNotes"): macAppObj & {
		currentNote(): SideNotesNote;
		createNote(options: {
			text: string;
			path?: string;
			folder?: SideNotesFolder;
			ispath?: boolean;
		}): void;
		open(noteOrFolder: SideNotesNote | SideNotesFolder): void;
		folders: {
			byName(folderName: string): SideNotesFolder;
		};
	};
	(name: "Alfred" | "com.runningwithcrayons.Alfred"): macAppObj & {
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
	import: (package: "stdlib" | "Foundation"| "AppKit") => void;
	unwrap: (string: string) => string;
};

declare function delay(seconds: number): void;

declare const $: {
	// requires `ObjC.import("AppKit")`
	// rome-ignore lint/suspicious/noExplicitAny: too long
	NSPasteboard: any;
	// rome-ignore lint/suspicious/noExplicitAny: too long
	NSFilenamesPboardType: any;
	// rome-ignore lint/suspicious/noExplicitAny: too long
	(paths: string[]): any;

	// requires `ObjC.import("stdlib")`
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
