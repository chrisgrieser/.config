require("utils")
local cmp = require("cmp")
local luasnip = require("luasnip")

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

local source_icons = {
	buffer = "﬘",
	git = "",
	treesitter = "",
	zsh = "",
	nvim_lsp = "璉",
	cmp_tabnine = "ﮧ",
	luasnip = "ﲖ",
	emoji = "",
	nerdfont = "",
	cmdline = "",
	cmdline_history = "",
	path = "",
}

local function has_words_before()
	local line, col = unpack(vim.api.nvim_win_get_cursor(0))
	return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
end

--------------------------------------------------------------------------------

cmp.setup {
	snippet = {
		-- REQUIRED a snippet engine must be specified and installed
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
			-- elseif has_words_before() then -- disabled when using tabout plugin
			-- 	cmp.complete()
			else
				fallback()
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

	sources = cmp.config.sources {
		{name = "luasnip"},
		{name = "nvim_lsp"},
		{name = "cmp_tabnine", keyword_length = 3},
		{name = "treesitter"},
		{name = "emoji", keyword_length = 2},
		{name = "buffer", keyword_length = 2},
	},

	formatting = {
		format = function(entry, vim_item)
			vim_item.kind = kind_icons[vim_item.kind]
			vim_item.menu = source_icons[entry.source.name]
			return vim_item
		end
	},
}

--------------------------------------------------------------------------------
-- Filetype specific Completion

local defaultAndNerdfont = {
	{name = "luasnip"},
	{name = "nvim_lsp"},
	{name = "cmp_tabnine", keyword_length = 3},
	{name = "treesitter"},
	{name = "nerdfont", keyword_length = 2},
	{name = "emoji", keyword_length = 2},
	{name = "buffer", keyword_length = 2},
}

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
		{name = "zsh"},
		{name = "luasnip"},
		{name = "nvim_lsp"},
		{name = "cmp_tabnine", keyword_length = 3},
		{name = "treesitter"},
		{name = "emoji", keyword_length = 2},
		{name = "nerdfont", keyword_length = 2},
		{name = "buffer", keyword_length = 3},
	},
})

--------------------------------------------------------------------------------
-- Command Line Completion
cmp.setup.cmdline({"/", "?"}, {
	mapping = cmp.mapping.preset.cmdline(),
	sources = {
		{name = "treesitter", keyword_length = 2},
		{name = "buffer", keyword_length = 4},
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
	git = {commits = {limit = 0}}, -- 0 = disable completing commits
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
-- AUTOPAIRS
require("nvim-autopairs").setup {}

-- add brackets to cmp
local cmp_autopairs = require("nvim-autopairs.completion.cmp")
cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())

--------------------------------------------------------------------------------
-- TABNINE
require("cmp_tabnine.config"):setup {-- yes, requires a ":", not "."
	max_lines = 1000,
	max_num_results = 20,
	run_on_every_keystroke = true,
	snippet_placeholder = "…",
	show_prediction_strength = true,
}

-- automatically prefetch completions for the buffer
augroup("prefetchTabNine", {})
autocmd("BufRead", {
	group = "prefetchTabNine",
	callback = function() require("cmp_tabnine"):prefetch(fn.expand("%:p")) end
})
