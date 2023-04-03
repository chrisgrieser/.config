-- source definitions
local s = {
	emojis = { name = "emoji", keyword_length = 2 },
	nerdfont = { name = "nerdfont", keyword_length = 2 },
	buffer = { name = "buffer", keyword_length = 3 },
	path = { name = "path" },
	zsh = { name = "zsh" },
	codeium = { name = "codeium" },
	snippets = { name = "luasnip" },
	lsp = { name = "nvim_lsp" },
	treesitter = { name = "treesitter" },
	cmdline_history = { name = "cmdline_history", keyword_length = 3 },
	cmdline = { name = "cmdline" },
}

local defaultSources = {
	s.snippets,
	s.codeium,
	s.lsp,
	s.emojis,
	s.treesitter,
	s.buffer,
}

--------------------------------------------------------------------------------

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

local source_icons = {
	buffer = "󰽙",
	treesitter = "",
	zsh = "",
	nvim_lsp = "󰒕",
	codeium = "",
	luasnip = "󰞘",
	emoji = "󰇵",
	nerdfont = "󰇳",
	cmdline = "",
	cmdline_history = "󰋚",
	path = "",
}

--------------------------------------------------------------------------------

local function cmpconfig()
	local cmp = require("cmp")
	local compare = require("cmp.config.compare")

	cmp.setup {
		snippet = {
			-- REQUIRED a snippet engine must be specified and installed
			expand = function(args) require("luasnip").lsp_expand(args.body) end,
		},
		window = {
			completion = {
				side_padding = 0,
				border = BorderStyle,
			},
			documentation = {
				border = BorderStyle,
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
			["<S-Up>"] = cmp.mapping.scroll_docs(-4),
			["<S-Down>"] = cmp.mapping.scroll_docs(4),

			["<CR>"] = cmp.mapping.confirm { select = true }, -- true = autoselect first entry
			["<M-Esc>"] = cmp.mapping.complete(), -- consistent with macOS autocomplete
			["<C-e>"] = cmp.mapping(function(fallback)
				if cmp.visible() then
					cmp.abort()
				else
					fallback()
				end
			end, { "i", "s" }),

			-- Next item, or trigger completion, or insert normal tab
			["<Tab>"] = cmp.mapping(function(fallback)
				if cmp.visible() then
					cmp.select_next_item()
				elseif require("neogen").jumpable() then
					require("neogen").jump_next()
				elseif require("luasnip").locally_jumpable(1) then
					require("luasnip").jump(1)
				else
					fallback()
				end
			end, { "i", "s" }),
			["<S-Tab>"] = cmp.mapping(function(fallback)
				if cmp.visible() then
					cmp.select_prev_item()
				elseif require("neogen").jumpable(true) then
					require("neogen").jump_prev()
				elseif require("luasnip").locally_jumpable(-1) then
					require("luasnip").jump(-1)
				else
					fallback()
				end
			end, { "i", "s" }),
			-- Force jumping
			["<D-j>"] = cmp.mapping(function(_)
				if require("neogen").jumpable() then
					require("neogen").jump_next()
				elseif require("luasnip").locally_jumpable(1) then
					require("luasnip").jump(1)
				else
					vim.notify("No more jump forwards.")
				end
			end, { "i", "s" }),
			-- Cycle Choices
			["<D-k>"] = cmp.mapping(function(_)
				if require("luasnip").choice_active() then
					require("luasnip").change_choice(1)
				else
					vim.notify("No choices available.")
				end
			end, { "i", "s" }),
		},
		formatting = {
			fields = { "kind", "abbr", "menu" }, -- order of the fields
			format = function(entry, vim_item)
				-- abbreviate length https://github.com/hrsh7th/nvim-cmp/discussions/609
				-- (height is controlled via pumheight option)
				local max_length = 50
				local ellipsis_char = "…"
				if #vim_item.abbr > max_length then
					vim_item.abbr = vim_item.abbr:sub(1, max_length) .. ellipsis_char
				end

				-- icons
				local kindIcon = kind_icons[vim_item.kind] or ""
				vim_item.kind = " " .. kindIcon .. " "
				vim_item.menu = source_icons[entry.source.name]
				return vim_item
			end,
		},
		sources = cmp.config.sources(defaultSources),
	}
end

--------------------------------------------------------------------------------

local function filetypeCompletionConfig()
	local cmp = require("cmp")

	cmp.setup.filetype("lua", {
		enabled = function() -- disable leading "-"
			local lineContent = vim.fn.getline(".") ---@diagnostic disable-line: param-type-mismatch
			return not (lineContent:match("%s%-%-?$") or lineContent:match("^%-%-?$")) ---@diagnostic disable-line: undefined-field
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

	cmp.setup.filetype("toml", {
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

	-- css
	cmp.setup.filetype("css", {
		sources = cmp.config.sources {
			s.snippets,
			s.lsp,
			s.codeium,
			s.emojis,
			-- buffer and treesitter too slow on big files
		},
	})

	-- markdown
	cmp.setup.filetype("markdown", {
		sources = cmp.config.sources {
			s.snippets,
			s.path, -- e.g. image paths
			s.lsp,
			s.emojis,
		},
	})

	cmp.setup.filetype("yaml", {
		sources = cmp.config.sources {
			s.snippets,
			s.treesitter, -- treesitter works good on yaml
			s.lsp,
			s.codeium,
			s.emojis,
			s.buffer,
		},
	})

	-- ZSH
	cmp.setup.filetype("sh", {
		sources = cmp.config.sources {
			s.snippets,
			s.zsh,
			s.lsp,
			s.path,
			s.codeium,
			s.treesitter,
			s.buffer,
			s.emojis,
			s.nerdfont, -- used for some configs
		},
	})

	-- bibtex
	cmp.setup.filetype("bib", {
		sources = cmp.config.sources {
			s.snippets,
			s.treesitter,
			s.buffer,
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

	-- Command Line Completion
	cmp.setup.cmdline(":", {
		mapping = cmp.mapping.preset.cmdline(),
		sources = cmp.config.sources({
			s.path,
			s.cmdline,
		}, { -- second array only relevant when no source from the first matches
			s.cmdline_history,
			s.buffer, -- e.g. for IncRename
		}),
	})

	cmp.setup.cmdline({ "/", "?" }, {
		mapping = cmp.mapping.preset.cmdline(),
		-- Wondering what suggestions could make sense there, other than buffer
		sources = { s.buffer },
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
		end,
		dependencies = {
			"hrsh7th/cmp-buffer",
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
	{ -- AI completion
		"jcdickinson/codeium.nvim",
		lazy = true, -- loaded by cmp
		dependencies = { "nvim-lua/plenary.nvim", "hrsh7th/nvim-cmp" },
		opts = {
			config_path = vim.env.ICLOUD .. "/Dotfolder/private dotfiles/codium-api-key.json",
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
				-- highlight when at a choice node
				-- https://github.com/L3MON4D3/LuaSnip/blob/master/DOC.md#ext_opts
				ext_opts = {
					[require("luasnip.util.types").choiceNode] = {
						active = {
							hl_group = "DiagnosticHint" ,
							virt_text = { { "󰝮", "DiagnosticHint" } },
						},
					},
				},
			}

			-- VS-code-style snippets
			require("luasnip.loaders.from_vscode").lazy_load { paths = "./snippets" }
		end,
	},
}
