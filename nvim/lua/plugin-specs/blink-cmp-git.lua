-- DOCS https://github.com/Kaiser-Yang/blink-cmp-git
--------------------------------------------------------------------------------
-- extensions are configured in blink's ` sources` config. To keep plugin
-- configs nonetheless modular, we define another set of `blink.cmp` config
-- (lazy.nvim merges multiple configs).
-----------------------------------------------------------------------------

return {
	"saghen/blink.cmp",
	dependencies = "Kaiser-Yang/blink-cmp-git",
	init = require("config.utils").loadGhToken,
	opts = {
		sources = {
			default = { "lsp", "path", "snippets", "buffer", "git" },
			per_filetype = {
				gitcommit = { "git" },
			},

			providers = {
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
