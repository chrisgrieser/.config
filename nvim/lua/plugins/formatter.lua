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
	"jsonc",
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

local conformOpts = {
	formatters_by_ft = ftToFormatter,
	formatters = {
		markdownlint = {
			prepend_args = { "--config=" .. vim.g.linterConfigs .. "/markdownlint.yaml" },
		},

		["bibtex-tidy"] = {
			-- stylua: ignore
			prepend_args = {
				-- BUG (do not use these options)
				-- *not* using `--no-escape` https://github.com/FlamingTempura/bibtex-tidy/issues/415
				-- `--no-encode-urls`: https://github.com/FlamingTempura/bibtex-tidy/issues/422
				-- `--enclosing-braces` https://github.com/FlamingTempura/bibtex-tidy/issues/423
				"--tab", "--curly", "--no-align", "--no-wrap", "--drop-all-caps",
				"--numeric", "--trailing-commas", "--no-escape",
				"--duplicates", "--sort-fields", "--remove-empty-fields",
				"--omit=month,issn,abstract",
			},
		},
	},
}

local function formattingFunc()
	-- PENDING https://github.com/stevearc/conform.nvim/issues/255
	if vim.tbl_contains(autoIndentFt, vim.bo.ft) then u.normal("gg=G``") end

	local useLsp = vim.tbl_contains(lspFormatFt, vim.bo.ft) and "always" or false
	require("conform").format({ lsp_fallback = useLsp }, function()
		-- add fixAll & organizeImports to formatting callback
		if vim.bo.ft == "python" then
			-- PENDING https://github.com/astral-sh/ruff-lsp/issues/335
			vim.lsp.buf.code_action { context = { only = { "source.fixAll.ruff" } }, apply = true }
		elseif vim.bo.ft == "javascript" or vim.bo.ft == "typescript" then
			vim.cmd.TSToolsFixAll()
			vim.cmd.TSToolsRemoveUnused()
			-- as opposed to biome's `source.organizeImports.biome`, this also
			-- removes unused imports
			vim.cmd.TSToolsOrganizeImports()
		end
	end)
end

--------------------------------------------------------------------------------

return {
	-- Formatter integration
	"stevearc/conform.nvim",
	cmd = "ConformInfo",
	mason_dependencies = listConformFormatters(ftToFormatter),
	config = function()
		require("conform.formatters.injected").options.ignore_errors = true
		require("conform").setup(conformOpts)
	end,
	keys = {
		{ "<D-s>", formattingFunc, desc = "󰒕 Format & Save", mode = { "n", "x" } },
	},
}
