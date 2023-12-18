return {
	-- { -- emphasized headers & code blocks
	-- 	"lukas-reineke/headlines.nvim",
	-- 	ft = "markdown", -- can work in other fts, but I only use it in markdown
	-- 	dependencies = "nvim-treesitter/nvim-treesitter",
	-- 	opts = {
	-- 		markdown = {
	-- 			fat_headlines = false,
	-- 			dash_string = "─",
	-- 		},
	-- 	},
	-- },
	{ -- preview markdown
		"iamcco/markdown-preview.nvim",
		build = function() vim.fn["mkdp#util#install"]() end,
		-- ft-load-trigger needed for the plugin to work, even though it's only
		-- loaded on the keymap, probably the plugin has some ftplugin conditions
		-- doing some pre-loading
		ft = "markdown",
		keys = {
			{ "<D-r>", vim.cmd.MarkdownPreview, ft = "markdown", desc = " Preview" },
		},
	},
}
