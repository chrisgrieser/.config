// https://code.visualstudio.com/docs/nodejs/working-with-javascript#_global-variables-and-type-checking
// https://www.typescriptlang.org/docs/handbook/declaration-files/by-example.html
// https://github.com/JXA-userland/JXA/tree/master/packages/%40jxa/types/src
//──────────────────────────────────────────────────────────────────────────────

declare class MacAppObj {
	includeStandardAdditions: boolean;
	openLocation(url: string): string;
	open(path: string): void;
	id(): number;
	name(): string;
	running(): boolean;
	frontmost(): boolean;
	activate(): void;
	quit(): void;
	launch(): void;
	properties(): object; // inspect all properties
	theClipboard(): string;

	menuBars: {
		menuBarItems: {
			byName(menuName: string): {
				menus: {
					menuItems: {
						byName(itemName: string): {
							click(): void;
						};
					};
				}[];
			};
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
	id(): string;
}

declare class FinderItem {
	creationDate(): Date;
	modificationDate(): Date;
	name(): string; // basename
	nameExtension(): string;
	kind(): string;
	size(): number;
	url(): string; // file-url, contains file-path
	properties(): object; // inspect all properties
	exists(): boolean;
}

// DOCS https://developer.apple.com/library/archive/releasenotes/InterapplicationCommunication/RN-JavaScriptForAutomation/Articles/OSX10-10.html
declare type PathObj = {
	toString(): string;
};
declare function Path(filepath: string): PathObj;

declare const Application: {
	currentApplication: () => {
		doShellScript(script: string): string; // DOCS https://developer.apple.com/library/archive/technotes/tn2065/_index.html
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
	(name: "System Events"): MacAppObj & {
		aliases: FinderItem[]; // hashmap of all paths, e.g. .aliases["/some/path/file.txt"]
		keystroke(key: string, modifiers?: { using: string[] });
		keyCode(keycode: number, modifiers?: { using: string[] });
		// biome-ignore lint/suspicious/noExplicitAny: later
		applicationProcesses: any;
		// biome-ignore lint/suspicious/noExplicitAny: later
		processes: any;
	};
	(name: "Reminders"): MacAppObj & {
		defaultList(): {
			make(any);
			// biome-ignore lint/suspicious/noExplicitAny: later
			reminders: any;
		};
	};
	(name: "Finder"): MacAppObj & {
		// PathObj and finderItems are not the same, but are apparently both accepted
		exists(path: PathObj): boolean;
		open(path: PathObj): void;
		reveal(path: PathObj): void;
		// accepts arrays only for *files*?! https://github.com/chrisgrieser/finder-vim-mode/issues/3
		select(path: PathObj | PathObj[]): void;
		selection(): PathObj[];
		finderWindows: { target: FinderItem };
		insertionLocation(): FinderItem;
		// https://medium.com/hackernoon/javascript-for-automation-in-macos-3b499da40da1
		make(options: {
			new: "folder" | "file";
			at: PathObj;
			withProperties: { name: string };
		}): FinderItem;
	};
	(name: "SideNotes"): MacAppObj & {
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
		}&SideNotesFolder[];
	};
	(name: "Alfred" | "com.runningwithcrayons.Alfred"): MacAppObj & {
		// biome-ignore lint/complexity/noBannedTypes: <explanation>
		setConfiguration(envVar: string, options: Object): void;
		revealWorkflow(workflowId: string): void; // workflow id = name of workflow folder
	};
	(name: "Safari" | "Webkit"): MacAppObj & {
		documents: { url(): string; name(): string }[];
	};
	(
		name: "Google Chrome" | "Chromium" | "Opera" | "Vivaldi" | "Brave Browser" | "Microsoft Edge" | "Arc",
	): MacAppObj & {
		documents: { url(): string; name(): string }[];
	};
	(name: string): MacAppObj;
};

//──────────────────────────────────────────────────────────────────────────────

declare const ObjC: {
	import: (package: "stdlib" | "Foundation" | "AppKit") => void;
	unwrap: (string: string) => string;
};

declare function delay(seconds: number): void;

declare const $: {
	// requires `ObjC.import("AppKit")`
	// biome-ignore lint: not set by me
	NSPasteboard: any;
	// biome-ignore lint: not set by me
	NSFilenamesPboardType: any;
	// biome-ignore lint: not set by me
	(paths: string[]): any;

	// requires `ObjC.import("stdlib")`
	getenv: (envVar: string) => string;
	// biome-ignore lint: not set by me
	NSFileManager: any;
	// biome-ignore lint: not set by me
	NSUTF8StringEncoding: any;
	// biome-ignore lint: not set by me
	NSFileModificationDate: any;
	// biome-ignore lint: not set by me
	NSProcessInfo: any;
	// biome-ignore lint: not set by me
	NSURL: any;
	// biome-ignore lint: not set by me
	NSString: any;
	// biome-ignore lint: not set by me
	NSData: any;
};
