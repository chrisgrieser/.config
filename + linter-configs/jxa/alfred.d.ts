// DOCS https://www.alfredapp.com/help/workflows/inputs/script-filter/json/
//──────────────────────────────────────────────────────────────────────────────

// "run" function used by Alfred
// when used as Script Filter, the returned value must be a stringified JSON object
// biome-ignore lint/suspicious/noConfusingVoidType: needed here for try optional return
declare type AlfredRun = (argv: string[]) => void | string;

declare class AlfredScriptFilter {
	items: AlfredItem[];
	rerun?: number; // only accepts values between 0.1 and 5
	// biome-ignore lint/complexity/noBannedTypes: <explanation>
	variables?: Object;
	skipknowledge?: boolean;
	cache?: {
		seconds: number;
		loosereload?: boolean;
	};
}

declare class AlfredIcon {
	type?: "fileicon" | "filetype" | "";
	path?: string;
}

declare class AlfredItem {
	title: string;
	// biome-ignore lint/complexity/noBannedTypes: not set by me
	action?: string | string[] | Object;
	subtitle?: string;
	arg?: string | string[] | number;
	valid?: boolean;
	type?: "default" | "file" | "file:skipcheck";
	match?: string;
	uid?: string|undefined;
	autocomplete?: string;
	quicklookurl?: string|undefined;
	// biome-ignore lint/suspicious/noExplicitAny: that's the type
	variables?: Record<string, any>;
	icon?: AlfredIcon;
	mods?: {
		cmd?: AlfredModifierKey;
		alt?: AlfredModifierKey;
		ctrl?: AlfredModifierKey;
		fn?: AlfredModifierKey;
		shift?: AlfredModifierKey;
		"cmd+shift"?: AlfredModifierKey;
		"cmd+ctrl"?: AlfredModifierKey;
		"cmd+alt"?: AlfredModifierKey;
	};
	text?: {
		copy?: string;
		largetype?: string;
	};
}

declare class AlfredModifierKey {
	title?: string | undefined;
	subtitle?: string | undefined;
	arg?: string | string[] | number | undefined;
	valid?: boolean | undefined;
	// biome-ignore lint/suspicious/noExplicitAny: not set by me
	variables?: Record<string, any> | undefined;
}
