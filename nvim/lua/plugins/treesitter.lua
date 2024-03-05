return {
	"nvim-treesitter/nvim-treesitter",
	event = "VeryLazy",
	build = ":TSUpdate",
	main = "nvim-treesitter.configs",
	opts = {
		-- easier than keeping track of new "special parsers", which are not
		-- auto-installed on entering a buffer (e.g., regex, luadocs, comments)
		ensure_installed = "all",

		highlight = {
			enable = true,
			disable = function(lang, buf)
				local max_filesize = 100 * 1024 -- 100 KB
				local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
				if ok and stats and stats.size > max_filesize then return true end
			end,
		},
		indent = {
			enable = true,
			disable = {
				"markdown", -- indentation at bullet points is worse
				"javascript", -- some wrong indentation when using `o`
				"typescript",
				"gitrebase",
			},
		},
		matchup = {
			enable = true,
			enable_quotes = true,
			disable_virtual_text = false,
		},
		endwise = {
			enable = true,
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
