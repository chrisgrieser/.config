-- save as `minimal-config.lua`
-- run via: `nvim -u minimal-config.lua`
--------------------------------------------------------------------------------
local spec = {
	{
		"saghen/blink.cmp",
		version = "*",
		dependencies = "Kaiser-Yang/blink-cmp-git",

		config = function(_, opts)
			-- read GITHUB_TOKEN from file
			local tokenPath = os.getenv("HOME")
				.. "/Library/Mobile Documents/com~apple~CloudDocs/Dotfolder/private dotfiles/github-token.txt"
			local file = io.open(tokenPath, "r")
			if file then
				vim.env.GITHUB_TOKEN = file:read("*l") -- read first line
				file:close()
			end

			require("blink.cmp").setup(opts)
		end,

		opts = {
			sources = {
				default = { "lsp", "path", "snippets", "buffer", "git" },
				providers = {
					git = {
						module = "blink-cmp-git",
						name = "Git",
					},
				},
			},
		},
	}
}

--------------------------------------------------------------------------------
vim.env.LAZY_STDPATH = "/tmp/nvim-repro"
load(vim.fn.system("curl -s https://raw.githubusercontent.com/folke/lazy.nvim/main/bootstrap.lua"))()
require("lazy.minit").repro { spec = spec }
--------------------------------------------------------------------------------
