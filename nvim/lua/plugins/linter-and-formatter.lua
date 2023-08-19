-- https://github.com/jose-elias-alvarez/null-ls.nvim/blob/main/doc/BUILTIN_CONFIG.md
--------------------------------------------------------------------------------

local linterConfig = require("config.utils").linterConfigFolder
local lintersAndFormatters = {
	"yamllint", -- only for diagnostics, not for formatting
	"shellcheck", -- needed for bash-lsp
	"shfmt", -- shell
	"markdownlint",
	"black", -- python formatter
	"vale", -- natural language
	"codespell", -- superset of `misspell`, therefore only using codespell
	"selene", -- lua
	"stylua", -- lua
	"prettier", -- only used for yaml and html https://github.com/mikefarah/yq/issues/515
	"rome", -- also an LSP; the lsp does diagnostics, the CLI via null-ls does formatting
	-- stylelint included in mason, but not its plugins, which then cannot be found https://github.com/williamboman/mason.nvim/issues/695
}
--------------------------------------------------------------------------------

local function linterConfigs()
	local lint = require("lint")
	lint.linters_by_ft = {
		lua = { "selene", "codespell" },
		css = { "stylelint", "codespell" },
		sh = { "shellcheck", "codespell" },
		zsh = { "shellcheck", "codespell" },
		markdown = { "vale", "markdownlint", "codespell" },
		yaml = { "yamllint", "codespell" },
		json = { "codespell" },
		javascript = { "codespell" },
		typescript = { "codespell" },
		gitcommit = { "codespell" },
		toml = { "codespell" },
		python = { "codespell" },
	}

	-- "BufWritePost" relevant due to nvim-autosave
	vim.api.nvim_create_autocmd({ "BufEnter", "BufReadPost", "BufWritePost", "InsertLeave", "TextChanged" }, {
		pattern = "*",
		callback = function(ctx)
			-- FIX weird error message for shellcheck
			if vim.bo.filetype == "sh" and (ctx.event == "TextChanged" or ctx.event == "BufEnter") then return end

			lint.try_lint()
		end,
	})

	-- Linter configs
	-- https://github.com/mfussenegger/nvim-lint/tree/master/lua/lint/linters
	lint.linters.codespell.args = { "--ignore-words", linterConfig .. "/codespell-ignore.txt" }
	lint.linters.markdownlint.args = { "--config", linterConfig .. "/markdownlintrc" }
	lint.linters.vale.args = {
		"--no-exit",
		"--output",
		"JSON",
		"--config",
		linterConfig .. "/vale/vale.ini",
	}
	lint.linters.shellcheck.args = {
		"--shell=bash", -- force to work with zsh
		"--format=json",
		"-",
	}
	lint.linters.yamllint.args = {
		"--config-file",
		linterConfig .. "/yamllint.yaml",
		"--format",
		"parsable",
		"-",
	}
	lint.linters.stylelint.args = {
		"-f",
		"json",
		"--quiet",
		-- "--config",
		-- linterConfig .. "/stylelintrc.yml",
		"--stdin",
		"--stdin-filename",
		function() return vim.fn.expand("%:p") end,
	}
end

--------------------------------------------------------------------------------

local function formatterConfigs()
	-- using the stdin formatting of rome bugs with emojis
	local util = require("formatter.util")
	local romeConfig = {
		exe = "rome",
		stdin = false,
		args = { "format", "--write", util.escape_path(util.get_current_buffer_file_path()) },
	}

	-- https://github.com/mhartington/formatter.nvim/tree/master/lua/formatter/filetypes
	-- Provides the Format, FormatWrite, FormatLock, and FormatWriteLock commands
	require("formatter").setup {
		filetype = {
			lua = { require("formatter.filetypes.lua").stylua },
			sh = { require("formatter.filetypes.sh").shfmt },
			zsh = { require("formatter.filetypes.sh").shfmt },
			python = { require("formatter.filetypes.python").black },
			html = { require("formatter.filetypes.html").prettier },
			yaml = { require("formatter.filetypes.yaml").prettier },
			javascript = { romeConfig },
			typescript = { romeConfig },
			json = { romeConfig },
		},
	}
end

--------------------------------------------------------------------------------

return {
	{ -- auto-install missing linters & formatters
		-- INFO auto-install of lsp servers done via `mason-lspconfig.nvim`
		"WhoIsSethDaniel/mason-tool-installer.nvim",
		event = "VimEnter", -- later does not trigger run_on_start properly
		dependencies = "williamboman/mason.nvim",
		opts = {
			ensure_installed = lintersAndFormatters,
			auto_update = false,
			run_on_start = true,
			start_delay = 1000,
		},
	},
	{
		"mfussenegger/nvim-lint",
		event = "BufReadPost", -- earlier to work on first buffer
		config = linterConfigs,
	},
	{
		"mhartington/formatter.nvim",
		keys = {
			{ "<D-s>", "<cmd>FormatWrite<CR>", desc = "󰒕  Save & Format" },
		},
		config = formatterConfigs,
	},
}
