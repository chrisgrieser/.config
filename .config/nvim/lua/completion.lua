require("utils")
local cmp = require("cmp")
local luasnip = require("luasnip")
--------------------------------------------------------------------------------

defaultSources = {
	{name = "luasnip"},
	{name = "nvim_lsp"},
	{name = "emoji", keyword_length = 2},
	{name = "buffer", keyword_length = 2},
}

local defaultWithoutBuffer = {
	{name = "luasnip"},
	{name = "nvim_lsp"},
	{name = "emoji", keyword_length = 2},
}

local defaultWithoutEmoji = {
	{name = "luasnip"},
	{name = "nvim_lsp"},
	{name = "buffer", keyword_length = 2},
}

local defaultAndNerdfont = {
	{name = "luasnip"},
	{name = "nvim_lsp"},
	{name = "nerdfont", keyword_length = 2},
	{name = "emoji", keyword_length = 2},
	{name = "buffer", keyword_length = 2},
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

cmp.setup {
	snippet = {-- REQUIRED a snippet engine must be specified and installed
		expand = function(args) require("luasnip").lsp_expand(args.body) end,
	},

	window = {
		completion = cmp.config.window.bordered(),
		documentation = cmp.config.window.bordered(),
	},

	mapping = cmp.mapping.preset.insert {
		["<CR>"] = cmp.mapping.confirm {select = true},
		["<S-Up>"] = cmp.mapping.scroll_docs(-4),
		["<S-Down>"] = cmp.mapping.scroll_docs(4),

		-- expand or jump in luasnip snippet https://github.com/hrsh7th/nvim-cmp/wiki/Example-mappings#luasnip
		["<Tab>"] = cmp.mapping(function(fallback)
			if cmp.visible() then
				cmp.select_next_item()
			elseif luasnip.expand_or_jumpable() then
				luasnip.expand_or_jump()
			else
				fallback()
			end
		end, {"i", "s"}),
		["<S-Tab>"] = cmp.mapping(function(fallback)
			if cmp.visible() then
				cmp.select_prev_item()
			elseif luasnip.jumpable(-1) then
				luasnip.jump(-1)
			else
				fallback()
			end
		end, {"i", "s"}),
	},

	sources = cmp.config.sources(defaultSources),

	formatting = {
		format = function(entry, vim_item)
			vim_item.kind = kind_icons[vim_item.kind]
			vim_item.menu = ({
				buffer = "[B]",
				git = "[GIT]",
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
}

--------------------------------------------------------------------------------
-- Filetype specific Completion

cmp.setup.filetype("lua", {
	enabled = function()
		-- disable leading "-"
		local lineContent = fn.getline(".") ---@diagnostic disable-line: param-type-mismatch
		return not (lineContent:match(" %-%-?$") or lineContent:match("^%-%-?$")) ---@diagnostic disable-line: undefined-field
	end,
	sources = cmp.config.sources(defaultAndNerdfont),
})

-- don't use buffer in css completions
cmp.setup.filetype("css", {
	sources = cmp.config.sources(defaultWithoutBuffer),
})

-- no emojis in vim, to avoid ex command `:` triggering emojis
cmp.setup.filetype("vim", {
	sources = cmp.config.sources(defaultWithoutEmoji),
})

-- also use nerdfont for starship config
cmp.setup.filetype("toml", {
	sources = cmp.config.sources(defaultAndNerdfont),
})

--------------------------------------------------------------------------------
-- Command Line Completion
cmp.setup.cmdline({"/", "?"}, {
	mapping = cmp.mapping.preset.cmdline(),
	sources = {
		{name = "buffer", keyword_length = 4}
	}
})

cmp.setup.cmdline(":", {
	mapping = cmp.mapping.preset.cmdline(),
	sources = cmp.config.sources({
		{name = "git"}, -- commits with ":", issues/PRs with "#"
		{name = "path"},
		{name = "cmdline"},
	}, {-- second array only relevant when no source from the first matches
		{name = "cmdline_history"},
	})
})

--------------------------------------------------------------------------------

require("cmp_git").setup {
	filetypes = commonFiletypes,
	git = { commits = { limit = 0 } }, -- = disable completing commits
	github = {
		issues = {
			limit = 100,
			state = "open", -- open, closed, all
		},
		pull_requests = {
			limit = 10,
			state = "open",
		},
	}
}
--------------------------------------------------------------------------------

-- autopairs
require("nvim-autopairs").setup {}
local cmp_autopairs = require("nvim-autopairs.completion.cmp") -- add brackets to cmp
cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())
