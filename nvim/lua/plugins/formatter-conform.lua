-- CONFIG
-- formatting from conform.nvim
local ftToFormatter = {
	applescript = { "trim_whitespace", "trim_newlines", "squeeze_blanks" },
	lua = { "stylua" },
	markdown = { "markdown-toc", "markdownlint", "injected" },
	bib = { "bibtex-tidy" },
	just = { "just", "squeeze_blanks" },
	query = { "format-queries" },
}
-- formatting from the LSP
local lspFormatFt = {
	"javascript",
	"typescript",
	"json",
	"jsonc",
	"toml",
	"yaml",
	"sh",
	"zsh",
	"python",
	"css",
}

--------------------------------------------------------------------------------

---@return string[]
---@nodiscard
local function listConformFormatters()
	local notClis =
		{ "trim_whitespace", "trim_newlines", "squeeze_blanks", "injected", "just", "format-queries" }
	local formatters = vim.iter(vim.tbl_values(ftToFormatter))
		:flatten()
		:filter(function(ft) return not vim.tbl_contains(notClis, ft) end)
		:totable()
	table.sort(formatters)
	vim.fn.uniq(formatters)
	return formatters
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
	local fileExists = vim.uv.fs_stat(vim.api.nvim_buf_get_name(bufnr)) ~= nil
	local valid = vim.api.nvim_buf_is_valid(bufnr)
	local specialBuffer = vim.bo[bufnr].buftype ~= ""
	if specialBuffer or not fileExists or not valid then return end

	-- parameters
	local ft = vim.bo[bufnr].filetype
	local useLsp = vim.tbl_contains(lspFormatFt, ft) and "always" or false

	-- typescript: organize imports before
	if ft == "typescript" then
		local actions = {
			"source.fixAll.ts",
			"source.addMissingImports.ts",
			"source.removeUnusedImports.ts",
			"source.organizeImports.biome",
		}
		for i = 1, #actions + 1 do
			vim.defer_fn(function()
				if i <= #actions then
					vim.lsp.buf.code_action {
						context = { only = { actions[i] } }, ---@diagnostic disable-line: assign-type-mismatch,missing-fields
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
				context = { only = { "source.fixAll.ruff" } }, ---@diagnostic disable-line: assign-type-mismatch,missing-fields
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
	mason_dependencies = listConformFormatters(),
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
