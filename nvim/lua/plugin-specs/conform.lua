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
			markdown = { "markdownlint", "markdown-toc", "injected" },
			python = { "ruff_fix", "ruff_organize_imports" },
			typescript = {
				"tsAddMissingImports",
				-- "tsRemoveUnusedImports",
				-- "biome-organize-imports",
			},
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
			shellHome = { -- replace `/Users/…` with `$HOME/`
				format = function(_self, _ctx, lines, callback)
					local outLines = vim.tbl_map(
						function(line) return line:gsub("/Users/%a+", "$HOME") end,
						lines
					)
					callback(nil, outLines)
				end,
			},
			-- PENDING https://github.com/stevearc/conform.nvim/issues/795
			tsAddMissingImports = {
				format = function(_self, ctx, _lines, callback)
					local ts_ls = vim.lsp.get_clients({ name = "ts_ls", bufnr = ctx.buf })[1]
					if not ts_ls then return end

					local params = vim.lsp.util.make_range_params(nil, ts_ls.offset_encoding)
					params.context = { ---@diagnostic disable-line: inject-field
						only = { "source.addMissingImports.ts" },
						diagnostics = {},
					}
					local results =
						vim.lsp.buf_request_sync(ctx.buf, "textDocument/codeAction", params, 2000)
					Chainsaw(results) -- 🪚

					if not results then return end
					for _, result in pairs(results) do
						vim.lsp.util.apply_workspace_edit(result.result, ts_ls.offset_encoding)
					end

					local outLines = vim.api.nvim_buf_get_lines(ctx.buf, 0, -1, true)
					callback(nil, outLines)
				end,
			},
			tsRemoveUnusedImports = {
				format = function(_self, ctx, _lines, callback)
					vim.lsp.buf.code_action {
						context = { only = { "source.removeUnusedImports.ts" } }, ---@diagnostic disable-line: missing-fields, assign-type-mismatch
						apply = true,
					}
					vim.defer_fn(function()
						local outLines = vim.api.nvim_buf_get_lines(ctx.buf, 0, -1, true)
						callback(nil, outLines)
					end, 60)
				end,
			},
		},
	},
}
