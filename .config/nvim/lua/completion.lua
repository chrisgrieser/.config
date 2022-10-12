require("utils")


--------------------------------------------------------------------------------
local cmp = require('cmp')

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
		['<Tab>'] = cmp.mapping.select_next_item(),
		['<S-Tab>'] = cmp.mapping.select_prev_item(),
		['<Esc>'] = cmp.mapping.close(), -- close() leaves the current text, abort() restores pre-completion situation
		['<CR>'] = cmp.mapping.confirm({ select = true }),
		['<S-Up>'] = cmp.mapping.scroll_docs(-4),
		['<S-Down>'] = cmp.mapping.scroll_docs(4),
	}),

	sources = cmp.config.sources({
		{ name = 'nvim_lsp_signature_help' },
		{ name = 'nvim_lsp' },
		{ name = 'luasnip' },
		{ name = 'emoji', keyword_length = 2 },
		{ name = 'buffer', keyword_length = 2 },
	}),
	formatting = {
		format = function(entry, vim_item)
			-- vim_item.kind = string.format('%s %s', kind_icons[vim_item.kind], vim_item.kind) -- This concatonates the icons with the name of the item kind
			vim_item.kind = kind_icons[vim_item.kind]
			vim_item.menu = ({
				buffer = "[B]",
				nvim_lsp = "[LSP]",
				nvim_lsp_signature_help = "[SIG]",
				luasnip = "[S]",
				emoji = "[E]",
				nerdfont = "[NF]",
				cmdline = "[CMD]",
				cmdline_history = "[CMD-H]",
				path = "[F]",
			})[entry.source.name]
			return vim_item
		end
	},

	-- disable completion in comments https://github.com/hrsh7th/nvim-cmp/wiki/Advanced-techniques#disabling-completion-in-certain-contexts-such-as-comments
	enabled = function()
		local context = require 'cmp.config.context'
		if vim.api.nvim_get_mode().mode == 'c' then -- keep command mode completion enabled when cursor is in a comment
			return true
		else
			return not context.in_treesitter_capture("comment")
			and not context.in_syntax_group("Comment")
		end
	end
})

--------------------------------------------------------------------------------
-- autopairs
require("nvim-autopairs").setup {}

-- add brackets to cmp
local cmp_autopairs = require('nvim-autopairs.completion.cmp')
cmp.event:on( 'confirm_done', cmp_autopairs.on_confirm_done())

--------------------------------------------------------------------------------
-- Filetype specific Completion

-- disable leading "-" and comments
cmp.setup.filetype ("lua", {
	enabled = function()
		local context = require 'cmp.config.context'
		if api.nvim_get_mode().mode == 'c' then -- keep command mode completion enabled when cursor is in a comment
			return true
		elseif fn.getline("."):match("%s*%-+") then ---@diagnostic disable-line: undefined-field, param-type-mismatch
			return false
		else
			return not context.in_treesitter_capture("comment")
			and not context.in_syntax_group("Comment")
		end
	end,
	
	sources = cmp.config.sources({
		{ name = 'nvim_lsp_signature_help' },
		{ name = 'nvim_lsp' },
		{ name = 'luasnip' },
		{ name = 'emoji', keyword_length = 2 },
		{ name = 'buffer', keyword_length = 2 },
	}),
})

-- don't use buffer in css completions
cmp.setup.filetype ("css", {
	sources = cmp.config.sources({
		{ name = 'nvim_lsp_signature_help' },
		{ name = 'nvim_lsp' },
		{ name = 'luasnip' },
		{ name = 'emoji', keyword_length = 2 },
		{ name = 'nerdfont', keyword_length = 2 },
	})
})

--------------------------------------------------------------------------------
-- Command Line Completion

cmp.setup.cmdline({ '/', '?' }, {
	mapping = cmp.mapping.preset.cmdline(),
	sources = {
		{ name = 'buffer', max_item_count = 12, keyword_length = 4 }
	}
})

-- if a path can be matched, omit the rest. If a cmd can be matched, omit
-- history
cmp.setup.cmdline(':', {
	mapping = cmp.mapping.preset.cmdline(),
	sources = cmp.config.sources({
		{ name = 'path' }
	}, {
		{ name = 'cmdline', max_item_count = 12 },
	}, {
		{ name = 'cmdline_history', max_item_count = 12 },
	})
})


