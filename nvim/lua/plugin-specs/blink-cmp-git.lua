-- DOCS https://github.com/Kaiser-Yang/blink-cmp-git
--------------------------------------------------------------------------------

return {
	-- `blink-cmp-git` is configured in the blink.cmp provider config. To keep
	-- plugin configs nonetheless modular, we define another set of `blink.cmp`
	-- config (lazy.nvim merges multiple configs).
	"saghen/blink.cmp",
	dependencies = "Kaiser-Yang/blink-cmp-git",
	init = require("config.utils").loadGhToken,

	opts = {
		sources = {
			default = { "lsp", "path", "snippets", "buffer", "git" }, -- add `git` to the list
			per_filetype = {
				gitcommit = { "git" },
			},

			providers = {
				git = {
					module = "blink-cmp-git",
					name = "Git",
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
