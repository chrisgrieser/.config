-- source definitions
local s = {
	emojis = { name = "emoji", keyword_length = 2 },
	nerdfont = { name = "nerdfont", keyword_length = 2 },
	buffer = { name = "buffer", keyword_length = 3 },
	fuzzybuffer = { name = "fuzzy_buffer", max_item_count = 5 },
	path = { name = "path" },
	zsh = { name = "zsh" },
	codeium = { name = "codeium" },
	snippets = { name = "luasnip" },
	lsp = { name = "nvim_lsp" },
	treesitter = { name = "treesitter" },
	cmdline_history = { name = "cmdline_history", keyword_length = 2 },
	cmdline = { name = "cmdline" },
	diag_codes = { name = "diag-codes" },
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
	["diag-codes"] = "",
}
local defaultSources = {
	s.snippets,
	s.codeium,
	s.lsp,
	s.diag_codes,
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
			-- REQUIRED a snippet engine must be specified and installed
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
			["<PageUp>"] = cmp.mapping.scroll_docs(-4),
			["<PageDown>"] = cmp.mapping.scroll_docs(4),

			-- Next item, or trigger completion, or insert normal tab
			["<Tab>"] = cmp.mapping(function(fallback)
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

	cmp.setup.filetype("lua", {
		enabled = function() -- disable leading "-"
			local lineContent = vim.fn.getline(".")
			return not (lineContent:match("%s%-%-?$") or lineContent:match("^%-%-?$"))
		end,
		sources = cmp.config.sources {
			s.snippets,
			s.lsp,
			s.diag_codes,
			s.codeium,
			s.nerdfont, -- add nerdfont for config
			s.emojis,
			s.treesitter,
			s.buffer,
		},
	})

	cmp.setup.filetype("toml", {
		sources = cmp.config.sources {
			s.snippets,
			s.lsp,
			s.diag_codes,
			s.codeium,
			s.nerdfont, -- add nerdfont for config
			s.emojis,
			s.treesitter,
			s.buffer,
		},
	})

	cmp.setup.filetype("css", {
		sources = cmp.config.sources {
			s.snippets,
			s.lsp,
			s.diag_codes,
			s.codeium,
			s.emojis,
			-- buffer and treesitter too slow on big files
		},
	})

	cmp.setup.filetype("markdown", {
		sources = cmp.config.sources {
			s.snippets,
			s.diag_codes,
			s.treesitter,
			s.path, -- e.g. image paths
			s.lsp,
			s.emojis,
		},
	})

	cmp.setup.filetype("yaml", {
		sources = cmp.config.sources {
			s.lsp, -- prioritize schemas
			s.snippets,
			s.diag_codes,
			s.treesitter, -- useful when no schemas
			s.emojis,
			s.buffer,
		},
	})
	cmp.setup.filetype("json", {
		sources = cmp.config.sources {
			s.lsp, -- prioritize schemas
			s.snippets,
			s.diag_codes,
			s.treesitter, -- useful when no schema
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
			s.diag_codes,
			s.path,
			s.codeium,
			s.treesitter,
			s.buffer,
			s.emojis,
			s.nerdfont, -- used for some configs
		},
	})

	-- in big bibliographies, other stuff performs too slow
	cmp.setup.filetype("bib", {
		sources = cmp.config.sources {
			s.snippets,
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
			local disabled = {
				IncRename = true,
				s = true, -- :substitute
				sm = true, -- :substitute (magic)
			}
			local cmd = vim.fn.getcmdline():match("%S+") -- Get first word of cmdline
			-- Return true if cmd isn't disabled
			-- else call/return cmp.close(), which returns false
			return not disabled[cmd] or cmp.close()
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
			"JMarkin/cmp-diag-codes",
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
	{ -- AI completion
		"jcdickinson/codeium.nvim",
		lazy = true, -- loaded by cmp
		dependencies = { "nvim-lua/plenary.nvim", "hrsh7th/nvim-cmp" },
		opts = {
			config_path = vim.env.DATA_DIR .. "/private dotfiles/codium-api-key.json",
			bin_path = vim.fn.stdpath("data") .. "/codeium",
		},
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
