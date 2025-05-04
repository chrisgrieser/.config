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

					---@module "blink-cmp-git"
					---@type blink-cmp-git.Options
					opts = {
						before_reload_cache = function() end, -- to silence cache-reload notification
						commit = { enable = false },
						git_centers = {
							github = {
								pull_request = { enable = false },
								mention = { enable = false },
								issue = {
									get_documentation = function() end, ---@diagnostic disable-line: missing-return wrong annotation
									insert_text_trailing = "", -- no trailing space after `#123`
								},
							},
						},
					},
				},
			},
		},
	},
}
