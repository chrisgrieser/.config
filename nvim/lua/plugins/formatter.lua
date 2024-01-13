local u = require("config.utils")
--------------------------------------------------------------------------------

-- use formatting from conform.nvim
local ftToFormatter = {
	applescript = { "trim_whitespace", "trim_newlines", "squeeze_blanks" },
	lua = { "stylua" },
	markdown = { "markdown-toc", "markdownlint", "injected" },
	sh = { "shellcheck", "shfmt" },
	bib = { "trim_whitespace", "bibtex-tidy" },
	css = { "squeeze_blanks" }, -- since the css formatter does not support that
	["*"] = { "typos" },
}
-- use formatting from the LSP
local lspFormatFt = {
	"javascript",
	"typescript",
	"json",
	"toml",
	"yaml",
	"html",
	"python",
	"css",
}

-- use auto-indenting as poor man's formatter
local autoIndentFt = {
	"query",
	"applescript",
}

--------------------------------------------------------------------------------

---@param formattersByFt object[]
---@return string[]
---@nodiscard
local function listConformFormatters(formattersByFt)
	local notClis = { "trim_whitespace", "trim_newlines", "squeeze_blanks", "injected" }
	local formatters = vim.tbl_flatten(vim.tbl_values(formattersByFt))
	formatters = vim.tbl_filter(function(f) return not vim.tbl_contains(notClis, f) end, formatters)
	table.sort(formatters)
	return vim.fn.uniq(formatters)
end

local formatterConfig = {
	formatters_by_ft = ftToFormatter,
	formatters = {
		markdownlint = {
			prepend_args = { "--config=" .. vim.g.linterConfigFolder .. "/markdownlint.yaml" },
		},

		["bibtex-tidy"] = {
			-- stylua: ignore
			prepend_args = {
				"--tab", "--curly", "--strip-enclosing-braces", "--no-align", "--no-wrap",
				"--enclosing-braces=title,journal,booktitle", "--drop-all-caps",
				"---@diagnostic disable-line: unused-local", "--months", "--encode-urls",
				"--duplicates", "--sort-fields", "--remove-empty-fields", "--omit=month,issn,abstract",
			},
			condition = function(_, ctx)
				local biggerThan500Kb = vim.loop.fs_stat(ctx.filename).size > 500 * 1024
				if biggerThan500Kb then u.notify("conform.nvim", "Not formatting (file > 500kb).") end
				return not biggerThan500Kb
			end,
		},
	},
}

local function formattingFunc()
	-- HACK since `fixAll` is not part of ruff-lsp formatting capabilities
	-- PENDING https://github.com/astral-sh/ruff-lsp/issues/335
	local function pythonRuffFixall()
		if vim.bo.ft == "python" then
			vim.lsp.buf.code_action { apply = true, context = { only = { "source.fixAll.ruff" } } }
		end
	end

	-- PENDING https://github.com/stevearc/conform.nvim/issues/255
	if vim.tbl_contains(autoIndentFt, vim.bo.ft) then u.normal("gg=G``") end

	local useLsp = vim.tbl_contains(lspFormatFt, vim.bo.ft) and "always" or false
	require("conform").format({ lsp_fallback = useLsp }, pythonRuffFixall)
end

--------------------------------------------------------------------------------

return {
	-- Formatter integration
	"stevearc/conform.nvim",
	cmd = "ConformInfo",
	extra_dependencies = listConformFormatters(ftToFormatter),
	config = function()
		require("conform.formatters.injected").options.ignore_errors = true
		require("conform").setup(formatterConfig)
	end,
	keys = {
		{ "<D-s>", formattingFunc, desc = "󰒕 Format & Save", mode = { "n", "x" } },
	},
}
