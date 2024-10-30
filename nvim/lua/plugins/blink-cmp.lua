return {
	"saghen/blink.cmp",
	event = "BufReadPre",
	version = "v0.*", -- REQUIRED release tag to download pre-built binaries

	opts = {
		sources = {
			completion = {
				enabled_providers = { "lsp", "path", "snippets", "buffer" },
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
			},
		},
		trigger = {
			completion = { show_in_snippet = true },
		},
		keymap = {
			["<D-c>"] = { "show" },
			["<S-CR>"] = { "hide" },
			["<CR>"] = { "select_and_accept", "fallback" },
			["<Tab>"] = { "next", "fallback" },
			["<S-Tab>"] = { "prev", "fallback" },
			["<Down>"] = { "select_next" },
			["<Up>"] = { "select_prev" },
			["<PageDown>"] = { "scroll_documentation_down" },
			["<PageUp>"] = { "scroll_documentation_up" },
		},
		highlight = {
			use_nvim_cmp_as_default = true,
		},
		windows = {
			documentation = {
				min_width = 15,
				max_width = 45, -- smaller, due to https://github.com/Saghen/blink.cmp/issues/194
				max_height = 10,
				border = vim.g.borderStyle,
				auto_show = true,
				auto_show_delay_ms = 250,
			},
			autocomplete = {
				min_width = 10, -- max_width controlled by draw-function
				max_height = 10,
				border = vim.g.borderStyle,
				cycle = { from_top = false }, -- cycle at bottom, but not at the top
				draw = function(ctx)
					-- https://github.com/Saghen/blink.cmp/blob/9846c2d2bfdeaa3088c9c0143030524402fffdf9/lua/blink/cmp/types.lua#L1-L6
					-- https://github.com/Saghen/blink.cmp/blob/9846c2d2bfdeaa3088c9c0143030524402fffdf9/lua/blink/cmp/windows/autocomplete.lua#L298-L349
					-- differentiate LSP snippets from user snippets and emmet snippets
					local source, client = ctx.item.source_id, ctx.item.client_id
					if client and vim.lsp.get_client_by_id(client).name == "emmet_language_server" then
						source = "emmet"
					end

					local sourceIcons = { snippets = "󰩫", buffer = "󰦨", emmet = "󰯸" }
					local icon = sourceIcons[source] or ctx.kind_icon

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
			Class = "󰜁",
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
