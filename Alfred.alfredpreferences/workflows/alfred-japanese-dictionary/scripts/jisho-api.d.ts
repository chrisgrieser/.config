declare type JishoResponse = {
	meta: { status: number };
	data: Entry[];
};

declare type Entry = {
	slug: string;
	// biome-ignore lint/style/useNamingConvention: not set by me
	is_common: boolean;
	tags: string[];
	jlpt: string[];
	japanese: Japanese[];
	senses: Sense[];
	attribution: {
		jmdict: boolean;
		jmnedict: boolean;
		dbpedia: boolean;
	};
};

declare type Japanese = {
	word?: string; // Kanji
	reading?: string; // Kana, (in some rare cases, even the kana is missing)
};

// biome-ignore-start lint/style/useNamingConvention: not set by me
// biome-ignore-start lint/suspicious/noExplicitAny: unclear
declare type Sense = {
	english_definitions: string[];
	parts_of_speech: string[];
	links: { text: string; url: string }[];
	tags: string[];
	restrictions: any[];
	see_also: string[];
	antonyms: string[];
	source: any[];
	info: string[];
	sentences?: any[];
};
// biome-ignore-end lint/style/useNamingConvention: not set by me
// biome-ignore-end lint/suspicious/noExplicitAny: unclear
