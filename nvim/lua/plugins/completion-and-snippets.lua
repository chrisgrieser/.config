local u = require("config.utils")
--------------------------------------------------------------------------------

local function cmpconfig()
	local cmp = require("cmp")
	local compare = require("cmp.config.compare")

	cmp.setup {
		view = {
			entries = { follow_cursor = true }, ---@diagnostic disable-line: missing-fields
		},
		performance = {
			-- all reduced, defaults: https://github.com/hrsh7th/nvim-cmp/blob/main/lua/cmp/config/default.lua#L18-L25
			debounce = 30,
			throttle = 15,
			fetching_timeout = 300,
			confirm_resolve_timeout = 40,
			async_budget = 0.5,
			max_view_entries = 100,
		},
		window = {
			completion = { border = vim.g.borderStyle, scrolloff = 2 },
			documentation = { border = vim.g.borderStyle, scrolloff = 2 },
		},
		sorting = { ---@diagnostic disable-line: missing-fields
			comparators = {
				-- defaults: https://github.com/hrsh7th/nvim-cmp/blob/main/lua/cmp/config/default.lua#L67-L78
				-- compare functions https://github.com/hrsh7th/nvim-cmp/blob/main/lua/cmp/config/compare.lua
				compare.offset,
				compare.recently_used, -- higher
				compare.score,
				compare.kind, -- higher (prioritize snippets)
				compare.exact, -- lower
				compare.locality,
				compare.length,
				compare.order,
			},
		},
		mapping = cmp.mapping.preset.insert {
			["<CR>"] = cmp.mapping.confirm { select = true },
			["<PageUp>"] = cmp.mapping.scroll_docs(-5),
			["<PageDown>"] = cmp.mapping.scroll_docs(5),
			["<Esc>"] = cmp.mapping(function(fallback)
				if cmp.visible() then cmp.abort() end
				fallback()
			end),

			-- manually triggering to only include LSP, useful for yaml/json/css
			["<D-c>"] = cmp.mapping.complete {
				config = {
					sources = cmp.config.sources {
						{ name = "nvim_lsp" },
					},
				},
			},

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
		},
		formatting = { ---@diagnostic disable-line: missing-fields
			fields = { "abbr", "menu", "kind" }, -- order of the fields
			format = function(entry, item)
				local maxLength = 40
				local sourceIcons = {
					buffer = "󰽙",
					cmdline = "󰘳",
					snippets = "",
					nvim_lsp = "󰒕",
					path = "",
					emmet = "",
				}
				local kindIcons = {
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
				if #item.abbr > maxLength then
					item.abbr = (item.abbr or ""):sub(1, maxLength) .. "…"
				end

				-- distinguish emmet snippets
				local isEmmet = entry.source.name == "nvim_lsp"
					and item.kind == "Snippet"
					and vim.bo[entry.context.bufnr].filetype == "css"
				if isEmmet then entry.source.name = "emmet" end

				item.kind = entry.source.name == "nvim_lsp" and kindIcons[item.kind] or ""
				item.menu = (sourceIcons[entry.source.name] or "") .. " "
				return item
			end,
		},
		sources = cmp.config.sources {
			{ name = "snippets", priority = 10 },
			{
				name = "nvim_lsp",
				entry_filter = function(entry, _)
					-- using cmp-buffer for this
					return require("cmp.types").lsp.CompletionItemKind[entry:get_kind()] ~= "Text"
				end,
			},
			{
				name = "buffer",
				option = {
					-- show completions from all buffers used within the last x minutes
					get_bufnrs = function()
						local mins = 15 -- CONFIG
						local recentBufs = vim.iter(vim.fn.getbufinfo { buflisted = 1 })
							:filter(function(buf) return os.time() - buf.lastused < mins * 60 end)
							:map(function(buf) return buf.bufnr end)
							:totable()
						return recentBufs
					end,
					max_indexed_line_length = 100, -- no long lines (e.g. base64-encoded things)
				},
				keyword_length = 3,
				max_item_count = 4, -- since searching all buffers results in many results
			},
			{ name = "path" },
		},
	}

	-----------------------------------------------------------------------------

	-- LUA: disable annoying `--#region` suggestions
	cmp.setup.filetype("lua", {
		enabled = function()
			local line = vim.api.nvim_get_current_line()
			local doubleDashLine = line:find("%s%-%-?$") or line:find("^%-%-?$")
			return not doubleDashLine
		end,
	})

	-- COMMANDLINE
	cmp.setup.cmdline(":", {
		mapping = cmp.mapping.preset.cmdline(),
		sources = cmp.config.sources {
			{ name = "path" },
			{ name = "cmdline" },
		},
	})

	cmp.setup.cmdline({ "/", "?" }, {
		mapping = cmp.mapping.preset.cmdline(),
		sources = {
			{ name = "buffer", max_item_count = 3, keyword_length = 2 },
		},
	})
end

--------------------------------------------------------------------------------

return {
	{ -- Completion Engine + Sources
		"hrsh7th/nvim-cmp",
		event = { "InsertEnter", "CmdlineEnter" },
		dependencies = {
			"hrsh7th/cmp-nvim-lsp",
			{ "garymjr/nvim-snippets", opts = true },
			"hrsh7th/cmp-buffer",
			"hrsh7th/cmp-path",
			"hrsh7th/cmp-cmdline",
		},
		config = cmpconfig,
	},
	{ -- snippet management
		"chrisgrieser/nvim-scissors",
		dependencies = "nvim-telescope/telescope.nvim",
		external_dependencies = "yq",
		init = function() u.leaderSubkey("n", " Snippets", { "n", "x" }) end,
		keys = {
			{ "<leader>nn", function() require("scissors").editSnippet() end, desc = " Edit" },
			-- stylua: ignore
			{ "<leader>na", function() require("scissors").addNewSnippet() end, mode = { "n", "x" }, desc = " Add" },
		},
		opts = {
			editSnippetPopup = {
				height = 0.5, -- between 0-1
				width = 0.7,
				border = vim.g.borderStyle,
				keymaps = {
					deleteSnippet = "<D-BS>",
					openInFile = "<D-o>",
					insertNextToken = "<D-t>",
				},
			},
			telescope = { alsoSearchSnippetBody = true },
			jsonFormatter = "yq",
		},
	},
}
