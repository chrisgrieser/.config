-- source definitions
local s = {
	emojis = { name = "emoji", keyword_length = 2 },
	nerdfont = { name = "nerdfont", keyword_length = 2 },
	buffer = { name = "buffer", keyword_length = 3 },
	-- max count for performance and to ensure the popup isn't too high
	fuzzybuffer = { name = "fuzzy_buffer", max_item_count = 3 },
	path = { name = "path" },
	zsh = { name = "zsh" },
	codeium = { name = "codeium" },
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
	codeium = "󰚩",
	luasnip = "󰞘",
	emoji = "󰇵",
	nerdfont = "󰇳",
	path = "",
	cmdline = "󰘳",
	cmdline_history = "󰋚",
}
local defaultSources = {
	s.snippets,
	s.codeium,
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
			-- lower values for lag-free performance
			-- default values: https://github.com/hrsh7th/nvim-cmp/blob/main/lua/cmp/config/default.lua#L18
			-- explanations: https://github.com/hrsh7th/nvim-cmp/blob/main/doc/cmp.txt#L403
			debounce = 20,
			throttle = 10,
			max_view_entries = 50,
			fetching_timeout = 100,
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
				compare.kind, -- higher (prioritize snippets)
				compare.locality,
				compare.exact, -- lower
				compare.length,
				compare.order,
			},
		},
		mapping = cmp.mapping.preset.insert {
			["<CR>"] = cmp.mapping.confirm { select = true }, -- true = autoselect first entry
			["<D-Esc>"] = cmp.mapping.complete(), -- like with macOS autocomplete
			["<C-e>"] = cmp.mapping.abort(),
			["<S-CR>"] = cmp.mapping.abort(), -- accept current text, consistent with Obsidian https://medium.com/obsidian-observer/obsidian-quick-tip-use-shift-enter-to-skip-autocomplete-on-links-8495ea189c4c
			["<PageUp>"] = cmp.mapping.scroll_docs(-4),
			["<PageDown>"] = cmp.mapping.scroll_docs(4),

			-- Next item, or trigger completion, or insert normal tab
			["<Tab>"] = cmp.mapping(function(fallback)
				vim.fn['codeium#Clear']() -- remove virtual text when not used anyway
				if require("luasnip").choice_active() then
					cmp.abort()
					require("luasnip").change_choice(1)
				elseif cmp.visible() then
					cmp.select_next_item()
				else
					fallback()
				end
			end, { "i", "s" }),
			["<S-Tab>"] = cmp.mapping(function(fallback)
				if require("luasnip").choice_active() then
					require("luasnip").change_choice(-1)
				elseif cmp.visible() then
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
					vim.notify("No more jumps.")
				end
			end, { "i", "s" }),
		},
		formatting = {
			fields = { "kind", "abbr", "menu" }, -- order of the fields
			format = function(entry, vim_item)
				-- abbreviate length https://github.com/hrsh7th/nvim-cmp/discussions/609
				-- (height is controlled via pumheight option)
				local max_length = 45
				if #vim_item.abbr > max_length then
					vim_item.abbr = vim_item.abbr:sub(1, max_length) .. "…"
				end

				-- icons
				local kindIcon = kind_icons[vim_item.kind] or ""
				vim_item.kind = " " .. kindIcon .. " "
				vim_item.menu = source_icons[entry.source.name]
				if entry.source.name == "fuzzy_buffer" then vim_item.kind = "" end
				return vim_item
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
			if vim.bo.filetype ~= "lua" then return true end
			local lineContent = vim.fn.getline(".")
			return not (lineContent:match("%s%-%-?$") or lineContent:match("^%-%-?$"))
		end,
		sources = cmp.config.sources {
			s.snippets,
			s.lsp,
			s.codeium,
			s.nerdfont, -- add nerdfont for config
			s.emojis,
			s.treesitter,
			s.buffer,
		},
	})

	cmp.setup.filetype("css", {
		sources = cmp.config.sources {
			s.lsp,
			s.snippets,
			s.codeium,
			s.emojis,
			-- buffer and treesitter too slow on big files
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
			s.buffer,
		},
	})

	cmp.setup.filetype("sh", {
		-- disable the annoying `\[` suggestion
		enabled = function()
			local col = vim.fn.col(".") - 1
			local charBefore = vim.fn.getline("."):sub(col, col)
			return charBefore ~= "\\"
		end,
		sources = cmp.config.sources {
			s.snippets,
			s.zsh, -- completion from zsh itself
			s.lsp,
			s.path,
			s.codeium,
			s.treesitter,
			s.buffer,
			s.nerdfont, -- used for some configs
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

	-- config files (e.g. ignore files)
	cmp.setup.filetype("conf", {
		sources = cmp.config.sources {
			s.snippets,
			s.path,
			s.codeium,
			s.buffer,
		},
	})

	-- vimscript (e.g., obsidian.vimrc)
	cmp.setup.filetype("vim", {
		sources = cmp.config.sources {
			s.snippets,
			s.treesitter,
			s.codeium,
			s.buffer,
		},
	})

	-- plaintext
	cmp.setup.filetype("text", {
		sources = cmp.config.sources {
			s.snippets,
			s.buffer,
			s.emojis,
			s.codeium,
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
			s.path,
			s.cmdline,
		}, { -- second array only relevant when no source from the first matches
			s.cmdline_history,
		}),
	})

	cmp.setup.cmdline({ "/", "?" }, {
		mapping = cmp.mapping.preset.cmdline(),
		sources = { s.fuzzybuffer },
	})
end

--------------------------------------------------------------------------------

return {
	{ -- Completion Engine + Sources
		"hrsh7th/nvim-cmp",
		event = { "InsertEnter", "CmdlineEnter" }, -- CmdlineEnter for completions there
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
			{ "chrisgrieser/cmp-nerdfont", dev = true },
			"tamago324/cmp-zsh", -- some shell completions
			"jcdickinson/codeium.nvim", -- AI completions
			"ray-x/cmp-treesitter",
			"hrsh7th/cmp-nvim-lsp", -- LSP input
			"L3MON4D3/LuaSnip", -- snippet engine
			"saadparwaiz1/cmp_luasnip", -- adapter for snippet engine
		},
	},
	{ -- for fuzzy searching the buffer via /
		"tzachar/cmp-fuzzy-buffer",
		lazy = true, -- loaded by cmp
		dependencies = {
			"hrsh7th/nvim-cmp",
			{
				"tzachar/fuzzy.nvim",
				dependencies = { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
			},
		},
	},
	{ -- AI completion (virtual text)
		"Exafunction/codeium.vim",
		event = "InsertEnter",
		build = function()
			-- HACK enable	syncing of API key
			local symlinkCmd = ("ln -sf '%s' '%s'"):format(
				vim.env.DATA_DIR .. "/private dotfiles/codium-api-key.json",
				vim.env.HOME .. "/.codeium/config.json"
			)
			vim.fn.system(symlinkCmd)
		end,
		init = function()
			vim.g.codeium_disable_bindings = 1
			vim.g.codeium_filetypes = {
				["DressingInput"] = false,
			}
			vim.keymap.set(
				"i",
				"<D-s>",
				function() return vim.fn["codeium#Accept"]() end,
				{ expr = true, desc = "󰚩 Accept Suggestion" }
			)
		end,
	},
	{ -- AI completion (suggestion)
		"jcdickinson/codeium.nvim",
		lazy = true, -- loaded by cmp
		dependencies = { "nvim-lua/plenary.nvim", "hrsh7th/nvim-cmp" },
		opts = {
			config_path = vim.env.DATA_DIR .. "/private dotfiles/codium-api-key.json",
			bin_path = vim.fn.stdpath("data") .. "/codeium",
		},
		-- FIX https://github.com/jcdickinson/codeium.nvim/issues/58
		build = function()
			local bin_path = vim.fn.stdpath("data") .. "/codeium"
			local oldBinaries = vim.fs.find(
				function() return true end,
				{ type = "file", limit = math.huge, path = bin_path }
			)
			table.remove(oldBinaries) -- remove last item (= most up to date binary) from list
			for _, binaryPath in pairs(oldBinaries) do
				os.remove(binaryPath)
				os.remove(vim.fs.dirname(binaryPath))
			end
		end,
	},
	{ -- Snippet Engine
		"L3MON4D3/LuaSnip",
		event = "InsertEnter",
		config = function()
			-- https://github.com/L3MON4D3/LuaSnip/blob/master/DOC.md#api-reference
			require("luasnip").setup {
				region_check_events = "CursorMoved", -- prevent <Tab> jumping back to a snippet after it has been left early
				update_events = "TextChanged,TextChangedI", -- live updating of snippets
				enable_autosnippets = true, -- for javascript "if ()"
				ext_opts = { -- https://github.com/L3MON4D3/LuaSnip/blob/master/DOC.md#ext_opts highlight when at a choice node
					[require("luasnip.util.types").choiceNode] = {
						active = { hl_group = "DiagnosticHint", virt_text = { { "󰊖 ", "DiagnosticHint" } } },
					},
				},
			}

			-- VS-code-style snippets
			require("luasnip.loaders.from_vscode").lazy_load { paths = "./snippets" }
		end,
	},
}
