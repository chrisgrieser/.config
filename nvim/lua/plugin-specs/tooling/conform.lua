-- DOCS https://github.com/stevearc/conform.nvim?tab=readme-ov-file#formatters
--------------------------------------------------------------------------------

return {
	"stevearc/conform.nvim",
	cmd = "ConformInfo",
	keys = {
		{
			"<D-s>",
			function() require("conform").format() end,
			mode = { "n", "x" },
			desc = "󱉯 Format buffer",
		},
	},
	---@module "conform.types"
	---@type conform.setupOpts
	opts = {
		default_format_opts = {
			lsp_format = "first",
		},
		formatters_by_ft = {
			lua = { "stylua" },
			markdown = { "markdownlint", "markdown-toc", "injected" },
			python = { "ruff_fix" },
			typescript = { "ts_remove_unused_imports", "ts_update_imports" },
			zsh = { "shell_home", "shellcheck" },

			-- fallback, used when no formatters are defined and no LSP is available
			_ = { "trim_whitespace", "trim_newlines", "squeeze_blanks" },
		},
		formatters = {
			injected = { ignore_errors = true },
			shell_home = {
				format = function(_, _, _, callback)
					vim.cmd([[% s_/Users/\w\+/_$HOME/_e]]) -- replace `/Users/…` with `$HOME/`
					callback()
				end,
			},
			shellcheck = { -- add `--shell=bash` to force to work with `zsh`
				args = "'$FILENAME' --format=diff --shell=bash | patch -p1 '$FILENAME'",
			},
			ts_update_imports = {
				format = function(_, _, _, callback)
					vim.lsp.buf.code_action {
						---@diagnostic disable-next-line: missing-fields, assign-type-mismatch
						context = { only = { "source.addMissingImports.ts" } },
						apply = true,
					}
					vim.lsp.buf.code_action {
						---@diagnostic disable-next-line: missing-fields, assign-type-mismatch
						context = { only = { "source.removeUnusedImports.ts" } },
						apply = true,
					}
					callback()
				end,
			},
		},
	},
}
