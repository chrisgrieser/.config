// https://code.visualstudio.com/docs/nodejs/working-with-javascript#_global-variables-and-type-checking
// https://www.typescriptlang.org/docs/handbook/declaration-files/by-example.html
// https://github.com/JXA-userland/JXA/tree/master/packages/%40jxa/types/src
//──────────────────────────────────────────────────────────────────────────────

declare class MacAppObj {
	includeStandardAdditions: boolean;
	/** only URLs, not files on device */
	openLocation(url: string): string;
	open(path: string): void;
	read(path: string): string;
	id(): number;
	name(): string;
	running(): boolean;
	frontmost(): boolean;
	activate(): void;
	quit(): void;
	launch(): void;
	properties(): object; // inspect all properties
	beep(): void;

	systemInfo(): {
		systemVersion: string;
	};

	doShellScript(script: string): string; // DOCS https://developer.apple.com/library/archive/technotes/tn2065/_index.html
	pathTo(what: "home folder" | "desktop" | "trash"): string;

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

declare class FinderItem {
	creationDate(): Date;
	modificationDate(): Date;
	name(): string; // basename
	nameExtension(): string;
	kind(): string;
	size(): number;
	url(): string; // file-uri, contains file-path by using `.slice(7)` and `decodeURIComponent`
	properties(): object; // inspect all properties
	exists(): boolean;
}

// DOCS https://developer.apple.com/library/archive/releasenotes/InterapplicationCommunication/RN-JavaScriptForAutomation/Articles/OSX10-10.html
declare type PathObj = { toString(): string };
declare function Path(filepath: string): PathObj;

declare type ReminderList = {
	make(any);
	reminders: {
		push(newReminder: Reminder): void;
		whose(options: {
			dueDate?: {
				// https://developer.apple.com/library/archive/releasenotes/InterapplicationCommunication/RN-JavaScriptForAutomation/Articles/OSX10-10.html#//apple_ref/doc/uid/TP40014508-CH109-SW10
				_lessThan?: Date;
				_greaterThan?: Date;
			};
			completed?: boolean;
		});
		(): Reminder[];
	};
};

declare type ReminderProperties = {
	name: string;
	body?: string;
	id?: string; // x-apple-reminder:// URI
	completed?: boolean;
	flagged?: boolean;
	priority?: number;
	remindMeDate?: Date;
	alldayDueDate?: Date;
	dueDate?: Date;
	completionDate?: Date;
	creationDate?: Date;
};

declare type Reminder = {
	name(): string;
	body(): string;
	delete(): void;
	completed(): boolean;
	properties(): ReminderProperties;
	alldayDueDate(): Date;
	dueDate(): Date;
	completionDate(): Date;
};

declare const Application: {
	currentApplication: () => MacAppObj;
	(
		name: "System Events",
	): MacAppObj & {
		aliases: Record<string, FinderItem>; // hashmap of all paths, e.g. .aliases["/some/path/file.txt"]
		keystroke(key: string, modifiers?: { using: string[] });
		keyCode(keycode: number, modifiers?: { using: string[] });
		// biome-ignore lint/suspicious/noExplicitAny: later
		applicationProcesses: any;
		// biome-ignore lint/suspicious/noExplicitAny: later
		processes: any;
	};
	(
		name: "Reminders",
	): MacAppObj & {
		defaultList(): ReminderList;
		lists: {
			byName(name: string): ReminderList;
		};
		// biome-ignore lint/style/useNamingConvention: not set by me
		Reminder(options: ReminderProperties): Reminder;
	};
	(
		name: "Finder",
	): MacAppObj & {
		// PathObj and finderItems are not the same, but are apparently both accepted
		exists(path: PathObj): boolean;
		open(path: PathObj): void;
		reveal(path: PathObj): void;
		delete(path: PathObj): void; // can delete folders, even non-empty ones
		// accepts arrays only for *files*?! https://github.com/chrisgrieser/finder-vim-mode/issues/3
		select(path: PathObj | PathObj[]): void;
		selection(): FinderItem[];
		finderWindows: { target: FinderItem };
		insertionLocation(): FinderItem;
		// https://medium.com/hackernoon/javascript-for-automation-in-macos-3b499da40da1
		make(options: {
			new: "folder" | "file";
			at: PathObj;
			withProperties: { name: string };
		}): FinderItem;
	};
	(
		name: "com.runningwithcrayons.Alfred",
	): MacAppObj & {
		// biome-ignore lint/complexity/noBannedTypes: todo
		setConfiguration(envVar: string, options: Object): void;
		// workflowId: workflow uid (name of workflow folder) || workflow bundle id
		revealWorkflow(workflowId: string): void;
		reloadWorkflow(workflowId: string): void;
	};
	(
		name: "Safari" | "Webkit",
	): MacAppObj & {
		documents: { url(): string; name(): string }[];
	};
	(
		name:
			| "Google Chrome"
			| "Chromium"
			| "Opera"
			| "Vivaldi"
			| "Brave Browser"
			| "Microsoft Edge"
			| "Arc",
	): MacAppObj & {
		windows: { activeTab: { url(): string; name(): string } }[];
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
	// biome-ignore-start lint/suspicious/noExplicitAny: not set by me
	// biome-ignore-start lint/style/useNamingConvention: not set by me
	NSWorkspace: any; // REQUIRED `ObjC.import("Foundaton")`
	NSPasteboard: any; // REQUIRED `ObjC.import("AppKit")`
	NSFilenamesPboardType: any;
	(paths: string[]): any;

	// REQUIRES `ObjC.import("stdlib")`
	getenv: (envVar: string) => string;
	NSFileManager: any;
	NSUTF8StringEncoding: any;
	NSFileModificationDate: any;
	NSProcessInfo: any;
	NSURL: any;
	NSString: any;
	NSData: any;
	NSLocale: any;
	NSLocaleCountryCode: any;
	// biome-ignore-end lint/style/useNamingConvention: -
	// biome-ignore-end lint/suspicious/noExplicitAny: -
};
