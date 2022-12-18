require("config/utils")
local cmp = require("cmp")

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
-- source definitions

local emojis = { name = "emoji", keyword_length = 2 }
local nerdfont = { name = "nerdfont", keyword_length = 2 }
local buffer = { name = "buffer", keyword_length = 2 }
local path = { name = "path" }
local zsh = { name = "zsh" }
local tabnine = { name = "cmp_tabnine", keyword_length = 3 }
local snippets = { name = "luasnip" }
local lsp = { name = "nvim_lsp" }
local treesitter = { name = "treesitter" }

local defaultSources = {
	snippets,
	lsp,
	tabnine,
	treesitter,
	emojis,
	buffer,
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
	cmp_tabnine = "ﮧ",
	luasnip = "ﲖ",
	emoji = "",
	nerdfont = "",
	cmdline = "",
	cmdline_history = "",
	path = "",
	omni = "", -- since only used for folders right now
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
		["<CR>"] = cmp.mapping.confirm { select = true },
		["<S-Up>"] = cmp.mapping.scroll_docs(-4),
		["<S-Down>"] = cmp.mapping.scroll_docs(4),

		-- expand or jump in luasnip snippet https://github.com/hrsh7th/nvim-cmp/wiki/Example-mappings#luasnip
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
	},
	formatting = {
		fields = { "kind", "abbr", "menu" }, -- order of the fields
		format = function(entry, vim_item)
			vim_item.kind = " " .. kind_icons[vim_item.kind] .. " "
			vim_item.menu = source_icons[entry.source.name]
			return vim_item
		end,
	},
	-- DEFAULT SOURCES
	sources = cmp.config.sources(defaultSources),
}
--------------------------------------------------------------------------------

-- lua and toml
local defaultAndNerdfont = copyTable(defaultSources)
table.insert(defaultAndNerdfont, 5, nerdfont)

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

-- css
cmp.setup.filetype("css", {
	sources = cmp.config.sources {
		snippets,
		lsp,
		treesitter,
	},
})

-- markdown
local markdownSources = copyTable(defaultSources)
table.remove(markdownSources, 3) -- no tabnine, since mostly suggesting useless words
table.insert(markdownSources, 1, path) -- for markdown images
cmp.setup.filetype("markdown", {
	sources = cmp.config.sources(markdownSources),
})
local yamlSources = copyTable(defaultSources)
table.remove(yamlSources) -- remove buffer
cmp.setup.filetype("yaml", {
	sources = cmp.config.sources(yamlSources),
})

-- ZSH
local shellSources = copyTable(defaultSources)
table.insert(shellSources, 2, zsh)
table.insert(shellSources, 5, nerdfont)
cmp.setup.filetype("sh", {
	sources = cmp.config.sources(shellSources),
})

-- bibtex
cmp.setup.filetype("bib", {
	sources = cmp.config.sources {
		snippets,
		treesitter,
		buffer,
	},
})

-- plaintext (e.g., pass editing)
cmp.setup.filetype("text", {
	sources = cmp.config.sources {
		snippets,
		buffer,
		emojis,
	},
})

--------------------------------------------------------------------------------
-- Command Line Completion
cmp.setup.cmdline({ "/", "?" }, {
	mapping = cmp.mapping.preset.cmdline(),
	sources = {
		{ name = "treesitter", keyword_length = 2 },
	},
	{ -- second array only relevant when no source from the first matches
		{ name = "buffer", keyword_length = 2 },
	},
})

cmp.setup.cmdline(":", {
	mapping = cmp.mapping.preset.cmdline(),
	sources = cmp.config.sources({
		{ name = "path" },
		{ name = "cmdline" },
	}, { -- second array only relevant when no source from the first matches
		{ name = "cmdline_history", keyword_length = 3 },
	}),
})

--------------------------------------------------------------------------------

-- Enable Completion in DressingInput
cmp.setup.filetype("DressingInput", {
	sources = cmp.config.sources { { name = "omni" } },
})

--------------------------------------------------------------------------------
-- AUTOPAIRS
require("nvim-autopairs").setup()

-- add brackets to cmp
local cmp_autopairs = require("nvim-autopairs.completion.cmp")
cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())
