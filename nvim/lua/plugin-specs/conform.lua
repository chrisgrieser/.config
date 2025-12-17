-- DOCS https://github.com/stevearc/conform.nvim#formatters
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
		log_level = vim.log.levels.WARN, -- for `ConformInfo`
		default_format_opts = { lsp_format = "first" },
		formatters_by_ft = {
			markdown = {
				"mdformat",
				"no-blank-after-heading",
				"markdown-toc",
				"markdownlint",
				"injected",
			},
			python = { "ruff_fix", "ruff_organize_imports" },
			zsh = { "shell-home", "shellcheck" },
			json = { lsp_format = "prefer", "jq" }, -- use `biome` (via LSP), with `jq` as fallback
			typescript = {
				"ts-add-missing-imports",
				"ts-remove-unused-imports",
				"biome-organize-imports",
			},

			-- fallback, used when no formatters defined and no LSP available
			_ = { "trim_whitespace", "trim_newlines", "squeeze_blanks" },
		},
		formatters = {
			injected = { -- https://github.com/stevearc/conform.nvim/blob/master/doc/formatter_options.md#injected
				options = {
					ignore_errors = true,
					lang_to_formatters = { -- need to set formatters https://github.com/stevearc/conform.nvim/issues/791
						json = { "jq" },
						yaml = { "yq" }, -- also applies to yaml frontmatter
						lua = { "stylua" },
						zsh = { "shfmt" },
						bash = { "shfmt" },
					},
				},
			},
			shellcheck = {
				-- add `--shell=bash` to force to work with `zsh`
				args = "'$FILENAME' --format=diff --shell=bash | patch -p1 '$FILENAME'",
			},
			["markdown-toc"] = {
				-- order used by markdownlint's `unordered-style: sublist`
				prepend_args = { "--bullets", "-", "--bullets", "+", "--bullets", "*" },

				-- FIX frontmatter being affected https://github.com/jonschlinkert/markdown-toc/issues/151
				condition = function(_self, ctx)
					-- only enable if the `<!-- toc -->` is present
					local lines = vim.api.nvim_buf_get_lines(ctx.buf, 0, -1, false)
					for _, line in pairs(lines) do
						if line == "<!-- toc -->" then return true end
					end
					return false
				end,
			},
			mdformat = {
				prepend_args = { "--number", "--wrap=" .. vim.o.textwidth },
			},
			---MY CUSTOM FORMATTERS------------------------------------------------
			["no-blank-after-heading"] = {
				format = function(_self, _ctx, lines, callback)
					local filtered = {}
					for ln = 1, #lines do
						local prevLine = lines[ln - 1] or ""
						local nextLine = lines[ln + 1] or ""
						local skip = prevLine:find("^#+ ")
							and lines[ln] == ""
							and not (nextLine:find("^#+ ") or nextLine:find("^```"))
						if not skip then table.insert(filtered, lines[ln]) end
					end
					callback(nil, filtered)
				end,
			},
			["shell-home"] = { -- replace `/Users/…` or `~` with `$HOME/`
				format = function(_self, _ctx, lines, callback)
					local function replace(line)
						return line:gsub("/Users/%a+", "$HOME"):gsub("([^/\\])~/", "%1$HOME/")
					end
					callback(nil, vim.tbl_map(replace, lines))
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
