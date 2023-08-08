local u = require("config.utils")
--------------------------------------------------------------------------------
return {
	{ -- keyboard cheatsheet
		"jokajak/keyseer.nvim",
		cmd = "KeySeer",
		opts = {
			include_builtin_keymaps = false,
			include_global_keymaps = true,
			include_buffer_keymaps = true,
			include_modified_keypresses = false,
			ignore_whichkey_conflicts = true,
			ui = {
				border = "double",
				size = { width = 70, height = 15 },
			},
			keyboard = {
				layout = "qwertz",
				keycap_padding = { 0, 1, 0, 1 }, -- [top, right, bottom, left]
				highlight_padding = { 0, 0, 0, 0 },
				key_labels = {
					["<Space>"] = "␣",
					["<CR>"] = "⏎",
					["<Tab>"] = "↹",
					["<BS>"] = "⌫",
					["<Esc>"] = "⎋",
					["<Shift>"] = "⇧",
					["<Meta>"] = "⌘",
					["<ALt>"] = "⌥",
					["<Ctrl>"] = "⌃",
					["<Caps>"] = "⇪",
				},
			},
		},
	},
	{
		"folke/which-key.nvim",
		event = "VimEnter",
		init = function()
			-- leader prefixes normal mode
			require("which-key").register({
				f = { name = " 󱗘 Refactor" },
				u = { name = " 󰕌 Undo" },
				l = { name = "  Log / Cmdline" },
				g = { name = " 󰊢 Git" },
				o = { name = "  Options" },
				p = { name = " 󰏗 Package" },
			}, { prefix = "<leader>" })

			-- leader prefixes visual mode
			require("which-key").register({
				f = { name = " 󱗘 Refactor" },
				l = { name = "  Log / Cmdline" },
				g = { name = " 󰊢 Git" },
			}, { prefix = "<leader>", mode = "x" })
		end,
		opts = {
			plugins = {
				presets = { motions = false, g = false, z = false },
				spelling = { enabled = false },
			},
			triggers_blacklist = {
				-- FIX "y" needed to fix weird delay occurring when yanking after a change
				-- n = { "y" },
				-- FIX very weird bug where insert mode undo points (<C-g>u),
				-- as well as vim-matchup's <C-g>% binding insert extra `1`s
				-- after wrapping to the next line in insert mode. The `G` needs
				-- to be uppercased to affect the right mapping, too.
				i = { "<C-G>" },
			},
			hidden = { "<Plug>", "^:lua ", "<cmd>" },
			-- INFO to ignore a mapping use the label "which_key_ignore", not the "hidden" setting here
			key_labels = { -- seems these are not working?
				["<CR>"] = "↵ ",
				["<BS>"] = "⌫",
				["<space>"] = "󱁐",
				["<Tab>"] = "↹ ",
				["<Esc>"] = "⎋",
				["<F1>"] = "^", -- karabiner remapping
				["<F2>"] = "<S-Space>", -- karabiner remapping
			},
			window = {
				-- only horizontal border to save space
				border = { "", u.borderHorizontal, "", "" },
				padding = { 0, 0, 0, 0 },
				margin = { 0, 0, 0, 0 },
			},
			popup_mappings = {
				scroll_down = "<PageDown>",
				scroll_up = "<PageUp>",
			},
			layout = { -- of the columns
				height = { min = 4, max = 11 },
				width = { min = 33, max = 35 },
				spacing = 2,
				align = "center",
			},
		},
	},
}
