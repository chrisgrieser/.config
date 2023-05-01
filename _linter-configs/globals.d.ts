// https://code.visualstudio.com/docs/nodejs/working-with-javascript#_global-variables-and-type-checking

//──────────────────────────────────────────────────────────────────────────────
// rome-disable lint/suspicious/noExplicitAny: <explanation>
//──────────────────────────────────────────────────────────────────────────────

declare const ObjC: {
	import: Function;
	unwrap: Function;
};

declare const Application: {
	currentApplication: Function;
};

declare const $: {
	NSFileManager: any;
	NSUTF8StringEncoding: any;
	NSProcessInfo: any;
	NSURL: any;
	NSString: any;
	NSData: any;
	getenv: Function;
};
