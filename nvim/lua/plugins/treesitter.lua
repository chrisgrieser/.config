return {
	"nvim-treesitter/nvim-treesitter",
	event = "VeryLazy",
	build = ":TSUpdate",
	main = "nvim-treesitter.configs",
	init = function ()
		-- use bash parser for zsh files
		vim.treesitter.language.register("bash", "zsh")
	end,
	opts = {
		-- easier than keeping track of new "special parsers", which are not
		-- auto-installed on entering a buffer (e.g., regex, luadocs, comments)
		ensure_installed = "all",

		highlight = {
			enable = true,
			-- disable on large files
			disable = function(_, buf) return vim.api.nvim_buf_line_count(buf) > 5000 end,
		},
		indent = {
			enable = true,
			disable = {
				"markdown", -- indentation at bullet points is worse
				"javascript", -- some wrong indentation when using `o`
				"typescript",
				"gitrebase",
				"lua",
				"yaml", -- wrong indentation in list continuation
			},
		},
		-- plugins
		matchup = {
			enable = true,
			enable_quotes = true,
		},
		textobjects = {
			move = { -- move to next function
				enable = true,
				set_jumps = true,
			},
			select = { -- textobj definitions
				enable = true,
				lookahead = true,
				include_surrounding_whitespace = false,
			},
			lsp_interop = {
				enable = true,
				border = vim.g.borderStyle,
				floating_preview_opts = {},
			},
		},
	},
}
