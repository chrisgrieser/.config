local defaultSources = {
	{ name = "luasnip" },
	{ name = "nvim_lsp" },
	{ name = "treesitter" },
	{ name = "path" },
	emojis = { name = "emoji", keyword_length = 2 },
}
local source_icons = {
	treesitter = "",
	zsh = "",
	nvim_lsp = "󰒕",
	luasnip = "󰞘",
	path = "",
	cmdline = "󰘳",
	cmdline_history = "󰋚",
	emoji = "󰞅",
}
--------------------------------------------------------------------------------

local function cmpconfig()
	local cmp = require("cmp")
	local compare = require("cmp.config.compare")
	local u = require("config.utils")

	cmp.setup {
		snippet = {
			expand = function(args) require("luasnip").lsp_expand(args.body) end,
		},
		window = {
			completion = {
				side_padding = 0,
				border = u.borderStyle,
			},
			documentation = {
				border = u.borderStyle,
			},
		},
		sorting = {
			comparators = {
				-- Original order: https://github.com/hrsh7th/nvim-cmp/blob/main/lua/cmp/config/default.lua#L57
				-- Definitions of compare function https://github.com/hrsh7th/nvim-cmp/blob/main/lua/cmp/config/compare.lua
				compare.offset,
				compare.recently_used, -- higher
				compare.score,
				compare.exact, -- lower
				compare.kind, -- higher (prioritize snippets)
				compare.locality,
				compare.length,
				compare.order,
			},
		},
		mapping = cmp.mapping.preset.insert {
			["<CR>"] = cmp.mapping.confirm { select = true }, -- true = autoselect first entry
			["<D-Esc>"] = cmp.mapping.complete(), -- trigger suggestion popup
			["<S-CR>"] = cmp.mapping.abort(), -- accept current text, consistent with Obsidian https://medium.com/obsidian-observer/obsidian-quick-tip-use-shift-enter-to-skip-autocomplete-on-links-8495ea189c4c
			["<PageUp>"] = cmp.mapping.scroll_docs(-4),
			["<PageDown>"] = cmp.mapping.scroll_docs(4),
			["<C-e>"] = cmp.mapping.abort(),

			-- Next item, or trigger completion, or insert normal tab
			["<Tab>"] = cmp.mapping(function(fallback)
				if cmp.visible() then
					cmp.select_next_item()
				else
					fallback()
				end
			end, { "i", "s" }),
			["<S-Tab>"] = cmp.mapping(function(fallback)
				if cmp.visible() then
					cmp.select_prev_item()
				else
					fallback()
				end
			end, { "i", "s" }),
			-- Force jumping
			["<D-j>"] = cmp.mapping(function(_)
				if require("luasnip").locally_jumpable(1) then
					require("luasnip").jump(1)
				else
					vim.notify("No more jumps.", vim.log.levels.WARN, { title = "Luasnip" })
				end
			end, { "i", "s" }),
		},
		formatting = {
			fields = { "kind", "abbr", "menu" }, -- order of the fields
			format = function(entry, item)
				local kind_icons = {
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
				}

				-- abbreviate length https://github.com/hrsh7th/nvim-cmp/discussions/609
				-- (height is controlled via pumheight option)
				local max_length = 50
				if #item.abbr > max_length then item.abbr = item.abbr:sub(1, max_length) .. "…" end

				-- icons
				local kindIcon = kind_icons[item.kind] or ""
				item.kind = " " .. kindIcon .. " "
				item.menu = source_icons[entry.source.name]
				if entry.source.name == "fuzzy_buffer" then item.kind = "" end
				return item
			end,
		},
		sources = cmp.config.sources(defaultSources),
	}

	-----------------------------------------------------------------------------

	-- LUA
	cmp.setup.filetype("lua", {
		enabled = function() -- disable annoying --#region suggestions
			local line = vim.api.nvim_get_current_line()
			return not (line:find("%s%-%-?$") or line:find("^%-%-?$"))
		end,
	})

	-- ZSH
	local defaultPlusZsh = vim.tbl_extend("keep", defaultSources, { name = "zsh" })
	cmp.setup.filetype("sh", {
		enabled = function() -- disable the annoying `\[` suggestion
			local col = vim.fn.col(".") - 1
			local charBefore = vim.api.nvim_get_current_line():sub(col, col)
			return charBefore ~= "\\"
		end,
		sources = cmp.config.sources(defaultPlusZsh),
	})

	-- COMMANDLINE
	cmp.setup.cmdline(":", {
		mapping = cmp.mapping.preset.cmdline(),
		enabled = function()
			-- ignore for :IncRename, numb.nvim, and :s -- https://github.com/hrsh7th/nvim-cmp/wiki/Advanced-techniques#disabling-cmdline-completion-for-certain-commands-such-as-increname
			local cmd = vim.fn.getcmdline()
			if cmd:find("^IncRename ") or cmd:find("^%d+$") or cmd:find("^s ") then
				cmp.close()
				return false
			end
			return true
		end,
		sources = cmp.config.sources {
			{ name = "path" },
			{ name = "cmdline" },
			{ name = "cmdline_history", keyword_length = 2 },
		},
	})

	cmp.setup.cmdline({ "/", "?" }, {
		mapping = cmp.mapping.preset.cmdline(),
		sources = {
			{ name = "treesitter", max_item_count = 3 },
		},
	})
end

--------------------------------------------------------------------------------

return {
	{ -- Completion Engine + Sources
		"hrsh7th/nvim-cmp",
		event = { "InsertEnter", "CmdlineEnter" },
		config = cmpconfig,
		dependencies = {
			"hrsh7th/cmp-path",
			"hrsh7th/cmp-cmdline",
			"hrsh7th/cmp-emoji",
			"dmitmel/cmp-cmdline-history",
			"tamago324/cmp-zsh", -- some shell completions
			"ray-x/cmp-treesitter",
			"hrsh7th/cmp-nvim-lsp", -- LSP input
			"L3MON4D3/LuaSnip", -- snippet engine
			"saadparwaiz1/cmp_luasnip", -- adapter for snippet engine
		},
	},
	{ -- Snippet Engine
		"L3MON4D3/LuaSnip",
		event = "InsertEnter",
		config = function()
			-- DOCS https://github.com/L3MON4D3/LuaSnip/blob/master/DOC.md#api-reference
			require("luasnip").setup {
				region_check_events = "CursorMoved", -- prevent <Tab> jumping back to a snippet after it has been left early
				update_events = { "TextChanged", "TextChangedI" }, -- live updating of snippets
			}

			-- VS-code-style snippets
			require("luasnip.loaders.from_vscode").lazy_load { paths = "./snippets" }
		end,
	},
}
