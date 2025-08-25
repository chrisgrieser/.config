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
			python = { "ruff_fix", "ruff_organize_imports" },
			typescript = { "ts_update_imports", "biome-organize-imports" },
			zsh = { "shell_home", "shellcheck" },
			json = { lsp_format = "prefer", "jq" }, -- prefer `biome`, then `jq`

			-- fallback, used when no formatters are defined and no LSP is available
			_ = { "trim_whitespace", "trim_newlines", "squeeze_blanks" },
		},
		formatters = {
			injected = {
				ignore_errors = true,
				lang_to_formatters = {
					json = { "jq" },
				},
			},
			shell_home = {
				format = function(_self, _ctx, _lines, callback)
					vim.cmd([[% s_/Users/\w\+/_$HOME/_e]]) -- replace `/Users/…` with `$HOME/`
					callback()
				end,
			},
			shellcheck = { -- add `--shell=bash` to force to work with `zsh`
				args = "'$FILENAME' --format=diff --shell=bash | patch -p1 '$FILENAME'",
			},
			ts_update_imports = {
				format = function(_self, _ctx, _lines, callback)
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
