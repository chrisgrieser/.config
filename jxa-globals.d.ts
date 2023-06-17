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
	};
	(appname: string): Object;
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
	NSString: string;
	NSData: string;
};
