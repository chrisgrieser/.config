-- DOCS https://github.com/saghen/blink.cmp#configuration
--------------------------------------------------------------------------------

-- TODO FOR NEXT RELEASE
-- annotations https://github.com/Saghen/blink.cmp/issues/427
---@diagnostic disable: missing-fields

--------------------------------------------------------------------------------

return {
	{ -- completion engine
		"saghen/blink.cmp",
		event = "InsertEnter",
		version = "*", -- REQUIRED `version` needed to download pre-built binary

		---@module "blink.cmp"
		---@type blink.cmp.Config
		opts = {
			sources = {
				providers = {
					snippets = {
						-- don't show when triggered manually (= length 0), useful
						-- when manually show completions to see available JSON keys
						min_keyword_length = 1,
						score_offset = -1,
					},
					path = {
						opts = {
							get_cwd = vim.uv.cwd,
						},
					},
					buffer = {
						-- disable being fallback for LSP, but limit its display via
						-- the other settings
						fallback_for = {},
						max_items = 4,
						min_keyword_length = 4,
						score_offset = -3,

						-- show completions from all buffers used within the last x minutes
						opts = {
							get_bufnrs = function()
								local mins = 15
								local allOpenBuffers = vim.fn.getbufinfo { buflisted = 1, bufloaded = 1 }
								local recentBufs = vim.iter(allOpenBuffers)
									:filter(function(buf)
										local recentlyUsed = os.time() - buf.lastused < (60 * mins)
										local nonSpecial = vim.bo[buf.bufnr].buftype == ""
										return recentlyUsed and nonSpecial
									end)
									:map(function(buf) return buf.bufnr end)
									:totable()
								return recentBufs
							end,
						},
					},
				},
			},
			keymap = {
				["<D-c>"] = { "show" },
				["<S-CR>"] = { "cancel" },
				["<CR>"] = { "select_and_accept", "fallback" },
				["<Tab>"] = { "select_next", "fallback" },
				["<S-Tab>"] = { "select_prev", "fallback" },
				["<Down>"] = { "select_next", "fallback" },
				["<Up>"] = { "select_prev", "fallback" },
				["<PageDown>"] = { "scroll_documentation_down" },
				["<PageUp>"] = { "scroll_documentation_up" },
			},
			completion = {
				keyword = {
					-- Remove `\`, so it does not trigger completion.
					-- Useful when breaking up lines in bash/zsh.
					regex = "[%w_-]",
				},
				list = {
					cycle = { from_top = false }, -- cycle at bottom, but not at the top
				},
				accept = {
					auto_brackets = { enabled = true }, -- experimental
				},
				documentation = {
					auto_show = true,
					auto_show_delay_ms = 250,
					window = {
						border = vim.g.borderStyle,
						max_width = 50,
						max_height = 15,
					},
				},
				menu = {
					border = vim.g.borderStyle,
					draw = {
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
									local sourceIcons =
										{ snippets = "󰩫", buffer = "󰦨", emmet = "", path = "" }
									return sourceIcons[source] or ctx.kind_icon
								end,
							},
						},
					},
				},
			},
			appearance = {
				-- supported: tokyonight
				-- not supported: nightfox, gruvbox-material
				use_nvim_cmp_as_default = true,
				kind_icons = {
					-- different icons of the corresponding source
					Text = "󰦨", -- `buffer`
					Snippet = "ﲖ", -- `snippets`
					File = "", -- `path`
					Folder = "󰉋",
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
					Color = "󰏘",
					Reference = "",
					EnumMember = "",
					Constant = "󰏿",
					Struct = "󰙅",
					Event = "",
					Operator = "󰆕",
					TypeParameter = "󰅲",
				},
			},
		},
	},
	{ -- snippet management
		"chrisgrieser/nvim-scissors",
		dependencies = "nvim-telescope/telescope.nvim",
		init = function() vim.g.whichkeyAddGroup { "<leader>n", group = "󰩫 Snippets" } end,
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
