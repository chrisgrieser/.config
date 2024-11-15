return {
	"nvim-treesitter/nvim-treesitter",
	event = "BufReadPre",
	build = ":TSUpdate",
	main = "nvim-treesitter.configs",
	init = function()
		-- FIX for `comments` parser https://github.com/stsewd/tree-sitter-comment/issues/22
		vim.api.nvim_create_autocmd("ColorScheme", {
			desc = "User: FIX hlgroup for `comments` parser",
			callback = function() vim.api.nvim_set_hl(0, "@lsp.type.comment.lua", {}) end,
		})
	end,
	opts = {
		-- easier than keeping track of new "special parsers", which are not
		-- auto-installed on entering a buffer (e.g., regex, luadocs, comments)
		ensure_installed = "all",

		highlight = {
			enable = true,
			disable = function(_, bufnr)
				-- disable on large files
				local maxFilesizeKb = 100
				local ok, stats = pcall(vim.uv.fs_stat, vim.api.nvim_buf_get_name(bufnr))
				if ok and stats and stats.size > maxFilesizeKb * 1024 then return true end
			end,
		},
		indent = {
			enable = true,
			disable = { "markdown" }, -- indentation at bullet points is worse
		},
		-- `nvim-treesitter-textobjects` plugin
		textobjects = {
			move = { -- move to next function
				enable = true,
				set_jumps = true,
			},
			select = { -- textobj definitions
				enable = true,
				lookahead = true,
				include_surrounding_whitespace = false, -- doesn't work with my comment textobj mappings
			},
		},
	},
}
