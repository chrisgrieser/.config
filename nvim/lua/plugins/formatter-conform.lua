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
	"zsh",
	"python",
	"css",
}
---@return string[]
---@nodiscard
local function listConformFormatters()
	local notClis =
		{ "trim_whitespace", "trim_newlines", "squeeze_blanks", "injected", "just", "format-queries" }
	local formatters = vim.iter(vim.tbl_values(ftToFormatter))
		:flatten()
		:filter(function(f) return not vim.tbl_contains(notClis, f) end)
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
	if not bufnr then bufnr = 0 end
	local fileExists = vim.uv.fs_stat(vim.api.nvim_buf_get_name(bufnr)) ~= nil
	local valid = vim.api.nvim_buf_is_valid(bufnr)
	local specialBuffer = vim.bo[bufnr].buftype ~= ""
	if specialBuffer or not fileExists or not valid then return end

	local ft = vim.bo[bufnr].filetype
	local useLsp = vim.tbl_contains(lspFormatFt, ft) and "first" or "never"

	require("conform").format({ lsp_format = useLsp }, function(_, did_edit)
		if ft == "python" then
			vim.lsp.buf.code_action {
				context = { only = { "source.fixAll.ruff" } }, ---@diagnostic disable-line: assign-type-mismatch,missing-fields
				apply = true,
			}
		end
		if did_edit then vim.cmd.update() end
	end)
end

--- organize imports on before formatting
local function typescriptFormatting()
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
				require("conform").format({ lsp_format = "first" }, function(_, did_edit)
					if did_edit then vim.cmd.update() end
				end)
			end
		end, i * 60)
	end
end

--------------------------------------------------------------------------------

return {
	-- Formatter integration
	"stevearc/conform.nvim",
	cmd = "ConformInfo",
	mason_dependencies = listConformFormatters(),
	keys = {
		{ "<D-s>", formattingFunc, desc = "󰒕 Format & Save", mode = { "n", "x" } },
		{
			"<D-s>",
			typescriptFormatting,
			ft = "typescript",
			desc = "󰒕 Format & Save",
			mode = { "n", "x" },
		},
	},
	config = function()
		require("conform.formatters.injected").options.ignore_errors = true
		require("conform").setup(conformOpts)
		vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"

		vim.api.nvim_create_autocmd("FocusLost", {
			callback = function(ctx)
				local func = vim.bo[ctx.buf].ft == "typescript" and typescriptFormatting
					or formattingFunc
				func(ctx.buf)
			end,
		})
	end,
}
