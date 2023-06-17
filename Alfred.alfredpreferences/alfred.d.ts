// https://www.alfredapp.com/help/workflows/inputs/script-filter/json/
//──────────────────────────────────────────────────────────────────────────────

// "run" function used by Alfred
// when used as Script Filter, the returned value must be a stringified JSON object
declare type AlfredRun = (argv: string[]) => string; 

declare class AlfredScriptFilter {
	rerun?: number; // only accepts values between 0.1 and 5
	variables?: Object;
	skipknowledge?: boolean;
	items: AlfredItem[];
}

declare class AlfredItem {
	title: string;
	action?: string|string[]|Object;
	subtitle?: string;
	arg?: string|string[];
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
		cmd?: AlfredModifierKey;
		alt?: AlfredModifierKey;
		ctrl?: AlfredModifierKey;
		fn?: AlfredModifierKey;
		shift?: AlfredModifierKey;
	};
	text?: {
		copy?: string;
		largetype?: string;
	};
}

declare class AlfredModifierKey {
	title?: string;
	subtitle?: string;
	arg?: string|string[];
	valid?: boolean;
	variables?: Object;
}
