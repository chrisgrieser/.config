return {
	"nvim-treesitter/nvim-treesitter",
	commit = "5aadae3f543ad9f83d5c2eb209d85f3ee26587ab",
	event = "VeryLazy",
	build = ":TSUpdate",
	main = "nvim-treesitter.configs",
	opts = {
		-- easier than keeping track of new "special parsers", which are not
		-- auto-installed on entering a buffer (e.g., regex, luadocs, comments)
		ensure_installed = "all",

		highlight = {
			enable = true,
			-- disable on large files to prevent lag
			disable = function(_, buf) return vim.api.nvim_buf_line_count(buf) > 8000 end,
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
		matchup = {
			enable = true,
			enable_quotes = true,
		},
		textobjects = {
			move = { -- move to next function
				enable = true,
				set_jumps = true,
				disable = { "markdown" }, -- using heading-jumping there
			},
			select = { -- textobj definitions
				enable = true,
				lookahead = true,
				include_surrounding_whitespace = false,
				-- markdown does not know most treesitter objects anyway, so disabling
				-- there to be able to map other things
				disable = { "markdown" },
			},
			lsp_interop = {
				enable = true,
				border = vim.g.borderStyle,
				floating_preview_opts = {},
			},
		},
	},
}
