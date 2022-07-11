// https://github.com/johnste/finicky/wiki/Configuration
// -----------------------------------------------------
// finicky can be fully replaced a Redirector browser
// extensions, e.g. https://chrome.google.com/webstore/search/redirector
// such an extension has the advantage of less overhead and
// of also working when links are clicked inside the browser
// (where finicky does not work)
// -----------------------------------------------------

module.exports = {
	defaultBrowser: "Brave Browser",
	options: {
		checkForUpdate: true,
		hideIcon: false,
	},

	rewrite: [
		{
			match: ({ url }) => url.host.endsWith("wikipedia.org"),
			url: ( { urlString } ) => urlString.replace (/https?:\/\/(\w+?)(?:\.m)?\.wikipedia\.org\/wiki\/(.*)/, "https://www.wikiwand.com/$1/$2"),
		},
	],

	handlers: [
		{
			match: /discord(app)?\.com\/channel/,
			url: ({ url }) => ({
				...url,
				protocol: "discord"
			}),
			browser: "com.hnc.Discord"
		},
		{
			match: /zoom\.us\/j/,
			browser: "us.zoom.xos"
		}
	]
}
