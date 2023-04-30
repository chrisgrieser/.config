// https://code.visualstudio.com/docs/nodejs/working-with-javascript#_global-variables-and-type-checking
//──────────────────────────────────────────────────────────────────────────────

interface _ObjC {
	import: Function;
}
interface _Application {
	currentApplication: Function;
}

declare var ObjC: _ObjC;
declare var Application: _Application;
