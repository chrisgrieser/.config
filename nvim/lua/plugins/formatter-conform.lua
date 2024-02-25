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
				-- BUG when…
				-- * using `--no-encode-urls`: https://github.com/FlamingTempura/bibtex-tidy/issues/422
				-- * using `--enclosing-braces`: https://github.com/FlamingTempura/bibtex-tidy/issues/423
				-- * *not* using `--no-escape`: https://github.com/FlamingTempura/bibtex-tidy/issues/415
				"--tab", "--curly", "--no-align", "--no-wrap", "--drop-all-caps",
				"--numeric", "--trailing-commas", "--no-escape",
				"--duplicates", "--sort-fields", "--remove-empty-fields",
				"--omit=month,issn,abstract",
			},
		},
	},
}

local function formattingFunc()
	-- GUARD
	local fileExists = vim.loop.fs_stat(vim.api.nvim_buf_get_name(0)) ~= nil
	if vim.bo.buftype ~= "" or not fileExists then return end

	-- PENDING https://github.com/stevearc/conform.nvim/issues/255
	if vim.tbl_contains(autoIndentFt, vim.bo.ft) then u.normal("gg=G``") end

	local useLsp = vim.tbl_contains(lspFormatFt, vim.bo.ft) and "always" or false
	require("conform").format({ lsp_fallback = useLsp }, function()
		if vim.bo.ft == "python" then
			vim.lsp.buf.code_action {
				context = { only = { "source.fixAll.ruff" } },
				apply = true,
			}
		elseif vim.bo.ft == "javascript" or vim.bo.ft == "typescript" then
			-- Biome's `source.organizeImports.biome`, does not remove unused imports
			pcall(function()
				vim.cmd.TSToolsOrganizeImports()
				vim.cmd.TSToolsAddMissingImports()
				vim.cmd.TSToolsFixAll()
			end)
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

		vim.api.nvim_create_autocmd({ "BufLeave", "FocusLost" }, {
			callback = formattingFunc,
		})
	end,
	keys = {
		{ "<D-s>", formattingFunc, desc = "󰒕 Format & Save", mode = { "n", "x" } },
	},
}
