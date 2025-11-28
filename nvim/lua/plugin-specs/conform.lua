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
			markdown = { "hardWrapAtTextwidth", "markdownlint", "markdown-toc", "injected" },
			python = { "ruff_fix", "ruff_organize_imports" },
			typescript = { "tsAddMissingImports", "tsRemoveUnusedImports", "biome-organize-imports" },
			zsh = { "shellHome", "shellcheck" },
			json = { lsp_format = "prefer", "jq" }, -- use `biome` (via LSP), with `jq` as fallback

			-- _ = fallback, used when no formatters defined and no LSP available
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
			shellHome = { -- replace `/Users/…` or `~` with `$HOME/`
				format = function(_self, _ctx, lines, callback)
					for i = 1, #lines do
						lines[i] = lines[i]:gsub("/Users/%a+", "$HOME"):gsub("~/", "$HOME/")
					end
					Chainsaw(lines) -- 🪚
					callback(nil, lines)
				end,
			},
			hardWrapAtTextwidth = {
				format = function(_self, ctx, _lines, callback)
					local view = vim.fn.winsaveview()

					vim.cmd("% normal! gww") -- each line, via `normal`, since `gggwG` breaks callouts
					local formattedLines = vim.api.nvim_buf_get_lines(ctx.buf, 0, -1, true)
					vim.cmd.undo()

					vim.fn.winrestview(view)
					callback(nil, formattedLines)
				end,
			},
			tsAddMissingImports = {
				format = function(_self, ctx, _lines, callback)
					-- PENDING https://github.com/stevearc/conform.nvim/issues/795
					vim.lsp.buf.code_action {
						context = { only = { "source.addMissingImports.ts" } }, ---@diagnostic disable-line: missing-fields, assign-type-mismatch
						apply = true,
					}
					vim.defer_fn(function() -- deferred for code action to update buffer
						local formattedLines = vim.api.nvim_buf_get_lines(ctx.buf, 0, -1, true)
						callback(nil, formattedLines)
					end, 100)
				end,
			},
			tsRemoveUnusedImports = {
				format = function(_self, ctx, _lines, callback)
					vim.lsp.buf.code_action {
						context = { only = { "source.removeUnusedImports.ts" } }, ---@diagnostic disable-line: missing-fields, assign-type-mismatch
						apply = true,
					}
					vim.defer_fn(function()
						local formattedLines = vim.api.nvim_buf_get_lines(ctx.buf, 0, -1, true)
						callback(nil, formattedLines)
					end, 100)
				end,
			},
		},
	},
}
