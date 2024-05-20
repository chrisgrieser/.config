local u = require("config.utils")
--------------------------------------------------------------------------------

local defaultSources = {
	{ name = "luasnip" },
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
				local usedWithinMins = 15 -- CONFIG
				local recentBufs = vim.iter(vim.fn.getbufinfo { buflisted = 1 })
					:filter(function(buf) return os.time() - buf.lastused < usedWithinMins * 60 end)
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
}

local sourceIcons = {
	buffer = "󰽙",
	cmdline = "󰘳",
	luasnip = "",
	nvim_lsp = "󰒕",
	path = "",
	emmet = "",
}

--------------------------------------------------------------------------------

local function cmpconfig()
	local cmp = require("cmp")
	local compare = require("cmp.config.compare")

	cmp.setup {
		view = {
			entries = { follow_cursor = true },
		},
		window = {
			completion = { border = vim.g.borderStyle, scrolloff = 2 },
			documentation = { border = vim.g.borderStyle, scrolloff = 2 },
		},
		sorting = {
			comparators = {
				-- defaults: https://github.com/hrsh7th/nvim-cmp/blob/main/lua/cmp/config/default.lua#L67-L78
				-- compare function https://github.com/hrsh7th/nvim-cmp/blob/main/lua/cmp/config/compare.lua
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
			["<CR>"] = cmp.mapping.confirm { select = true },
			["<PageUp>"] = cmp.mapping.scroll_docs(-4),
			["<PageDown>"] = cmp.mapping.scroll_docs(4),
			["<C-e>"] = cmp.mapping.abort(),

			-- manually triggering to only include LSP, useful for yaml/json/css
			["<D-c>"] = cmp.mapping.complete {
				config = {
					sources = cmp.config.sources {
						{ name = "nvim_lsp" },
					},
				},
			},

			-- Next item, or trigger completion, or insert normal tab
			["<Tab>"] = cmp.mapping(function(fallback)
				if cmp.visible() then
					-- FIX lag when using `Insert` in css
					local behavior = vim.bo.ft == "css" and "Select" or "Insert"
					cmp.select_next_item { behavior = cmp.SelectBehavior[behavior] }
				else
					fallback()
				end
			end, { "i", "s" }),
			["<S-Tab>"] = cmp.mapping(function(fallback)
				if cmp.visible() then
					local behavior = vim.bo.ft == "css" and "Select" or "Insert"
					cmp.select_prev_item { behavior = cmp.SelectBehavior[behavior] }
				else
					fallback()
				end
			end, { "i", "s" }),
			-- cmd+j: Jump to next location
			["<D-j>"] = cmp.mapping(function(_)
				if vim.snippet.active { direction = 1 } then vim.snippet.jump(1) end
			end, { "i", "s" }),
			-- cmd+shift+j: prev location
			["<D-J>"] = cmp.mapping(function(_)
				if vim.snippet.active { direction = -1 } then vim.snippet.jump(-1) end
			end, { "i", "s" }),
		},
		formatting = {
			fields = { "abbr", "menu", "kind" }, -- order of the fields
			format = function(entry, item)
				-- abbreviate length https://github.com/hrsh7th/nvim-cmp/discussions/609
				-- (height is controlled via pumheight option)
				local maxLength = 50
				if #item.abbr > maxLength then item.abbr = item.abbr:sub(1, maxLength) .. "…" end

				-- distinguish emmet snippets
				local isEmmet = entry.source.name == "nvim_lsp"
					and item.kind == "Snippet"
					and vim.bo[entry.context.bufnr].filetype == "css"
				if isEmmet then entry.source.name = "emmet" end

				-- stylua: ignore
				local kindIcons = { Text = "", Method = "󰆧", Function = "󰊕", Constructor = "", Field = "󰇽", Variable = "󰂡", Class = "󰠱", Interface = "", Module = "", Property = "󰜢", Unit = "", Value = "󰎠", Enum = "", Keyword = "󰌋", Snippet = "󰅱", Color = "󰏘", File = "󰈙", Reference = "", Folder = "󰉋", EnumMember = "", Constant = "󰏿", Struct = "", Event = "", Operator = "󰆕", TypeParameter = "󰅲" }
				item.kind = entry.source.name == "nvim_lsp" and kindIcons[item.kind] or ""
				item.menu = sourceIcons[entry.source.name] .. " "
				return item
			end,
		},
		sources = cmp.config.sources(defaultSources),
	}

	-----------------------------------------------------------------------------

	-- LUA: disable annoying `--#region` suggestions
	cmp.setup.filetype("lua", {
		enabled = function()
			local line = vim.api.nvim_get_current_line()
			return not (line:find("%s%-%-?$") or line:find("^%-%-?$"))
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
		config = cmpconfig,
		dependencies = {
			"hrsh7th/cmp-path",
			"hrsh7th/cmp-cmdline",
			"hrsh7th/cmp-buffer",
			"hrsh7th/cmp-nvim-lsp", -- LSP input
			"L3MON4D3/LuaSnip", -- snippet engine
			"saadparwaiz1/cmp_luasnip", -- adapter for snippet engine
		},
	},
	{ -- Snippet Engine
		"L3MON4D3/LuaSnip",
		init = function()
			-- copy system clipboard to regular register, required for VSCode
			-- snippets with `$CLIPBOARD`
			vim.api.nvim_create_autocmd("FocusGained", {
				callback = function() vim.fn.setreg('"', vim.fn.getreg("+")) end,
			})
		end,
		opts = {
			-- disable auto-reload, since already done by scissors
			fs_event_providers = { autocmd = false, libuv = false },
		},
		config = function(_, opts)
			require("luasnip").setup(opts)
			require("luasnip.loaders.from_vscode").lazy_load { paths = "./snippets" }
		end,
	},
	{ -- snippet management
		"chrisgrieser/nvim-scissors",
		dependencies = "nvim-telescope/telescope.nvim",
		external_dependencies = "yq",
		init = function() u.leaderSubkey("n", " Snippets", { "n", "x" }) end,
		keys = {
			{
				"<leader>nn",
				function() require("scissors").editSnippet() end,
				desc = " Edit snippet",
			},
			{
				"<leader>na",
				function() require("scissors").addNewSnippet() end,
				mode = { "n", "x" },
				desc = " Add new snippet",
			},
		},
		opts = {
			editSnippetPopup = {
				height = 0.45, -- between 0-1
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
