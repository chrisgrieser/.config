declare type JishoResponse = {
	meta: { status: number }
	data: Entry[]
}

declare type Entry = {
	slug: string
	// biome-ignore lint/style/useNamingConvention: not set by me
	is_common: boolean
	tags: string[]
	jlpt: string[]
	japanese: Japanese[]
	senses: Sense[]
}

declare type Japanese = {
	word?: string
	reading: string
}

declare type Sense = {
	// biome-ignore lint/style/useNamingConvention: not set by me
	english_definitions: string[]
	// biome-ignore lint/style/useNamingConvention: not set by me
	parts_of_speech: string[]
	links: { text: string, url: string }[]
	tags: string[]
	// biome-ignore lint/suspicious/noExplicitAny: unclear
	restrictions: any[]
	// biome-ignore lint/style/useNamingConvention: not set by me
	see_also: string[]
	antonyms: string[]
	// biome-ignore lint/suspicious/noExplicitAny: unclear
	source: any[]
	info: string[]
	// biome-ignore lint/suspicious/noExplicitAny: unclear
	sentences?: any[]
}
