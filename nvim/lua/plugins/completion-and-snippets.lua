--# selene: allow(mixed_table) -- lazy.nvim uses them
local defaultSources = {
	{ name = "luasnip" },
	{
		name = "nvim_lsp",
		entry_filter = function(entry)
			-- remove suggestions of type "Text"
			-- local kind = require("cmp.types").lsp.CompletionItemKind[entry:get_kind()]
			-- return kind ~= "Text"
			return entry ~= nil
		end,
	},
	{
		name = "buffer",
		option = {
			get_bufnrs = vim.api.nvim_list_bufs, -- all buffers instead of only the current
			max_indexed_line_length = 120, -- no long lines (e.g. base64-encoded things)
		},
		keyword_length = 3,
		max_item_count = 5, -- since searching all buffers results in many results
	},
	{
		name = "cmp_yanky",
		option = { onlyCurrentFiletype = true, minLength = 5 },
	},
	{ name = "path" },
	{ name = "emoji" },
}

local sourceIcons = {
	buffer = "󰽙",
	cmdline = "󰘳",
	cmdline_history = "󰋚",
	cmp_yanky = "󰅍",
	emoji = "󰞅",
	luasnip = "󰞘",
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
			completion = {
				border = require("config.utils").borderStyle,
				scrolloff = 2,
			},
			documentation = {
				border = require("config.utils").borderStyle,
				scrolloff = 2,
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
			["<PageUp>"] = cmp.mapping.scroll_docs(-4),
			["<PageDown>"] = cmp.mapping.scroll_docs(4),
			["<C-e>"] = cmp.mapping.abort(),
			["<D-c>"] = cmp.mapping.complete(), -- manually triggereing useful for yaml/json

			-- Next item, or trigger completion, or insert normal tab
			["<Tab>"] = cmp.mapping(function(fallback)
				local function onlyWhitespaceBefCursor()
					local col = vim.api.nvim_win_get_cursor(0)[2]
					local charsBefore = vim.api.nvim_get_current_line():sub(1, col)
					return charsBefore:match("^%s*$") ~= nil
				end

				if cmp.visible() then
					cmp.select_next_item()
				elseif not onlyWhitespaceBefCursor() then
					cmp.complete()
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
				-- stylua: ignore
				local kindIcons = { Text = "", Method = "󰆧", Function = "󰊕", Constructor = "", Field = "󰇽", Variable = "󰂡", Class = "󰠱", Interface = "", Module = "", Property = "󰜢", Unit = "", Value = "󰎠", Enum = "", Keyword = "󰌋", Snippet = "󰅱", Color = "󰏘", File = "󰈙", Reference = "", Folder = "󰉋", EnumMember = "", Constant = "󰏿", Struct = "", Event = "", Operator = "󰆕", TypeParameter = "󰅲" }
				item.kind = entry.source.name == "nvim_lsp" and kindIcons[item.kind] .. " " or ""
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
	cmp.setup.filetype("sh", {
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
			"chrisgrieser/cmp_yanky",
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
