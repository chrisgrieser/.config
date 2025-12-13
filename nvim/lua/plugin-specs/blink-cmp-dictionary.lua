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
			-- manually trigger via `<D-d>` (as only source)
			["<D-d>"] = { function(cmp) cmp.show { providers = { "dictionary" } } end },
		},
		sources = {
			per_filetype = {
				-- automatically trigger in markdown files (along other sources)
				markdown = { inherit_defaults = true, "dictionary" },
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
