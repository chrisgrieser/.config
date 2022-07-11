// Future versions of Hyper may add additional config options,
// which will not automatically be merged into this file.
// See https://hyper.is#cfg for all currently supported options.
// and https://github.com/vercel/hyper/blob/canary/app/config/config-default.js
module.exports = {
	config: {

		// Typography
		fontSize: 23,
		fontFamily: 'JetBrainsMono Nerd Font',
		fontWeight: 'normal',
		fontWeightBold: 'bold',
		lineHeight: 1.2,
		letterSpacing: 3,
		disableLigatures: true,

		// Appearance
		cursorShape: 'BLOCK',
		cursorBlink: true,
		padding: '10px 4px',
		backgroundColor: "#333",
		hyperTabs: {
			border: true,
			tabIcons: true,
			tabIconsColored: true,
			closeAlign: 'right',
			activityColor: 'yellow',
			activityPulse: true,
		},

		// Theme Specific
		verminal: {
			fontFamily: 'JetBrainsMono Nerd Font',
			fontSize: 23,
		},

		//Behavior
		copyOnSelect: true,
		quickEdit: true, // right-click copies selection or pastes
		webLinksActivationKey: 'meta', // meta = cmd (on Mac)
		// macOptionSelectionMode: 'vertical',
		macOptionSelectionMode: 'force', // https://github.com/walles/moar/issues/53#issuecomment-1049085201
		bell: false,
		scrollback: 2000,

		//Updates
		updateChannel: 'stable',
		disableAutoUpdates: false,
	},

	plugins: [
		"hyperalfred",
		"hyperminimal",
		"hyper-tabs-enhanced",
		"verminal",
		"hyper-quit",
	],

	localPlugins: ["fig-hyper-integration"],
};
