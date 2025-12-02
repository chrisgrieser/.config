-- DOCS https://github.com/Kaiser-Yang/blink-cmp-dictionary
--------------------------------------------------------------------------------
-- extensions are configured in blink's ` sources` config. To keep plugin
-- configs nonetheless modular, we define another set of `blink.cmp` config
-- (lazy.nvim merges multiple configs).
-----------------------------------------------------------------------------

return {
	"saghen/blink.cmp",
	dependencies = "Kaiser-Yang/blink-cmp-dictionary",
	opts = {
		keymap = {
			-- manually trigger only dictionary as completion source
			["<D-d>"] = { function(cmp) cmp.show { providers = { "dictionary" } } end },
		},
		sources = {
			per_filetype = {
				markdown = { inherit_defaults = true, "dictionary" },
				text = { inherit_defaults = true, "dictionary" },
			},
			providers = {
				dictionary = {
					module = "blink-cmp-dictionary",
					score_offset = -7,
					min_keyword_length = 4,
					opts = {
						dictionary_directories = { vim.env.HOME .. "/.config/word-lists" },
					},
				},
			},
		},
	},
}
