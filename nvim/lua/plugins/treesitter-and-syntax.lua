local u = require("config.utils")

local tsConfig = {
	-- easier than keeping track of new parsers, especially the special ones (luap, luadocs)
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
				["ik"] = "@assignment.lhs", -- inner [k]ey ( INFO: outer defined via various textobjs)
				["a<CR>"] = "@return.outer", -- <CR>: return (`ar` already = a rectangular bracket)
				["i<CR>"] = "@return.inner",
				["a/"] = "@regex.outer", -- /regex/
				["i/"] = "@regex.inner",
				["aa"] = "@parameter.outer", -- [a]rgument
				["ia"] = "@parameter.inner",
				["iu"] = "@loop.inner", -- loop (mnemonic: luup)
				["au"] = "@loop.outer",
				["a" .. u.textobjectMaps["function"]] = "@function.outer", -- [f]unction
				["i" .. u.textobjectMaps["function"]] = "@function.inner",
				["a" .. u.textobjectMaps["conditional"]] = "@conditional.outer", -- c[o]nditional (`ac` already = a curly)
				["i" .. u.textobjectMaps["conditional"]] = "@conditional.inner",
				["a" .. u.textobjectMaps["call"]] = "@call.outer", -- cal[l]
				["i" .. u.textobjectMaps["call"]] = "@call.inner",

				-- INFO later remapped to q only in operator pending mode to avoid conflict
				-- @comment.inner not supported yet for most languages
				["&&&"] = "@comment.outer",
			},
		},
	},
	endwise = { enable = true },
	context_commentstring = {
		enable = true,
	},
	matchup = {
		enable = true,
		enable_quotes = true,
		disable_virtual_text = true,
	},
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
		build = function() require("nvim-treesitter.install").update { with_sync = true } end,
		main = "nvim-treesitter.configs",
		opts = tsConfig,
		init = function()
			-- HACK avoid conflict with visual mode comment from Comments.nvim
			vim.keymap.set("o", "q", "&&&", { desc = "comment", remap = true })
		end,
	},

	-- Syntax Highlighting Plugins
	{ "mityu/vim-applescript", ft = "applescript" },
	{ "hail2u/vim-css3-syntax", ft = "css" }, -- https://github.com/tree-sitter/tree-sitter-css/issues/34
	{ "MTDL9/vim-log-highlighting", ft = "log" },
}
