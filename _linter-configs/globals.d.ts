// https://code.visualstudio.com/docs/nodejs/working-with-javascript#_global-variables-and-type-checking
//──────────────────────────────────────────────────────────────────────────────

declare var ObjC: {
	import: Function;
};

declare var Application: {
	currentApplication: Function;
};

declare var $: {
	NSUTF8StringEncoding: any;
	NSProcessInfo: any;
	NSURL: any;
	NSString: any;
	NSData: any;
	getenv: Function;
};
