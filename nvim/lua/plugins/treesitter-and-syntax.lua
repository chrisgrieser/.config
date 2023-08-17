local u = require("config.utils")

local tsConfig = {
	-- easier than keeping track of new parsers, especially the special ones,
	-- which are not auto-installed (luap, luadocs)
	ensure_installed = "all",

	highlight = {
		enable = true,
		disable = { "css" }, -- pending https://github.com/tree-sitter/tree-sitter-css/issues/34
	},
	-- use treesitter for autoindent with `=`
	indentation = { enable = true },

	--------------------------------------------------------------------------
	-- TREESITTER PLUGINS

	textobjects = { -- textobj plugin
		move = { -- move to next comment / function
			enable = true,
			set_jumps = true,
			disable = { "markdown", "css", "scss" }, -- so they can be mapped to heading/section navigation
			goto_next_start = { ["<C-j>"] = "@function.outer" },
			goto_previous_start = { ["<C-k>"] = "@function.outer" },
		},
		select = {
			enable = true,
			lookahead = true,
			include_surrounding_whitespace = false,
			disable = { "markdown" }, -- so `al` can be remapped to link text object
			keymaps = {
				["ik"] = { query = "@assignment.lhs", desc = "󱡔 inner key textobj" },
				-- INFO: outer key textobj defined via various textobjs
				["a<CR>"] = { query = "@return.outer", desc = "󱡔 outer return textobj" },
				["i<CR>"] = { query = "@return.inner", desc = "󱡔 inner return textobj" },
				["a/"] = { query = "@regex.outer", desc = "󱡔 outer regex textobj" },
				["i/"] = { query = "@regex.inner", desc = "󱡔 inner regex textobj" },
				["aa"] = { query = "@parameter.outer", desc = "󱡔 outer parameter textobj" },
				["ia"] = { query = "@parameter.inner", desc = "󱡔 inner parameter textobj" },
				-- stylua: ignore start
				["iu"] = { query = "@loop.inner", desc = "󱡔 inner loop textobj" }, -- mnemonic: luup
				["au"] = { query = "@loop.outer", desc = "󱡔 outer loop textobj" },
				["a" .. u.textobjectMaps["function"]] = { query = "@function.outer", desc = "󱡔 outer function textobj" },
				["i" .. u.textobjectMaps["function"]] = { query = "@function.inner", desc = "󱡔 inner function textobj" },
				["a" .. u.textobjectMaps["conditional"]] = { query = "@conditional.outer", desc = "󱡔 outer conditional textobj" },
				["i" .. u.textobjectMaps["conditional"]] = { query = "@conditional.inner", desc = "󱡔 inner conditional textobj" },
				["a" .. u.textobjectMaps["call"]] = { query = "@call.outer", desc = "󱡔 outer call textobj" },
				["i" .. u.textobjectMaps["call"]] = { query = "@call.inner", desc = "󱡔 inner call textobj" },
				-- stylua: ignore end

				-- INFO later remapped to q only in operator pending mode to avoid conflict
				-- @comment.inner not supported yet for most languages
				["&&&"] = { query = "@comment.outer", desc = "which_key_ignore" },
			},
		},
	},
	matchup = {
		enable = true,
		enable_quotes = true,
		disable_virtual_text = true,
	},
	endwise = { enable = true },
	tree_setter = { enable = true },
	refactor = {
		highlight_definitions = {
			enable = true,
			clear_on_cursor_move = false, -- set to true with a very low updatetime
		},
		highlight_current_scope = { enable = false },
		smart_rename = {
			enable = true,
			keymaps = { smart_rename = "<leader>v" }, -- in LSP filetypes overwritten by LSP rename
		},
	},
}

--------------------------------------------------------------------------------

return {
	{
		"nvim-treesitter/nvim-treesitter",
		event = "VeryLazy",
		build = function()
			-- build later, to ensure update went through correctly
			vim.defer_fn(
				function() require("nvim-treesitter.install").update { with_sync = true } end,
				5000
			)
		end,
		main = "nvim-treesitter.configs",
		opts = tsConfig,
		init = function()
			-- only `omap` to avoid conflict with visual mode comment from Comments.nvim
			vim.keymap.set("o", "q", "&&&", { desc = "󱡔 comment textobj", remap = true })
		end,
	},

	-- Syntax Highlighting Plugins
	{ "mityu/vim-applescript", ft = "applescript" },
	{ "hail2u/vim-css3-syntax", ft = "css" }, -- FIX https://github.com/tree-sitter/tree-sitter-css/issues/34
	{ "MTDL9/vim-log-highlighting", ft = "log" },
}
