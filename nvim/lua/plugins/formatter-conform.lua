return {
	"stevearc/conform.nvim",
	mason_dependencies = { "stylua", "markdownlint", "markdown-toc" },
	cmd = "ConformInfo",
	keys = {
		-- NOTE in TYPESCRIPT, overridden with custom function in `/ftplugin/typescript.lua`
		{ "<D-s>", function() require("conform").format() end, desc = "󰒕 Format" },
	},
	opts = {
		default_format_opts = {
			lsp_format = "first", -- unwanted LSP formatters disabled in lsp-config
		},
		formatters_by_ft = {
			lua = { "stylua" },
			markdown = { "markdown-toc", "markdownlint", "injected" },
			query = { "format-queries" },
			zsh = { "shell_home" },
			python = { "ruff_fix_all" },
			just = { "just", "trim_whitespace", "trim_newlines", "squeeze_blanks" },

			-- fallback, used when no formatters are defined and no LSP is available
			_ = { "trim_whitespace", "trim_newlines", "squeeze_blanks", "indent_expr" },
		},
		formatters = {
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
	},
	config = function(_, opts)
		require("conform").setup(opts)
		require("conform.formatters.injected").options.ignore_errors = true
	end,
}
