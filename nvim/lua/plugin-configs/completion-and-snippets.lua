-- DOCS https://github.com/saghen/blink.cmp#configuration
--------------------------------------------------------------------------------
-- TODO can be removed next version: https://github.com/Saghen/blink.cmp/issues/370
---@diagnostic disable: missing-fields

return {
	{ -- completion engine
		"saghen/blink.cmp",
		event = "InsertEnter",
		version = "*", -- REQUIRED `tag` needed to download pre-built binary

		---@module "blink.cmp"
		---@type blink.cmp.Config
		opts = {
			highlight = {
				-- supported: tokyonight
				-- not supported: nightfox, gruvbox-material
				use_nvim_cmp_as_default = true,
			},
			sources = {
				providers = {
					snippets = {
						min_keyword_length = 1, -- don't show when triggered manually, useful for JSON keys
						score_offset = -1,
					},
					buffer = {
						fallback_for = {}, -- disable being fallback for LSP
						max_items = 4,
						min_keyword_length = 4,
						score_offset = -3,
					},
				},
			},
			keymap = {
				["<D-c>"] = { "show" },
				["<S-CR>"] = { "hide" },
				["<CR>"] = { "select_and_accept", "fallback" },
				["<Tab>"] = { "select_next", "fallback" },
				["<S-Tab>"] = { "select_prev", "fallback" },
				["<Down>"] = { "select_next", "fallback" },
				["<Up>"] = { "select_prev", "fallback" },
				["<PageDown>"] = { "scroll_documentation_down" },
				["<PageUp>"] = { "scroll_documentation_up" },
			},
			windows = {
				documentation = {
					border = vim.g.borderStyle,
					max_width = 50,
					max_height = 15,
					auto_show = true,
					auto_show_delay_ms = 250,
				},
				autocomplete = {
					border = vim.g.borderStyle,
					cycle = { from_top = false }, -- cycle at bottom, but not at the top
					draw = {
						-- https://github.com/saghen/blink.cmp#menu-appearancedrawing
						columns = {
							{ "label", "label_description", "kind_icon", gap = 1 },
						},
						components = {
							label = { width = { max = 30 } }, -- more space for doc-win
							label_description = { width = { max = 20 } },
							kind_icon = {
								text = function(ctx)
									-- detect emmet-ls
									local source, client = ctx.item.source_id, ctx.item.client_id
									local lspName = client and vim.lsp.get_client_by_id(client).name
									if lspName == "emmet_language_server" then source = "emmet" end

									-- use source-specific icons, and `kind_icon` only for items from LSPs
									local sourceIcons = {
										snippets = "󰩫",
										buffer = "󰦨",
										emmet = "",
										path = "󰈔",
									}
									local icon = sourceIcons[source] or ctx.kind_icon
									return icon
								end,
							},
						},
					},
				},
			},
			kind_icons = {
				Text = "",
				Method = "󰊕",
				Function = "󰡱",
				Constructor = "",
				Field = "󰇽",
				Variable = "󰀫",
				Class = "󰜁",
				Interface = "",
				Module = "",
				Property = "󰜢",
				Unit = "",
				Value = "󰎠",
				Enum = "",
				Keyword = "󰌋",
				Snippet = "󰒕", -- should indicate it's from the LSP
				Color = "󰏘",
				Reference = "",
				File = "", -- if from LSP, it's a module
				Folder = "󰉋",
				EnumMember = "",
				Constant = "󰏿",
				Struct = "󰙅",
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
			{
				"<leader>na",
				function() require("scissors").addNewSnippet() end,
				mode = { "n", "x" },
				desc = "󰩫 Add",
			},
		},
		opts = {
			editSnippetPopup = {
				height = 0.55, -- between 0-1
				width = 0.75,
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
