-- DOCS https://github.com/stevearc/conform.nvim?tab=readme-ov-file#formatters
--------------------------------------------------------------------------------

return {
	"stevearc/conform.nvim",
	cmd = "ConformInfo",
	keys = {
		{ "<D-s>", function() require("conform").format() end, desc = "󱉯 Format buffer" },
		{
			"<D-s>",
			function()
				require("conform").format({}, function() end)
			end,
			ft = "typescript",
			desc = " Format buffer",
		},
	},
	opts = {
		default_format_opts = {
			lsp_format = "first",
		},
		formatters_by_ft = {
			lua = { "stylua" },
			markdown = { "markdownlint", "markdown-toc", "injected" },
			python = { "ruff_format", "ruff_fix", "ruff_organize_imports" },
			typescript = { "biome-organize-imports" },
			zsh = { "shell_home", "shellcheck" },

			-- fallback, used when no formatters are defined and no LSP is available
			_ = { "trim_whitespace", "trim_newlines", "squeeze_blanks" },
		},
		formatters = {
			shell_home = {
				format = function(_, _, _, callback)
					vim.cmd([[% s_/Users/\w\+/_$HOME/_e]]) -- replace `/Users/…` with `$HOME/`
					callback()
				end,
			},
			shellcheck = { -- force to work with `zsh`
				args = "'$FILENAME' --format=diff --shell=bash | patch -p1 '$FILENAME'",
			},
		},
	},
	config = function(_, opts)
		require("conform").setup(opts)
		require("conform.formatters.injected").options.ignore_errors = false
	end,
}
