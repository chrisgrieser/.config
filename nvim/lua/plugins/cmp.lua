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
			fields = { "abbr", "kind" }, -- order of the fields
			format = function(entry, item)
				local maxLen = 40
				local sourceIcons =
					{ buffer = "󰽙", snippets = "󰩫", emmet = "󰯸", lsp_snip = "󰒕" }

				local kindIcons = {
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
				local icon = sourceIcons[entry.source.name]

				-- differentiate snippets from LSPs, the user, and emmet
				if entry.source.name == "nvim_lsp" then
					icon = kindIcons[item.kind]
					if item.kind == "Snippet" then
						icon = entry.context.filetype == "css" and sourceIcons.emmet
							or sourceIcons.lsp_snip
					end
				end

				-- abbreviate length https://github.com/hrsh7th/nvim-cmp/discussions/609
				-- (height is controlled via pumheight option)
				if #item.abbr > maxLen then item.abbr = (item.abbr or ""):sub(1, maxLen) .. "…" end

				item.kind = icon
				return item
			end,
		},
		sources = cmp.config.sources {
			{ name = "snippets" },
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
		},
	}

	-----------------------------------------------------------------------------

	-- LUA: disable annoying `--#region` suggestions
	cmp.setup.filetype("lua", {
		enabled = function()
			local line = vim.api.nvim_get_current_line()
			local hasDoubleDash = line:find("%s%-%-?$") or line:find("^%-%-?$")
			return not hasDoubleDash
		end,
	})

	cmp.setup.cmdline({ "/", "?" }, {
		mapping = cmp.mapping.preset.cmdline(),
		sources = {
			{ name = "buffer", max_item_count = 3, keyword_length = 2 },
		},
	})
end

--------------------------------------------------------------------------------

return { -- Completion Engine + Sources
	"hrsh7th/nvim-cmp",
	event = { "InsertEnter", "CmdlineEnter" },
	dependencies = {
		"hrsh7th/cmp-nvim-lsp",
		{ "garymjr/nvim-snippets", opts = true },
		"hrsh7th/cmp-buffer",
	},
	config = cmpconfig,
}