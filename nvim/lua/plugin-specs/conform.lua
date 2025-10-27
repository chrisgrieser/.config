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
	opts = {
		default_format_opts = {
			lsp_format = "first",
		},
		formatters_by_ft = {
			-- FIX stylua-lsp offset bug: https://github.com/JohnnyMorganz/StyLua/issues/1045
			lua = { lsp_format = "never", "stylua" },

			markdown = { "markdownlint", "markdown-toc", "injected" },
			python = { "ruff_fix", "ruff_organize_imports" },
			typescript = { "tsAddMissingImports", "tsRemoveUnusedImports", "biome-organize-imports" },
			zsh = { "shellHome", "shellcheck" },
			json = { lsp_format = "prefer", "jq" }, -- use `biome` (via LSP), with `jq` as fallback

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
			shellcheck = { -- add `--shell=bash` to force to work with `zsh`
				args = "'$FILENAME' --format=diff --shell=bash | patch -p1 '$FILENAME'",
			},
			-----------------------------------------------------------------------
			-- my custom formatters
			shellHome = { -- replace `/Users/…` with `$HOME/`
				format = function(_self, _ctx, lines, callback)
					local outLines = vim.tbl_map(
						function(line) return line:gsub("/Users/%a+", "$HOME") end,
						lines
					)
					callback(nil, outLines)
				end,
			},
			tsAddMissingImports = {
				format = function(_self, ctx, _lines, callback)
					vim.lsp.buf.code_action {
						context = { only = { "source.addMissingImports.ts" } }, ---@diagnostic disable-line: missing-fields, assign-type-mismatch
						apply = true,
					}
					local outLines = vim.api.nvim_buf_get_lines(ctx.buf, 0, -1, true)
					-- vim.cmd.undo()
					callback(nil, outLines)
				end,
			},
			tsRemoveUnusedImports = {
				format = function(_self, ctx, _lines, callback)
					vim.lsp.buf.code_action {
						context = { only = { "source.removeUnusedImports.ts" } }, ---@diagnostic disable-line: missing-fields, assign-type-mismatch
						apply = true,
					}
					local outLines = vim.api.nvim_buf_get_lines(ctx.buf, 0, -1, true)
					vim.cmd.undo()
					callback(nil, outLines)
				end,
			},
		},
	},
}
