// https://www.alfredapp.com/help/workflows/inputs/script-filter/json/
//──────────────────────────────────────────────────────────────────────────────

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
		cmd?: AlfredModifier;
		alt?: AlfredModifier;
		ctrl?: AlfredModifier;
		fn?: AlfredModifier;
		shift?: AlfredModifier;
	};
	text?: {
		copy?: string;
		largetype?: string;
	};
}

declare class AlfredModifier {
	title?: string;
	subtitle?: string;
	arg?: string|string[];
	valid?: boolean;
	variables?: Object;
}

declare class AlfredScriptFilter {
	rerun?: number;
	variables?: Object;
	skipknowledge?: boolean;
	items: AlfredItem[];
}
