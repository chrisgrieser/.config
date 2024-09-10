local opts = {
	default_format_opts = {
		lsp_format = "first",
	},
	formatters_by_ft = {
		lua = { "stylua" },
		markdown = { "markdown-toc", "markdownlint", "injected" },
		bib = { "bibtex-tidy" },
		query = { "format-queries" },
		zsh = { "shell_home" },
		python = { "ruff_fix_all" },
		just = { "just", "trim_whitespace", "trim_newlines", "squeeze_blanks", "indent_expr" },

		-- fallback, used when not formatters are defined and no LSP is available
		_ = { "trim_whitespace", "trim_newlines", "squeeze_blanks", "indent_expr" },
	},
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
	local formatters = vim.iter(vim.tbl_values(opts.formatters_by_ft))
		:flatten()
		:filter(function(f) return not vim.tbl_contains(notClis, f) end)
		:totable()
	table.sort(formatters)
	vim.fn.uniq(formatters)
	return formatters
end


--------------------------------------------------------------------------------

return {
	"stevearc/conform.nvim",
	cmd = "ConformInfo",
	mason_dependencies = listConformFormatters(),
	config = function()
		require("conform").setup(opts)
		require("conform.formatters.injected").options.ignore_errors = true
	end,
	keys = {
		{ "<D-s>", function() require("conform").format() end, desc = "󰒕 Format & Save" },
	},
}
