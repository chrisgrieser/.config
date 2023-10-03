local s = {
	emojis = { name = "emoji", keyword_length = 2 },
	nerdfont = { name = "nerdfont", keyword_length = 2 },
	buffer = { name = "buffer", keyword_length = 4 },
	fuzzy_buffer = { name = "fuzzy_buffer", max_item_count = 3 },
	path = { name = "path" },
	zsh = { name = "zsh" },
	snippets = { name = "luasnip" },
	lsp = { name = "nvim_lsp" },
	treesitter = { name = "treesitter" },
	cmdline_history = { name = "cmdline_history", keyword_length = 2 },
	cmdline = { name = "cmdline" },
}
local source_icons = {
	treesitter = "",
	buffer = "󰽙",
	fuzzy_buffer = "f",
	zsh = "",
	nvim_lsp = "󰒕",
	luasnip = "󰞘",
	emoji = "󰇵",
	nerdfont = "󰇳",
	path = "",
	cmdline = "󰘳",
	cmdline_history = "󰋚",
}
local defaultSources = {
	s.luasnip_choice,
	s.snippets,
	s.lsp,
	s.emojis,
	s.treesitter,
	s.buffer,
}
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
--------------------------------------------------------------------------------

local function cmpconfig()
	local cmp = require("cmp")
	local compare = require("cmp.config.compare")
	local u = require("config.utils")

	cmp.setup {
		snippet = {
			expand = function(args) require("luasnip").lsp_expand(args.body) end,
		},
		performance = {
			-- PERF lower values for lag-free performance
			-- default values: https://github.com/hrsh7th/nvim-cmp/blob/main/lua/cmp/config/default.lua#L18
			-- explanations: https://github.com/hrsh7th/nvim-cmp/blob/main/doc/cmp.txt#L425
			debounce = 30,
			throttle = 20,
			fetching_timeout = 250,
			async_budget = 0.8,
			max_view_entries = 100,
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
end

--------------------------------------------------------------------------------

local function filetypeCompletionConfig()
	local cmp = require("cmp")

	-- disable in special filetypes
	cmp.setup.filetype("", { enabled = false })

	cmp.setup.filetype({ "lua", "toml" }, {
		enabled = function() -- disable leading "-" in lua
			local line = vim.api.nvim_get_current_line()
			return not (line:find("%s%-%-?$") or line:find("^%-%-?$"))
		end,
		sources = cmp.config.sources {
			s.luasnip_choice,
			s.snippets,
			s.lsp,
			s.nerdfont, -- add nerdfont for config
			s.emojis,
			s.treesitter,
		},
	})

	cmp.setup.filetype("css", {
		sources = cmp.config.sources {
			s.lsp,
			s.snippets,
			s.emojis,
		},
	})

	cmp.setup.filetype("markdown", {
		sources = cmp.config.sources {
			s.snippets,
			s.treesitter,
			s.path, -- e.g. image paths
			s.lsp,
			s.emojis,
		},
	})

	cmp.setup.filetype({ "yaml", "json" }, {
		sources = cmp.config.sources {
			s.lsp, -- prioritize schemas
			s.snippets,
			s.treesitter, -- useful when no schemas
			s.emojis,
		},
	})

	cmp.setup.filetype("sh", {
		-- disable the annoying `\[` suggestion
		enabled = function()
			local col = vim.fn.col(".") - 1
			local charBefore = vim.api.nvim_get_current_line():sub(col, col)
			return charBefore ~= "\\"
		end,
		sources = cmp.config.sources {
			s.snippets,
			s.zsh, -- completion from zsh itself
			s.lsp,
			s.path,
			s.treesitter,
			s.nerdfont, -- used for some configs
			s.emojis,
		},
	})

	cmp.setup.filetype("make", {
		sources = cmp.config.sources {
			s.path,
			s.zsh,
			s.emojis,
		},
	})

	-- in big bibliographies, other stuff performs too slow
	cmp.setup.filetype("bib", {
		sources = cmp.config.sources {
			s.snippets,
			s.buffer, -- for consistent keyword usage
		},
	})

	-- config files
	cmp.setup.filetype({ "conf", "ini", "gitignore" }, {
		sources = cmp.config.sources {
			s.snippets,
			s.path,
			s.buffer,
		},
	})

	-- vimscript (e.g., obsidian.vimrc)
	cmp.setup.filetype("vim", {
		sources = cmp.config.sources {
			s.snippets,
			s.treesitter,
			s.buffer,
		},
	})

	-- plaintext
	cmp.setup.filetype("text", {
		sources = cmp.config.sources {
			s.snippets,
			s.buffer,
			s.emojis,
		},
	})
end

local function cmdlineCompletionConfig()
	local cmp = require("cmp")

	cmp.setup.cmdline(":", {
		mapping = cmp.mapping.preset.cmdline(),
		enabled = function()
			-- https://github.com/hrsh7th/nvim-cmp/wiki/Advanced-techniques#disabling-cmdline-completion-for-certain-commands-such-as-increname
			local cmd = vim.fn.getcmdline()
			-- ignore for :IncRename, numb.nvim, and :s
			if cmd:find("^IncRename ") or cmd:find("^%d+$") or cmd:find("^s ") then
				cmp.close()
				return false
			end
			return true
		end,
		sources = cmp.config.sources({
		}),
	})

	cmp.setup.cmdline({ "/", "?" }, {
		mapping = cmp.mapping.preset.cmdline(),
		sources = { s.fuzzy_buffer },
	})
end

--------------------------------------------------------------------------------

return {
	{ -- Completion Engine + Sources
		"hrsh7th/nvim-cmp",
		event = { "InsertEnter", "CmdlineEnter" }, 
		config = function()
			cmpconfig()
			filetypeCompletionConfig()
			cmdlineCompletionConfig()
		end,
		dependencies = {
			"hrsh7th/cmp-buffer",
			"tzachar/cmp-fuzzy-buffer",
			"hrsh7th/cmp-path",
			"hrsh7th/cmp-cmdline",
			"dmitmel/cmp-cmdline-history",
			"hrsh7th/cmp-emoji",
			"chrisgrieser/cmp-nerdfont",
			"tamago324/cmp-zsh", -- some shell completions
			"ray-x/cmp-treesitter",
			"hrsh7th/cmp-nvim-lsp", -- LSP input
			"L3MON4D3/LuaSnip", -- snippet engine
			"saadparwaiz1/cmp_luasnip", -- adapter for snippet engine
		},
	},
	{ -- for fuzzy searching the buffer via /
		"tzachar/cmp-fuzzy-buffer",
		dependencies = {
			"hrsh7th/nvim-cmp",
			{ "tzachar/fuzzy.nvim", dependencies = "nvim-telescope/telescope-fzf-native.nvim" },
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
