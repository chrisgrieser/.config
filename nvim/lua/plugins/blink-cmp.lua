return {
	"saghen/blink.cmp",
	event = "VimEnter", -- already lazy-loads internally
	version = "v0.*", -- REQUIRED release tag to download pre-built binaries
	opts = {
		sources = {
			providers = {
				{ "blink.cmp.sources.lsp", name = "LSP" },
				{ "blink.cmp.sources.snippets", name = "Snippets" },
				{
					"blink.cmp.sources.path",
					name = "Path",
					score_offset = 3,
					opts = {
						get_cwd = vim.uv.cwd,
						show_hidden_files_by_default = false,
					},
				},
				{
					"blink.cmp.sources.buffer",
					name = "Buffer",
					score_offset = -3,
					keyword_length = 3,
				},
			},
		},
		fhighlight = { use_nvim_cmp_as_default = true },
		keymap = {
			show = "<D-c>",
			accept = "<CR>",
			hide = "<S-CR>",
			select_next = { "<Tab>", "<Down>" },
			select_prev = { "<S-Tab>", "<Up>" },
			scroll_documentation_down = "<PageDown>",
			scroll_documentation_up = "<PageUp>",
		},
		windows = {
			autocomplete = {
				min_width = 10,
				max_height = 10,
				border = vim.g.borderStyle,
				selection = "auto_insert", -- auto_insert|preselect|manual
				cycle = { from_top = false },
				-- https://github.com/Saghen/blink.cmp/blob/819b978328b244fc124cfcd74661b2a7f4259f4f/lua/blink/cmp/windows/autocomplete.lua#L285-L349
				draw = function(ctx)
					-- differentiate snippets from LSPs, the user, and emmet
					local icon = ctx.kind_icon
					local client = ctx.item.source == "LSP"
						and vim.lsp.get_client_by_id(ctx.item.client_id).name
					if ctx.item.source == "LSP" and client ~= "basics_ls" and ctx.kind == "Snippet" then
						icon = "󰒕"
					end
					if client == "emmet_language_server" then icon = "󰯸" end
					if ctx.item.source == "Buffer" or (client == "basics_ls" and ctx.kind == "Text") then
						icon = "﬘"
					end

					return {
						{
							" " .. ctx.item.label .. " ",
							fill = true,
							hl_group = ctx.deprecated and "BlinkCmpLabelDeprecated" or "BlinkCmpLabel",
							max_width = 45,
						},
						{ icon .. ctx.icon_gap, hl_group = "BlinkCmpKind" .. ctx.kind },
					}
				end,
			},
			documentation = {
				min_width = 15,
				max_width = 45,
				max_height = 15,
				border = vim.g.borderStyle,
				auto_show = true,
				auto_show_delay_ms = 250,
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
}
