require("utils")
local cmp = require('cmp')
local luasnip = require("luasnip")
--------------------------------------------------------------------------------

local defaultSources = {
	{ name = 'luasnip' },
	{ name = 'nvim_lsp' },
	{ name = 'emoji', keyword_length = 2 },
	{ name = 'buffer', keyword_length = 2 },
}

local nerdfontSource = { name = "nerdfont", keyword_length = 2 }
local bufferLineSource = { name = "buffer-lines", keyword_length = 2 }

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
	Snippet = "",
	Color = "",
	File = "",
	Reference = "",
	Folder = "",
	EnumMember = "",
	Constant = "",
	Struct = "",
	Event = "",
	Operator = "",
	TypeParameter = ""
}

cmp.setup({
	snippet = { -- REQUIRED a snippet engine must be specified and installed
		expand = function(args) require('luasnip').lsp_expand(args.body) end,
	},
	experimental = { ghost_text = false },

	window = {
		completion = cmp.config.window.bordered(),
		documentation = cmp.config.window.bordered(),
	},

	mapping = cmp.mapping.preset.insert({
		['<CR>'] = cmp.mapping.confirm({ select = true }),
		['<S-Up>'] = cmp.mapping.scroll_docs(-4),
		['<S-Down>'] = cmp.mapping.scroll_docs(4),

		-- expand or jump in luasnip snippet https://github.com/hrsh7th/nvim-cmp/wiki/Example-mappings#luasnip
		["<Tab>"] = cmp.mapping(function(fallback)
			if cmp.visible() then
				cmp.select_next_item()
			elseif luasnip.expand_or_jumpable() then
				luasnip.expand_or_jump()
			else
				fallback()
			end
		end, { "i", "s" }),
		["<S-Tab>"] = cmp.mapping(function(fallback)
			if cmp.visible() then
				cmp.select_prev_item()
			elseif luasnip.jumpable(-1) then
				luasnip.jump(-1)
			else
				fallback()
			end
		end, { "i", "s" }),
	}),

	sources = cmp.config.sources(defaultSources),

	formatting = {
		format = function(entry, vim_item)
			-- vim_item.kind = string.format('%s %s', kind_icons[vim_item.kind], vim_item.kind) -- This concatonates the icons with the name of the item kind
			vim_item.kind = kind_icons[vim_item.kind]
			vim_item.menu = ({
				buffer = "[B]",
				["buffer-lines"] = "[BL]",
				nvim_lsp = "[LSP]",
				luasnip = "[S]",
				emoji = "[E]",
				nerdfont = "[NF]",
				cmdline = "[CMD]",
				cmdline_history = "[C-H]",
				path = "[F]",
			})[entry.source.name]
			return vim_item
		end
	},
	-- disable completion in comments https://github.com/hrsh7th/nvim-cmp/wiki/Advanced-techniques#disabling-completion-in-certain-contexts-such-as-comments
})

--------------------------------------------------------------------------------
-- Filetype specific Completion

cmp.setup.filetype ("lua", {
	enabled = function()
		-- disable leading "-"
		local lineContent = fn.getline(".") ---@diagnostic disable-line: param-type-mismatch
		return not(lineContent:match(" %-%-?$") or lineContent:match("^%-%-?$")) ---@diagnostic disable-line: undefined-field
	end,
	sources = cmp.config.sources(
		table.insert(defaultSources, nerdfontSource)
	),
})

-- use buffer lines in yaml and json
cmp.setup.filetype ("json", {
	sources = cmp.config.sources(
		table.insert(defaultSources, bufferLineSource)
	),
})
cmp.setup.filetype ("yaml", {
	sources = cmp.config.sources(
		table.insert(defaultSources, bufferLineSource)
	),
})

-- don't use buffer in css completions
local bufferSourceIndex = table.find(defaultSources,{name='buffer', keyword_length=2 })
cmp.setup.filetype ("css", {
	sources = cmp.config.sources(
		table.remove(defaultSources)
	),
})

-- also use nerdfont for starship config
cmp.setup.filetype ("toml", {
	sources = cmp.config.sources(
		table.insert(defaultSources, nerdfontSource)
	),
})

--------------------------------------------------------------------------------
-- Command Line Completion

cmp.setup.cmdline({ '/', '?' }, {
	mapping = cmp.mapping.preset.cmdline(),
	sources = {
		{ name = 'buffer', keyword_length = 4 }
	}
})

cmp.setup.cmdline(':', {
	mapping = cmp.mapping.preset.cmdline(),
	sources = cmp.config.sources({
		{ name = 'path' },
		{ name = 'cmdline' },
	},{ -- additional arrays = second array only relevant when no source from the first matches
		{ name = 'cmdline_history' },
	})
})

--------------------------------------------------------------------------------

-- autopairs
require("nvim-autopairs").setup {}
local cmp_autopairs = require('nvim-autopairs.completion.cmp') -- add brackets to cmp
cmp.event:on( 'confirm_done', cmp_autopairs.on_confirm_done())
