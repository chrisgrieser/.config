-- CONFIG
-- formatting from conform.nvim
local ftToFormatter = {
	lua = { "stylua" },
	markdown = { "markdown-toc", "markdownlint", "injected" },
	bib = { "bibtex-tidy" },
	just = { "just", "squeeze_blanks", "indent_expr" },
	gitconfig = { "squeeze_blanks", "indent_expr" },
	query = { "format-queries" },
	applescript = { "trim_whitespace", "trim_newlines", "squeeze_blanks", "indent_expr" },
	zsh = { "shell_home" },
	python = { "ruff_fix_all" },
}

local conformOpts = {
	formatters_by_ft = ftToFormatter,
	formatters = {
		["bibtex-tidy"] = {
			-- stylua: ignore
			prepend_args = {
				-- BUG when using `--no-encode-urls`: https://github.com/FlamingTempura/bibtex-tidy/issues/422
				"--tab", "--curly", "--no-align", "--no-wrap", "--drop-all-caps",
				"--enclosing-braces", "--numeric", "--trailing-commas", "--duplicates",
				"--sort-fields", "--remove-empty-fields", "--omit=month,issn,abstract",
			},
		},
		-- Custom formatter to auto indent buffer. https://github.com/stevearc/conform.nvim/issues/255#issuecomment-2337684156
		indent_expr = {
			format = function(_, _, _, callback)
				vim.cmd.normal { "m`gg=G``", bang = true }
				callback()
			end,
		},
		shell_home = {
			format = function(_, _, _, callback)
				vim.cmd([[% s_/Users/\w\+/_$HOME/_e]]) -- replace `/Users/…` with `$HOME/`
				callback()
			end,
		},
		ruff_fix_all = {
			format = function(_, _, _, callback)
				vim.lsp.buf.code_action {
					context = { only = { "source.fixAll.ruff" } }, ---@diagnostic disable-line: assign-type-mismatch,missing-fields
					apply = true,
				}
				callback()
			end,
		},
	},
}

--------------------------------------------------------------------------------

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
	local notClis = {
		-- builtins
		"trim_whitespace",
		"trim_newlines",
		"squeeze_blanks",
		"injected",
		"format-queries",
		-- `just` cli
		"just",
		-- custom formatters
		"indent_expr",
		"shell_home",
		"ruff_fix_all",
	}
	local formatters = vim.iter(vim.tbl_values(ftToFormatter))
		:flatten()
		:filter(function(f) return not vim.tbl_contains(notClis, f) end)
		:totable()
	table.sort(formatters)
	vim.fn.uniq(formatters)
	return formatters
end

local function formattingFunc()
	local useLsp = vim.tbl_contains(lspFormatFt, vim.bo.ft) and "first" or "never"
	require("conform").format({ lsp_format = useLsp }, function() vim.cmd.update() end)
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
				require("conform").format({ lsp_format = "first" }, function() vim.cmd.update() end)
			end
		end, i * 60)
	end
end

--------------------------------------------------------------------------------

return {
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
		require("conform").setup(conformOpts)

		require("conform.formatters.injected").options.ignore_errors = true
		vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"

		vim.api.nvim_create_autocmd("FocusLost", {
			callback = function()
				local func = vim.bo.ft == "typescript" and typescriptFormatting or formattingFunc
				func()
			end,
		})
	end,
}
