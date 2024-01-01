local u = require("config.utils")
--------------------------------------------------------------------------------

local defaultSources = {
	{ name = "luasnip" },
	{ name = "nvim_lsp" },
	{
		name = "buffer",
		option = {
			get_bufnrs = function()
				local allBufs = vim.fn.getbufinfo { buflisted = 1 }
				local allBufNums = vim.tbl_map(function(buf) return buf.bufnr end, allBufs)
				return allBufNums
			end,
			max_indexed_line_length = 120, -- no long lines (e.g. base64-encoded things)
		},
		keyword_length = 3,
		max_item_count = 5, -- since searching all buffers results in many results
	},
	{ name = "path" },
	{ name = "emoji" },
}

local sourceIcons = {
	buffer = "󰽙",
	cmdline = "󰘳",
	cmdline_history = "󰋚",
	emoji = "󰞅",
	luasnip = "",
	nvim_lsp = "󰒕",
	path = "",
	zsh = "",
}

--------------------------------------------------------------------------------

local function cmpconfig()
	local cmp = require("cmp")
	local compare = require("cmp.config.compare")

	cmp.setup {
		snippet = {
			expand = function(args) require("luasnip").lsp_expand(args.body) end,
		},
		window = {
			completion = { border = u.borderStyle, scrolloff = 2 },
			documentation = { border = u.borderStyle, scrolloff = 2 },
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
			["<PageUp>"] = cmp.mapping.scroll_docs(-4),
			["<PageDown>"] = cmp.mapping.scroll_docs(4),
			["<C-e>"] = cmp.mapping.abort(),
			["<D-t>"] = cmp.mapping.complete(), -- manually triggering useful for yaml/json

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
			-- Jumping to next location
			["<D-j>"] = cmp.mapping(function(_)
				if require("luasnip").locally_jumpable(1) then
					require("luasnip").jump(1)
				else
					vim.notify("No more jumps.", vim.log.levels.WARN, { title = "Luasnip" })
				end
			end, { "i", "s" }),
		},
		formatting = {
			fields = { "abbr", "menu", "kind" }, -- order of the fields
			format = function(entry, item)
				-- abbreviate length https://github.com/hrsh7th/nvim-cmp/discussions/609
				-- (height is controlled via pumheight option)
				local maxLength = 50
				if #item.abbr > maxLength then item.abbr = item.abbr:sub(1, maxLength) .. "…" end

				-- stylua: ignore
				local kindIcons = { Text = "", Method = "󰆧", Function = "󰊕", Constructor = "", Field = "󰇽", Variable = "󰂡", Class = "󰠱", Interface = "", Module = "", Property = "󰜢", Unit = "", Value = "󰎠", Enum = "", Keyword = "󰌋", Snippet = "󰅱", Color = "󰏘", File = "󰈙", Reference = "", Folder = "󰉋", EnumMember = "", Constant = "󰏿", Struct = "", Event = "", Operator = "󰆕", TypeParameter = "󰅲" }
				item.kind = entry.source.name == "nvim_lsp" and kindIcons[item.kind] or ""
				item.menu = sourceIcons[entry.source.name]
				return item
			end,
		},
		sources = cmp.config.sources(defaultSources),
	}

	-----------------------------------------------------------------------------

	-- LUA
	-- disable annoying --#region suggestions
	cmp.setup.filetype("lua", {
		enabled = function()
			local line = vim.api.nvim_get_current_line()
			return not (line:find("%s%-%-?$") or line:find("^%-%-?$"))
		end,
	})

	-- ZSH
	-- add cmp-zsh source
	local defaultPlusZsh = vim.deepcopy(defaultSources)
	table.insert(defaultPlusZsh, { name = "zsh" })
	cmp.setup.filetype({ "sh", "make" }, {
		sources = cmp.config.sources(defaultPlusZsh),
		-- disable useless `\[` suggestions at end of line
		enabled = function()
			local col = vim.fn.col(".") - 1
			local charBefore = vim.api.nvim_get_current_line():sub(col, col)
			return charBefore ~= "\\"
		end,
	})

	-- COMMANDLINE
	cmp.setup.cmdline(":", {
		mapping = cmp.mapping.preset.cmdline(),
		sources = cmp.config.sources {
			{ name = "path" },
			{ name = "cmdline" },
			{ name = "cmdline_history" },
		},
	})

	cmp.setup.cmdline({ "/", "?" }, {
		mapping = cmp.mapping.preset.cmdline(),
		sources = {
			{ name = "buffer", max_item_count = 2, keyword_length = 2 },
			{ name = "cmdline_history", max_item_count = 2, keyword_length = 2 },
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
			{ "chrisgrieser/cmp-emoji", branch = "dev" }, -- PENDING https://github.com/hrsh7th/cmp-emoji/pull/9
			"hrsh7th/cmp-path",
			"hrsh7th/cmp-cmdline",
			"dmitmel/cmp-cmdline-history",
			"tamago324/cmp-zsh", -- some shell completions
			"hrsh7th/cmp-buffer",
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
				-- prevent <Tab> jumping back to a snippet after it has been left early
				region_check_events = "CursorMoved",
				-- live updating of snippets
				update_events = { "TextChanged", "TextChangedI" },
				-- disable auto-reload, since already done by my own plugin
				fs_event_providers = { autocmd = false, libuv = false },
			}

			-- VS-code-style snippets
			require("luasnip.loaders.from_vscode").lazy_load { paths = "./snippets" }
		end,
	},
	{ -- snippet management
		"chrisgrieser/nvim-scissors",
		init = function() u.leaderSubkey("n", " Snippets") end,
		keys = {
			{
				"<leader>nn",
				function() require("scissors").editSnippet() end,
				desc = " Edit snippets",
			},
			{
				"<leader>na",
				function() require("scissors").addNewSnippet() end,
				mode = { "n", "x" },
				desc = " Add new snippets",
			},
		},
		opts = {
			editSnippetPopup = {
				height = 0.4, -- between 0-1
				width = 0.7,
				border = u.borderStyle,
				keymaps = { delete = "<D-BS>" },
			},
			jsonFormatter = "yq",
		},
	},
}
