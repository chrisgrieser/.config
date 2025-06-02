-- DOCS https://github.com/Kaiser-Yang/blink-cmp-git
--------------------------------------------------------------------------------

return {
	"saghen/blink.cmp", -- lazy.nvim will merge this config with the `blink.cmp` config
	dependencies = "Kaiser-Yang/blink-cmp-git",

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
								-- https://github.com/Kaiser-Yang/blink-cmp-git/issues/58
								issue = { get_documentation = function() return "" end },
							},
						},
					},
				},
			},
		},
	},
}
