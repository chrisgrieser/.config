-- DOCS https://github.com/kylechui/nvim-surround/blob/main/doc/nvim-surround.txt
--------------------------------------------------------------------------------
vim.pack.add { "https://github.com/kylechui/nvim-surround" }
--------------------------------------------------------------------------------

Keymap { "ys", "<Plug>(nvim-surround-normal)", desc = "󰅪 Add surround operator" }
Keymap { "yS", "ys$", desc = "󰅪 Surround to EoL", remap = true }
Keymap { "ds", "<Plug>(nvim-surround-delete)", desc = "󰅪 Delete surround operator" }
Keymap { "cs", "<Plug>(nvim-surround-change)", desc = "󰅪 Change surround operator" }

--------------------------------------------------------------------------------

require("nvim-surround").setup {
	move_cursor = false,
	-- stylua: ignore
	aliases = { -- aliases mirror my custom textobj keymaps
		c = "}", b = ")", r = "]",
		q = '"', z = "'", e = "`", k = { '"', "'", "`" }, -- anyquote
		s = { "}", ")", "]", '"', "'", "`" }, -- any surround
	},
	surrounds = {
		-- disable fallback to prevent accidental changes
		invalid_key_behavior = { add = false, find = false, delete = false, change = false },

		l = { -- function-calls
			find = "[%w.:_]+%b()", -- includes `:` for lua-methods/css-pseudoclasses
			delete = "([%w.:_]+%()().*(%))()",
		},
		f = { -- one-line lua functions
			find = "function ?[%w_]* ?%b().- end",
			delete = "(function ?[%w_]* ?%b() ?)().-( end)()",
		},
		o = { -- one-line lua conditionals
			find = "if .- then .- end",
			delete = "(if .- then )().-( end)()",
		},
		R = { -- double square brackets
			add = { "[[", "]]" },
			find = "%[%[.-%]%]",
			delete = "(%[%[)().-(%]%])()",
		},
	},
}
