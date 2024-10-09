-- REMAINING ISSUES
-- https://github.com/Saghen/blink.cmp/issues/28
--------------------------------------------------------------------------------

return {
	{
		"saghen/blink.cmp",
		event = "UIEnter", -- already lazy-loads internally
		version = "v0.*", -- REQUIRED release tag to download pre-built binaries
		opts = {
			sources = {
				providers = {
					{
						{ "blink.cmp.sources.lsp" },
						{ "blink.cmp.sources.snippets", score_offset = -1 },
						{ "blink.cmp.sources.buffer", score_offset = -5 },
					},
				},
			},
			keymap = {
				show = "<D-c>",
				accept = "<CR>",
				hide = "<S-CR>",
				select_next = "<Tab>",
				select_prev = "<S-Tab>",
				scroll_documentation_down = "<PageDown>",
				scroll_documentation_up = "<PageUp>",
				snippet_forward = "<D-p>",
				snippet_backward = "<D-P>",
			},
			windows = {
				autocomplete = {
					min_width = 10,
					max_width = 45,
					max_height = 12,
					border = vim.g.borderStyle,
					-- https://github.com/Saghen/blink.cmp/blob/f456c2aa0994f709f9aec991ed2b4b705f787e48/lua/blink/cmp/windows/autocomplete.lua#L227
					draw = function(ctx)
						-- differentiate snippets from LSPs, the user, and emmet
						local icon = ctx.kind_icon
						local client = ctx.item.source == "blink.cmp.sources.lsp"
							and vim.lsp.get_client_by_id(ctx.item.client_id).name
						if client and ctx.kind == "Snippet" then icon = "󰒕" end
						if client == "emmet_language_server" then icon = "󰯸" end
						if ctx.item.source == "blink.cmp.sources.buffer" then icon = "﬘" end

						return {
							{
								" " .. ctx.item.label .. " ",
								fill = true,
								hl_group = ctx.deprecated and "BlinkCmpLabelDeprecated" or "BlinkCmpLabel",
							},
							{ icon .. " ", hl_group = "BlinkCmpKind" .. ctx.kind },
						}
					end,
				},
				documentation = {
					min_width = 15,
					max_width = 45,
					max_height = 15,
					border = vim.g.borderStyle,
					auto_show_delay_ms = 250,
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
				Class = "⬟",
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
