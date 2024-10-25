return {
	"saghen/blink.cmp",
	event = "BufReadPre",
	version = "v0.*", -- REQUIRED release tag to download pre-built binaries
	dependencies = "niuiic/blink-cmp-rg.nvim",

	opts = {
		sources = {
			completion = {
				enabled_providers = { "lsp", "path", "snippets", "buffer", "rg" },
			},
			providers = {
				snippets = {
					min_keyword_length = 1, -- don't show when triggered manually, useful for JSON keys
					score_offset = -1,
				},
				path = {
					opts = { get_cwd = vim.uv.cwd },
				},
				buffer = {
					fallback_for = {},
					max_items = 4,
					min_keyword_length = 4,
					score_offset = -3,
				},
				rg = {
					module = "blink-cmp-rg",
					name = "Rg",
					opts = { prefix_min_len = 3 },
				},
			},
		},
		trigger = {
			completion = {
				show_in_snippet = true,
			},
		},
		keymap = {
			show = "<D-c>",
			hide = "<S-CR>",
			accept = "<CR>",
			select_next = { "<Tab>", "<Down>" },
			select_prev = { "<S-Tab>", "<Up>" },
			scroll_documentation_down = "<PageDown>",
			scroll_documentation_up = "<PageUp>",
		},
		highlight = {
			use_nvim_cmp_as_default = true,
		},
		windows = {
			documentation = {
				min_width = 15,
				max_width = 50,
				max_height = 15,
				border = vim.g.borderStyle,
				auto_show = true,
				auto_show_delay_ms = 250,
			},
			autocomplete = {
				selection = "preselect", -- preselect|auto_insert
				min_width = 10, -- max_width controlled by draw-function
				max_height = 10,
				border = vim.g.borderStyle,
				cycle = { from_top = false }, -- cycle at bottom, but not at the top
				draw = function(ctx)
					-- https://github.com/Saghen/blink.cmp/blob/9846c2d2bfdeaa3088c9c0143030524402fffdf9/lua/blink/cmp/types.lua#L1-L6
					-- https://github.com/Saghen/blink.cmp/blob/9846c2d2bfdeaa3088c9c0143030524402fffdf9/lua/blink/cmp/windows/autocomplete.lua#L298-L349
					-- differentiate LSP snippets from user snippets and emmet snippets
					local icon, source = ctx.kind_icon, ctx.item.source_id
					local client = ctx.item.client_id
						and vim.lsp.get_client_by_id(ctx.item.client_id).name
					if source == "snippets" or (client == "basics_ls" and ctx.kind == "Snippet") then
						icon = "󰩫"
					elseif source == "buffer" or (client == "basics_ls" and ctx.kind == "Text") then
						icon = "󰦨"
					elseif source == "rg" then
						icon = "󰚌"
					elseif client == "emmet_language_server" then
						icon = "󰯸"
					end

					-- FIX highlight for Tokyonight
					local iconHl = vim.g.colors_name:find("tokyonight") and "BlinkCmpKind"
						or "BlinkCmpKind" .. ctx.kind

					return {
						{
							" " .. ctx.item.label .. " ",
							fill = true,
							hl_group = ctx.deprecated and "BlinkCmpLabelDeprecated" or "BlinkCmpLabel",
							max_width = 45,
						},
						{ icon .. " ", hl_group = iconHl },
					}
				end,
			},
		},
		kind_icons = {
			Text = "",
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
			Snippet = "󰒕",
			Color = "󰏘",
			Reference = "",
			File = "",
			Folder = "󰉋",
			EnumMember = "",
			Constant = "󰏿",
			Struct = "",
			Event = "",
			Operator = "󰆕",
			TypeParameter = "󰅲",
		},
	},
}
