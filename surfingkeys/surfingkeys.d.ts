// DOCS https://github.com/brookhong/Surfingkeys/blob/master/docs/API.md
declare const api: SurfingKeysAPI;

// biome-ignore lint/suspicious/noExplicitAny: <explanation>
declare const chrome: any;

declare type SurfingKeysAPI = {
	// biome-ignore lint/style/useNamingConvention: not set by me
	Normal: {
		// biome-ignore lint/style/useNamingConvention: not set by me
		PassThrough(delay: number): void;
		feedkeys(keys: string): void;
	};
	// biome-ignore lint/style/useNamingConvention: not set by me
	Hints: {
		style(inlinceCss: string): void;
		// https://github.com/brookhong/Surfingkeys/blob/master/docs/API.md#hintscreate
		create(
			cssSelector: string,
			onHintKey: () => void,
			opts?: { active?: boolean; tabbed?: boolean; multipleHits?: boolean },
		): void;
		dispatchMouseClick(): void;
	};
	// biome-ignore lint/style/useNamingConvention: not set by me
	Front: {
		showBanner(text: string): void;
		openOmnibar(opts: { type: "History" | "RecentlyClosed" | "Tabs" }): void;
	};
	imap: (lhs: string, jscode: string, scope?: RegExp | null, annotation?: string) => void;
	map: (lhs: string, rhs: string, scope?: RegExp | null, annotation?: string) => void;
	vmap: (lhs: string, rhs: string, scope?: RegExp | null, annotation?: string) => void;
	mapkey: (
		lhs: string,
		annotation: string,
		jscode: () => void,
		opts?: { domain?: RegExp; repeatIgnore?: boolean },
	) => void;
	vmapkey: (
		lhs: string,
		annotation: string,
		jscode: () => void,
		opts?: { domain?: RegExp; repeatIgnore?: boolean },
	) => void;
	imapkey: (
		lhs: string,
		annotation: string,
		jscode: () => void,
		opts?: { domain?: RegExp; repeatIgnore?: boolean },
	) => void;
	aceVimMap: (lhs: string, rhs: string, ctx?: "insert" | "normal") => void;
	searchSelectedWith: (search: string, scope?: RegExp) => void;
	unmap: (keys: string, scope?: RegExp) => void;
	removeSearchAlias: (alias: string, searchLeaderKey?: string, onlyThisSiteKey?: string) => void;
	// biome-ignore lint/style/useNamingConvention: not set by me
	RUNTIME: (name: string, args?: object, callback?: () => void) => void;
};
