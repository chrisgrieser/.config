// https://code.visualstudio.com/docs/nodejs/working-with-javascript#_global-variables-and-type-checking
//──────────────────────────────────────────────────────────────────────────────

declare const ObjC: {
	import: Function;
	unwrap: Function;
};

declare const Application: {
	currentApplication: Function;
	(appname: string): any;
};

declare const Path: (filepath: string) => string;

declare const delay: (seconds: number) => void;

declare const $: {
	getenv: (envVar: string) => string;
	NSFileManager: any;
	NSUTF8StringEncoding: any;
	NSProcessInfo: any;
	NSURL: any;
	NSString: any;
	NSData: any;
};
