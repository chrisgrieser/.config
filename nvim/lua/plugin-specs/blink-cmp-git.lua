-- DOCS https://github.com/Kaiser-Yang/blink-cmp-git
--------------------------------------------------------------------------------

return {
	"saghen/blink.cmp",
	dependencies = {"Kaiser-Yang/blink-cmp-git", dependencies = "nvim-lua/plenary.nvim",},

	opts = {
		sources = {
			per_filetype = {
				gitcommit = { "git" }, -- use only in gitcommits, and there as only source
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
								issue = {
									insert_text_trailing = "", -- no trailing space after `#123`
									get_documentation = function() return "" end, -- disable
								},
							},
						},
					},
				},
			},
		},
	},
}
