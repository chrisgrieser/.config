-- remaining issues PENDING
-- https://github.com/Saghen/blink.cmp/issues/30
-- https://github.com/Saghen/blink.cmp/issues/28
--------------------------------------------------------------------------------

return {
	{
		"saghen/blink.cmp",
		event = "InsertEnter",
		version = "v0.*", -- use a release tag to download pre-built binaries
		opts = {
			highlight = { use_nvim_cmp_as_default = true },
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
			accept = {
				auto_bracket = { enabled = false }, -- experimental
			},
			sources = {
				providers = {
					{
						{ "blink.cmp.sources.snippets" },
						{ "blink.cmp.sources.lsp" },
						{ "blink.cmp.sources.buffer", keyword_length = 3 },
						{
							"blink.cmp.sources.path",
							get_cwd = function(_) return vim.uv.cwd() or "/" end,
						},
					},
				},
			},
			windows = {
				autocomplete = {
					min_width = 10,
					max_width = 40,
					max_height = 15,
					border = vim.g.borderStyle,
					direction_priority = { "s", "n" },
					-- https://github.com/Saghen/blink.cmp/blob/f456c2aa0994f709f9aec991ed2b4b705f787e48/lua/blink/cmp/windows/autocomplete.lua#L227
					draw = function(ctx)
						return {
							{
								ctx.item.label .. " ",
								fill = true,
								hl_group = ctx.deprecated and "BlinkCmpLabelDeprecated" or "BlinkCmpLabel",
							},
							{ ctx.kind_icon .. " ", hl_group = "BlinkCmpKind" .. ctx.kind },
						}
					end,
				},
				documentation = {
					min_width = 15,
					max_width = 50,
					max_height = 20,
					border = vim.g.borderStyle,
					direction_priority = {
						autocomplete_north = { "e", "w", "n", "s" },
						autocomplete_south = { "e", "w", "s", "n" },
					},
					auto_show_delay_ms = 500,
					update_delay_ms = 100,
				},
			},
			kind_icons = {
				Text = "",
				Method = "󰊕",
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
				Snippet = "󰩫",
				Color = "󰏘",
				Reference = "",
				File = "󰉋",
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
