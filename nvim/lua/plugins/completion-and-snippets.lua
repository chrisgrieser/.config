lu

return {
	{
		"saghen/blink.cmp",
		lazy = false, -- lazy loading handled internally
		version = "v0.*", -- use a release tag to download pre-built binaries
		opts = {
			highlight = {
				use_nvim_cmp_as_default = true,
			},
			nerd_font_variant = "normal",
			accept = {
				auto_brackets = {
					enabled = false, -- experimental
				},
			}, 
			trigger = {
				signature_help = {
					enabled = false, -- experimental
				},
			},
			keymap = {
				show = "<D-c>",
				accept = "<CR>",
				select_next = "<Tab>",
				select_prev = "<S-Tab>",
				scroll_documentation_down = "<PageUp>",
				scroll_documentation_up = "<PageDown>",
				snippet_forward = "<D-p>",
				snippet_backward = "<D-P>",
			},
			sources = {
				providers = {
					{
						{ "blink.cmp.sources.snippets" },
						{ "blink.cmp.sources.lsp" },
					},
					{
						{ "blink.cmp.sources.buffer" },
					},
				},
			},
			windows = {
				autocomplete = {
					min_width = 20,
					max_width = 40,
					max_height = 15,
					border = vim.g.borderStyle,
					-- keep the cursor X lines away from the top/bottom of the window
					scrolloff = 2,
					-- which directions to show the window,
					-- falling back to the next direction when there's not enough space
					direction_priority = { "s", "n" },
					-- draw = "reversed",
				},
				documentation = {
				min_width = 15,
				max_width = 50,
				max_height = 20,
				border = vim.g.borderStyle,
				-- which directions to show the documentation window,
				-- for each of the possible autocomplete window directions,
				-- falling back to the next direction when there's not enough space
				direction_priority = {
					autocomplete_north = { "e", "w", "n", "s" },
					autocomplete_south = { "e", "w", "s", "n" },
				},
				auto_show = true,
				auto_show_delay_ms = 500,
				update_delay_ms = 100,
			},
			},
			kind_icons = {
				Text = "",
				Method = "󰆧",
				Function = "󰊕",
				Constructor = "",
				Field = "󰇽",
				Variable = "󰂡",
				Class = "󰠱",
				Interface = "",
				Module = "",
				Property = "󰜢",
				Unit = "",
				Value = "󰎠",
				Enum = "",
				Keyword = "󰌋",
				Snippet = "󰅱",
				Color = "󰏘",
				File = "󰈙",
				Reference = "",
				Folder = "󰉋",
				EnumMember = "",
				Constant = "󰏿",
				Struct = "",
				Event = "",
				Operator = "󰆕",
				TypeParameter = "󰅲",
			},
		},
	},
	{ -- snippet management
		"chrisgrieser/nvim-scissors",
		dependencies = "nvim-telescope/telescope.nvim",
		init = function() vim.g.whichkeyAddGroup("<leader>n", "󰩫 Snippets") end,
		keys = {
			{ "<leader>nn", function() require("scissors").editSnippet() end, desc = "󰩫 Edit" },
			-- stylua: ignore
			{ "<leader>na", function() require("scissors").addNewSnippet() end, mode = { "n", "x" }, desc = "󰩫 Add" },
		},
		opts = {
			editSnippetPopup = {
				height = 0.5, -- between 0-1
				width = 0.7,
				border = vim.g.borderStyle,
				keymaps = {
					deleteSnippet = "<D-BS>",
					insertNextPlaceholder = "<D-t>",
				},
			},
			telescope = { alsoSearchSnippetBody = true },
			jsonFormatter = "yq",
		},
	},
}
