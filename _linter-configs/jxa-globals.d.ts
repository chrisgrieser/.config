// https://code.visualstudio.com/docs/nodejs/working-with-javascript#_global-variables-and-type-checking
// https://www.typescriptlang.org/docs/handbook/declaration-files/by-example.html
//──────────────────────────────────────────────────────────────────────────────

declare const ObjC: {
	import: (package: "stdlib" | "Foundation") => void;
	unwrap: (string: string) => string;
};

declare const Application: {
	currentApplication: () => any;
	(appname: string): any;
};

declare function Path(filepath: string): string;

declare function delay(seconds: number): void;

declare const $: {
	getenv: (envVar: string) => string;
	NSFileManager: any;
	NSUTF8StringEncoding: any;
	NSFileModificationDate: any;
	NSProcessInfo: any;
	NSURL: any;
	NSString: any;
	NSData: any;
};

//──────────────────────────────────────────────────────────────────────────────

// Alfred
declare class modiferObj {
	title: string;
	subtitle: string;
	arg: string|string[];
	valid: boolean;
}

// https://www.alfredapp.com/help/workflows/inputs/script-filter/json/
declare class AlfredScriptFilter {
	rerun?: number;
	variables?: Object;
	skipknowledge?: boolean;
	items: {
		title: string;
		action?: string|string[]|Object;
		subtitle?: string;
		arg: string|string[];
		valid?: boolean;
		type?: "default"|"file"|"file:skipcheck";
		match?: string;
		uuid?: string;
		autocomplete?: string;
		quicklookurl?: string;
		variables?: Object;
		icon?: {
			type?: "fileicon"|"filetype";
			path: string;
		};
		mods?: {
			cmd?: modiferObj;
			alt?: modiferObj;
			ctrl?: modiferObj;
			fn?: modiferObj;
			shift?: modiferObj;
		};
		text?: {
			copy?: string;
			largetype?: string;
		};
	}[];
}
