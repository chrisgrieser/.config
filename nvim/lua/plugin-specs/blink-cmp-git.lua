-- DOCS https://github.com/Kaiser-Yang/blink-cmp-git
--------------------------------------------------------------------------------

local function getToken(path)
	local file = io.open(path, "r")
	if file then
		local token = file:read("*l") -- read first line
		file:close()
		return token
	end
end

return {
	-- `blink-cmp-git` is configured in the blink.cmp provider config. To keep
	-- plugin configs nonetheless modular, we define another set of `blink.cmp`
	-- config (lazy.nvim merges multiple configs).
	"saghen/blink.cmp",
	dependencies = "Kaiser-Yang/blink-cmp-git",

	config = function(_, opts)
		local tokenPath = os.getenv("HOME")
			.. "/Library/Mobile Documents/com~apple~CloudDocs/Dotfolder/private dotfiles/github-token.txt"
		vim.env.GITHUB_TOKEN = getToken(tokenPath)

		require("blink.cmp").setup(opts)
	end,

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
