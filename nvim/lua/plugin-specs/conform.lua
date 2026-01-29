-- DOCS https://github.com/stevearc/conform.nvim#formatters
--------------------------------------------------------------------------------

return {
	"stevearc/conform.nvim",
	cmd = "ConformInfo",
	keys = {
		-- stylua: ignore
		{ "<D-s>", function() require("conform").format() end, mode = { "n", "x" }, desc = "󱉯 Format buffer" },
	},
	opts = {
		log_level = vim.log.levels.WARN, -- for `ConformInfo`
		default_format_opts = { lsp_format = "last" },
		formatters_by_ft = {
			markdown = { "listify-links-in-notes" },
			python = { "ruff_fix", "ruff_organize_imports" },
			zsh = { "shell-home", "shellcheck" },
			json = { lsp_format = "prefer", "jq" }, -- use `biome` (via LSP), with `jq` as fallback
			-- stylua: ignore
			typescript = { "ts-add-missing-imports", "ts-remove-unused-imports", "biome-organize-imports" },

			-- fallback, used when no formatters defined and no LSP available
			_ = { "trim_whitespace", "trim_newlines", "squeeze_blanks" },
		},
		formatters = {
			shellcheck = {
				-- add `--shell=bash` to force to work with `zsh`
				args = "'$FILENAME' --format=diff --shell=bash | patch -p1 '$FILENAME'",
			},
			---MY CUSTOM FORMATTERS------------------------------------------------
			["listify-links-in-notes"] = {
				condition = function(_, ctx) return vim.startswith(ctx.dirname, vim.g.notesDir) end,
				format = function(_self, _ctx, lines, callback)
					local updated = vim.tbl_map(function(line)
						return line
							:gsub("^%[%[.*%]%]$", "- %0") -- wikilinks
							:gsub("^%[.*]%(.*%)$", "- %0") -- mdlinks
							:gsub("^<[^!].*>$", "- %0") -- bare links, not html-comment
					end, lines)
					callback(nil, updated)
				end,
			},
			["shell-home"] = { -- replace `/Users/…` or `~` with `$HOME/`
				format = function(_self, _ctx, lines, callback)
					local updated = vim.tbl_map(function(line)
						return line
							:gsub("/Users/%a+", "$HOME") -- /Users/name
							:gsub("([^/\\])~/", "%1$HOME/") -- ~/
					end, lines)
					callback(nil, updated)
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
