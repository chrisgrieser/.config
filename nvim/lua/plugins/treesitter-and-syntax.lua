local tsConfig = {
	ensure_installed = "all",

	highlight = {
		enable = true,
		-- names of the parsers and not filetypes
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
				["an"] = "@number.inner", -- [n]umber
				["ik"] = "@assignment.lhs", -- inner [k]ey ( INFO: outer defined via various textobjs)
				["a<CR>"] = "@return.outer", -- <CR>: return (`ar` already = a rectangular bracket)
				["i<CR>"] = "@return.inner",
				["a/"] = "@regex.outer", -- /regex/
				["i/"] = "@regex.inner",
				["af"] = "@function.outer", -- [f]unction
				["if"] = "@function.inner",
				["aa"] = "@parameter.outer", -- [a]rgument
				["ia"] = "@parameter.inner",
				["ao"] = "@conditional.outer", -- c[o]nditional (`ac` already = a curly)
				["io"] = "@conditional.inner",
				["il"] = "@call.inner", -- cal[l]
				["al"] = "@call.outer",
				["iu"] = "@loop.inner", -- loop (mnemonic: luup)
				["au"] = "@loop.outer",
				-- later remapped to q only in operator pending mode to avoid conflict
				-- @comment.inner not supported yet for most languages
				["&&&"] = "@comment.outer",
			},
		},
	},
	endwise = { enable = true },
	rainbow = { enable = true },
	refactor = {
		highlight_definitions = {
			enable = true,
			clear_on_cursor_move = false, -- set to true with a very low updatetime
		},
		highlight_current_scope = { enable = false },
		smart_rename = {
			enable = true,
			-- in LSP filetypes overwritten by LSP rename
			keymaps = { smart_rename = "<leader>v" },
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
	{ -- Embedded filetypes
		"AndrewRadev/inline_edit.vim",
		cmd = "InlineEdit",
		init = function()
			vim.g.inline_edit_autowrite = 1
			vim.g.inline_edit_new_buffer_command = "new"
			vim.g.inline_edit_proxy_type = "scratch" -- scratch|tempfile
		end,
	},

	-- Syntax Highlighting Plugins
	{ "mityu/vim-applescript", ft = "applescript" },
	{ "hail2u/vim-css3-syntax", ft = "css" }, -- https://github.com/tree-sitter/tree-sitter-css/issues/34
}
