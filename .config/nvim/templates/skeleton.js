#!/usr/bin/env osascript -l JavaScript

ObjC.import("stdlib");
const app = Application.currentApplication();
app.includeStandardAdditions = true;

const onlineJSON = (url) => JSON.parse(app.doShellScript(`curl -s "${url}"`));

function alfredMatcher(str) {
	const clean = str.replace(/[-()_.:#/\\;,]/g, " ");
	const camelCaseSeperated = str.replace(/([A-Z])/g, " $1");
	return [clean, camelCaseSeperated, str].join(" ");
}

function readFile(path) {
	const fm = $.NSFileManager.defaultManager;
	const data = fm.contentsAtPath(path);
	const str = $.NSString.alloc.initWithDataEncoding(data, $.NSUTF8StringEncoding);
	return ObjC.unwrap(str);
}

//──────────────────────────────────────────────────────────────────────────────
