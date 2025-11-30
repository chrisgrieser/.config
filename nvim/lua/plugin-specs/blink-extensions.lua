-- DOCS https://github.com/Kaiser-Yang/blink-cmp-git
--------------------------------------------------------------------------------

return {
	-- `blink-cmp-git` is configured in the blink.cmp provider config. To keep
	-- plugin configs nonetheless modular, we define another set of `blink.cmp`
	-- config (lazy.nvim merges multiple configs).
	"saghen/blink.cmp",
	dependencies = { "Kaiser-Yang/blink-cmp-git", "Kaiser-Yang/blink-cmp-dictionary" },
	init = require("config.utils").loadGhToken,

	opts = {
		sources = {
			-- add `git` and `dictionary` to the list
			default = { "lsp", "path", "snippets", "buffer", "git", },

			per_filetype = {
				gitcommit = { "git" },
			},

			providers = {
				dictionary = {
					module = "blink-cmp-dictionary",
					score_offset = -7,
					max_items = 6,
					min_keyword_length = 4,
					opts = {
						dictionary_directories = { vim.env.HOME .. "/.config/word-lists/" },
					},
				},
				git = {
					module = "blink-cmp-git",
					opts = {
						before_reload_cache = function() end, -- silence cache-reload notification
						commit = { enable = false },
						git_centers = {
							github = {
								pull_request = { enable = false },
								mention = { enable = false },
								issue = { get_documentation = function() return "" end }, -- disable doc window
							},
						},
					},
				},
			},
		},
	},
}
