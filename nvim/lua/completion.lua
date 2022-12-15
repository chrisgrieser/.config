require("utils")
local cmp = require("cmp")
local luasnip = require("luasnip")

---Create a copy of a lua table
---@param originalTable table
---@return table
local function copyTable(originalTable)
	local newTable = {}
	for _, value in pairs(originalTable) do
		table.insert(newTable, value)
	end
	return newTable
end

--------------------------------------------------------------------------------


local defaultSources = {
	{name = "luasnip"},
	{name = "nvim_lsp"},
	{name = "cmp_tabnine", keyword_length = 3},
	{name = "treesitter"},
	{name = "emoji", keyword_length = 2},
	{name = "buffer", keyword_length = 2},
}

local defaultAndNerdfont = copyTable(defaultSources)
table.insert(defaultAndNerdfont, {name = "nerdfont", keyword_length = 2})

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
	TypeParameter = ""
}

local source_icons = {
	buffer = "﬘",
	treesitter = "",
	zsh = "",
	nvim_lsp = "璉",
	cmp_tabnine = "ﮧ",
	luasnip = "ﲖ",
	emoji = "",
	nerdfont = "",
	cmdline = "",
	cmdline_history = "",
	path = "",
	omni = "",
}

--------------------------------------------------------------------------------

cmp.setup {
	snippet = {
		-- REQUIRED a snippet engine must be specified and installed
		expand = function(args) require("luasnip").lsp_expand(args.body) end,
	},
	window = {
		completion = {
			col_offset = -3,
			side_padding = 0,
			border = borderStyle,
		},
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
				fallback() -- normal mapping, e.g. tabout plugin
			end
		end, {"i", "s", "n"}),
		["<S-Tab>"] = cmp.mapping(function(fallback)
			if cmp.visible() then
				cmp.select_prev_item()
			elseif luasnip.jumpable(-1) then
				luasnip.jump(-1)
			else
				fallback()
			end
		end, {"i", "s", "n"}),
	},
	formatting = {
		fields = {"kind", "abbr", "menu"}, -- order of the fields
		format = function(entry, vim_item)
			vim_item.kind = " " .. kind_icons[vim_item.kind]
			vim_item.menu = source_icons[entry.source.name]
			return vim_item
		end
	},
	-- DEFAULT SOURCES
	sources = cmp.config.sources(defaultSources),
}
--------------------------------------------------------------------------------

-- Filetype specific Completion

cmp.setup.filetype("lua", {
	-- disable leading "-"
	enabled = function()
		local lineContent = fn.getline(".") ---@diagnostic disable-line: param-type-mismatch
		return not (lineContent:match(" %-%-?$") or lineContent:match("^%-%-?$")) ---@diagnostic disable-line: undefined-field
	end,
	sources = cmp.config.sources(defaultAndNerdfont),
})

-- also use nerdfont for starship config
cmp.setup.filetype("toml", {
	sources = cmp.config.sources(defaultAndNerdfont),
})

-- don't use buffer and treesitter in css completions since laggy
cmp.setup.filetype("css", {
	sources = cmp.config.sources {
		{name = "luasnip"},
		{name = "nvim_lsp"},
		{name = "cmp_tabnine", keyword_length = 3},
		{name = "emoji", keyword_length = 2},
	},
})

-- treesitter has better completions here so using it
cmp.setup.filetype("yaml", {
	sources = cmp.config.sources {
		{name = "luasnip"},
		{name = "treesitter"},
		{name = "nvim_lsp"},
		{name = "cmp_tabnine", keyword_length = 2},
		{name = "emoji", keyword_length = 2},
	},
})

-- also use paths for markdown images, don't use tabnine
cmp.setup.filetype("markdown", {
	sources = cmp.config.sources {
		{name = "path"},
		{name = "luasnip"},
		{name = "nvim_lsp"},
		{name = "emoji", keyword_length = 2},
		{name = "buffer", keyword_length = 3},
	},
})

-- also use zsh for shell completion
cmp.setup.filetype("sh", {
	sources = cmp.config.sources {
		{name = "luasnip"},
		{name = "zsh"},
		{name = "nvim_lsp"},
		{name = "cmp_tabnine", keyword_length = 3},
		{name = "treesitter"},
		{name = "emoji", keyword_length = 2},
		{name = "nerdfont", keyword_length = 2},
		{name = "buffer", keyword_length = 3},
	},
})

-- bibtex
cmp.setup.filetype("bib", {
	sources = cmp.config.sources {
		{name = "luasnip"},
		{name = "treesitter"},
		{name = "buffer", keyword_length = 2},
	},
})

-- plaintext (e.g., pass editing)
cmp.setup.filetype("text", {
	sources = cmp.config.sources {
		{name = "luasnip"},
		{name = "buffer", keyword_length = 2},
		{name = "emoji", keyword_length = 2},
	},
})

--------------------------------------------------------------------------------
-- Command Line Completion
cmp.setup.cmdline({"/", "?"}, {
	mapping = cmp.mapping.preset.cmdline(),
	sources = {
		{name = "treesitter", keyword_length = 2},
	}, {-- second array only relevant when no source from the first matches
		{name = "buffer", keyword_length = 2},
	}
})

cmp.setup.cmdline(":", {
	mapping = cmp.mapping.preset.cmdline(),
	sources = cmp.config.sources({
		{name = "path"},
		{name = "cmdline"},
	}, {-- second array only relevant when no source from the first matches
		{name = "cmdline_history", keyword_length = 3},
	})
})

--------------------------------------------------------------------------------

-- Enable Completion in DressingInput
cmp.setup.filetype("DressingInput", {
	sources = cmp.config.sources {{name = "omni"}},
})

--------------------------------------------------------------------------------
-- AUTOPAIRS
require("nvim-autopairs").setup()

-- add brackets to cmp
local cmp_autopairs = require("nvim-autopairs.completion.cmp")
cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())
