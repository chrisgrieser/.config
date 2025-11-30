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
			markdown = { "hard-wrap-at-textwidth", "markdownlint", "markdown-toc", "injected" },
			python = { "ruff_fix", "ruff_organize_imports" },
			zsh = { "shell-home", "shellcheck" },
			json = { lsp_format = "prefer", "jq" }, -- use `biome` (via LSP), with `jq` as fallback
			typescript = {
				"ts-add-missing-imports",
				"ts-remove-unused-imports",
				"biome-organize-imports",
			},

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
			["shell-home"] = { -- replace `/Users/…` or `~` with `$HOME/`
				format = function(_self, _ctx, lines, callback)
					local function replace(line)
						return line:gsub("/Users/%a+", "$HOME"):gsub("~/", "$HOME/")
					end
					callback(nil, vim.tbl_map(replace, lines))
				end,
			},
			["hard-wrap-at-textwidth"] = {
				format = function(_self, _ctx, lines, callback)
					local view = vim.fn.winsaveview()

					for ln = #lines, 1, -1 do -- upwards to to avoid line shift
						vim.api.nvim_win_set_cursor(0, { ln, 0 })
						local node = vim.treesitter.get_node()
						local doWrap = node
							and node:type() ~= "code_fence_content"
							and node:type() ~= "html_block"
							and not vim.startswith(node:type(), "pipe_table")
						if doWrap then vim.cmd.normal { "gww", bang = true } end
					end
					local formattedLines = vim.api.nvim_buf_get_lines(0, 0, -1, true)

					vim.cmd.undo()
					vim.fn.winrestview(view)
					callback(nil, formattedLines)
				end,
			},
			["ts-add-missing-imports"] = {
				format = function(_self, ctx, _lines, callback)
					-- PENDING https://github.com/stevearc/conform.nvim/issues/795
					vim.lsp.buf.code_action {
						context = { only = { "source.addMissingImports.ts" } }, ---@diagnostic disable-line: missing-fields, assign-type-mismatch
						apply = true,
					}
					-- works better without undoing changes, probably due to race?
					vim.defer_fn(function() -- deferred for code action to update buffer
						local formattedLines = vim.api.nvim_buf_get_lines(ctx.buf, 0, -1, true)
						callback(nil, formattedLines)
					end, 100)
				end,
			},
			["ts-remove-unused-imports"] = {
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
