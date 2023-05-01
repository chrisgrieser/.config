// https://code.visualstudio.com/docs/nodejs/working-with-javascript#_global-variables-and-type-checking
//──────────────────────────────────────────────────────────────────────────────

declare const ObjC: {
	import: (package: "stdlib" | "Foundation") => void;
	unwrap: (string: string) => string;
};

declare const Application: {
	currentApplication: () => object;
	(appname: string): object;
};

declare const Path: (filepath: string) => string;

declare function delay (seconds: number) => void;

declare const $: {
	getenv: (envVar: string) => string;
	NSFileManager: any;
	NSUTF8StringEncoding: any;
	NSProcessInfo: any;
	NSURL: any;
	NSString: any;
	NSData: any;
};
