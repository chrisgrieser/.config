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
	Method = "",
	Function = "",
	Constructor = "",
	Field = "",
	Variable = "",
	Class = "ﴯ",
	Interface = "",
	Module = "",
	Property = "ﰠ",
	Unit = "",
	Value = "",
	Enum = "",
	Keyword = "",
	Snippet = "",
	Color = "",
	File = "",
	Reference = "",
	Folder = "",
	EnumMember = "",
	Constant = "",
	Struct = "",
	Event = "",
	Operator = "",
	TypeParameter = "",
}

local source_icons = {
	buffer = "﬘",
	treesitter = "",
	zsh = "",
	nvim_lsp = "璉",
	codeium = "",
	luasnip = "ﲖ",
	emoji = "",
	nerdfont = "",
	cmdline = "",
	cmdline_history = "",
	path = "",
	omni = "", -- since only used for folders right now
	git = "",
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
				compare.offset,
				-- disable exact matches getting higher priority https://github.com/hrsh7th/nvim-cmp/blob/main/lua/cmp/config/default.lua#L57
				-- compare.exact,
				compare.score,
				compare.recently_used,
				compare.locality,
				compare.kind,
				compare.length,
				compare.order,
			},
		},
		mapping = cmp.mapping.preset.insert {
			["<CR>"] = cmp.mapping.confirm { select = true }, -- true = autoselect first entry
			["<S-Up>"] = cmp.mapping.scroll_docs(-4),
			["<S-Down>"] = cmp.mapping.scroll_docs(4),
			["<C-e>"] = cmp.mapping(function(fallback)
				if cmp.visible() then
					cmp.abort()
				else
					fallback()
				end
			end, { "i", "s" }),

			-- expand or jump in luasnip snippet https://github.com/hrsh7th/nvim-cmp/wiki/Example-mappings#luasnip
			["<Tab>"] = cmp.mapping(function(fallback)
				local lineIsEmpty = vim.fn.getline("."):find("^%s*$") ---@diagnostic disable-line: param-type-mismatch, undefined-field
				if cmp.visible() then
					cmp.select_next_item()
				elseif require("neogen").jumpable() then
					require("neogen").jump_next()
				elseif require("luasnip").jumpable(1) and not lineIsEmpty then
					-- requiring non-empty line to prevent prevent jumps when
					-- intending to indent inside a block
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
				elseif require("luasnip").jumpable(-1) then
					require("luasnip").jump(-1)
				else
					fallback()
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
				if #vim_item.abbr > max_length then vim_item.abbr = vim_item.abbr:sub(1, max_length) .. ellipsis_char end

				-- icons
				local kindIcon = kind_icons[vim_item.kind] or ""
				vim_item.kind = " " .. kindIcon .. " "
				vim_item.menu = source_icons[entry.source.name]
				return vim_item
			end,
		},
		sources = cmp.config.sources(defaultSources),
	}
	--------------------------------------------------------------------------------
	-- FILETYPE SPECIFIC COMPLETION

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
			s.lsp,
			s.snippets,
			s.treesitter, -- treesitter works good on yaml
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
			s.path,
			s.codeium,
			s.buffer,
		},
	})

	-- plaintext (e.g., pass editing)
	cmp.setup.filetype("text", {
		sources = cmp.config.sources {
			s.snippets,
			s.buffer,
			s.emojis,
			s.codeium,
		},
	})

	--------------------------------------------------------------------------------
	-- Command Line Completion

	cmp.setup.cmdline(":", {
		mapping = cmp.mapping.preset.cmdline(),
		sources = cmp.config.sources({
			s.path,
			s.cmdline,
		}, { -- second array only relevant when no source from the first matches
			s.cmdline_history,
		}),
	})

	-- cmp.setup.cmdline({ "/", "?" }, {
	-- 	mapping = cmp.mapping.preset.cmdline(),
	-- 	sources = {}, -- empty cause all suggestions do not help much?
	-- })
end
--------------------------------------------------------------------------------

return {
	{
		"hrsh7th/nvim-cmp",
		event = { "InsertEnter", "CmdlineEnter" }, -- CmdlineEnter for completions there
		dependencies = {
			"hrsh7th/cmp-buffer", -- completion sources
			"hrsh7th/cmp-path",
			"hrsh7th/cmp-cmdline",
			"dmitmel/cmp-cmdline-history",
			"hrsh7th/cmp-emoji",
			"chrisgrieser/cmp-nerdfont",
			"tamago324/cmp-zsh",
			"jcdickinson/codeium.nvim", -- ai support
			"ray-x/cmp-treesitter",
			{ "petertriho/cmp-git", dependencies = "nvim-lua/plenary.nvim" },
			"hrsh7th/cmp-nvim-lsp", -- lsp
			"L3MON4D3/LuaSnip", -- snippet
			"saadparwaiz1/cmp_luasnip", -- adapter for snippet engine
		},
		config = cmpconfig,
	},
	{
		"jcdickinson/codeium.nvim",
		lazy = true, -- is being loaded by cmp
		dependencies = { "nvim-lua/plenary.nvim", "hrsh7th/nvim-cmp" },
		config = function()
			require("codeium").setup {
				config_path = vim.env.ICLOUD .. "Dotfolder/private dotfiles/codium-api-key.json",
				bin_path = vim.fn.stdpath("data") .. "/codeium",
			}
		end,
	},
	{
		"petertriho/cmp-git",
		lazy = true, -- is being loaded by cmp
		dependencies = "nvim-lua/plenary.nvim",
		config = function()
			local cmp = require("cmp")
			cmp.setup.filetype("gitcommit", {
				sources = cmp.config.sources {
					{ name = "git" },
				},
			})

			require("cmp_git").setup {
				git = { commits = { limit = 10 } }, -- 0 = disable completing commits
				github = {
					issues = {
						limit = 100,
						state = "open", -- open, closed, all
					},
					mentions = {
						limit = 100,
					},
					pull_requests = {
						limit = 10,
						state = "open",
					},
				},
			}
		end,
	},
	{
		"windwp/nvim-autopairs",
		dependencies = "hrsh7th/nvim-cmp",
		event = "InsertEnter",
		config = function()
			local npairs = require("nvim-autopairs")
			local rule = require("nvim-autopairs.rule")
			local isNodeType = require("nvim-autopairs.ts-conds").is_ts_node

			npairs.setup { check_ts = true } -- use treesitter

			npairs.add_rules {
				-- auto-pair <> if inside string (e.g. for keymaps)
				rule("<", ">", "lua"):with_pair(isNodeType { "string" }),
			}

			-- add brackets to cmp completions, e.g. "function" -> "function()"
			local cmp_autopairs = require("nvim-autopairs.completion.cmp")
			require("cmp").event:on("confirm_done", cmp_autopairs.on_confirm_done())
		end,
	},

	-----------------------------------------------------------------------------

	{
		"L3MON4D3/LuaSnip",
		event = "InsertEnter",
		config = function()
			-- https://github.com/L3MON4D3/LuaSnip/blob/master/DOC.md#api-reference
			local ls = require("luasnip")

			ls.setup {
				region_check_events = "InsertEnter", -- prevent <Tab> jumping back to a snippet after it has been left early
				update_events = "TextChanged,TextChangedI", -- live updating of snippets
			}

			-- VS-code-style snippets
			-- INFO has to be loaded after the regular luasnip-snippets
			require("luasnip.loaders.from_vscode").lazy_load { paths = "./snippets" }
		end,
	},
}
