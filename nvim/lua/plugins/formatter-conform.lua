local u = require("config.utils")
--------------------------------------------------------------------------------

-- use formatting from conform.nvim
local ftToFormatter = {
	applescript = { "trim_whitespace", "trim_newlines", "squeeze_blanks" },
	lua = { "stylua" },
	markdown = { "markdown-toc", "markdownlint", "injected" },
	sh = { "shellcheck", "shfmt" },
	bib = { "trim_whitespace", "bibtex-tidy" },
	-- css = { "squeeze_blanks" }, -- since the css formatter does not support that
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

local function formattingFunc(bufnr)
	-- GUARD
	if not bufnr then bufnr = 0 end
	local bufname = vim.api.nvim_buf_get_name(bufnr)
	local fileExists = vim.loop.fs_stat(bufname) ~= nil
	local valid = vim.api.nvim_buf_is_valid(bufnr)
	local specialBuffer = vim.bo[bufnr].buftype ~= ""
	if specialBuffer or not fileExists or not valid then return end

	-- parameters
	local ft = vim.bo[bufnr].filetype
	local useLsp = vim.tbl_contains(lspFormatFt, ft) and "always" or false

	-- PENDING https://github.com/stevearc/conform.nvim/issues/255
	if vim.tbl_contains(autoIndentFt, ft) then u.normal("gg=G``") end

	-- typescript: organize imports before
	if ft == "typescript" then
		local actions = {
			"source.fixAll.ts",
			"source.addMissingImports.ts",
			"source.removeUnusedImports.ts",
			"source.organizeImports.biome",
		}
		-- deferred, so it does not conflict with `addMissingImports`
		for i = 0, #actions do
			vim.defer_fn(function()
				if i < #actions then
					vim.lsp.buf.code_action {
						context = { only = { actions[i] } },
						apply = true,
					}
				else
					require("conform").format { lsp_fallback = useLsp }
				end
			end, i * 60)
		end
		return
	end

	require("conform").format({ lsp_fallback = useLsp }, function()
		if ft == "python" then
			vim.lsp.buf.code_action {
				context = { only = { "source.fixAll.ruff" } },
				apply = true,
			}
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

		vim.api.nvim_create_autocmd("FocusLost", {
			callback = function(ctx) formattingFunc(ctx.buf) end,
		})
	end,
	keys = {
		{ "<D-s>", formattingFunc, desc = "󰒕 Format & Save", mode = { "n", "x" } },
	},
}
