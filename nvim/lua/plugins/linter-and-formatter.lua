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
	"actionlint", -- TODO this is just a test
}
--------------------------------------------------------------------------------

local function linterConfigs()
	local lint = require("lint")
	lint.linters_by_ft = {
		lua = { "selene" },
		css = { "stylelint" },
		sh = { "shellcheck" },
		zsh = { "shellcheck" },
		markdown = { "vale", "markdownlint" },
		yaml = { "yamllint" },
		json = {},
		javascript = {},
		typescript = {},
		gitcommit = {},
		toml = {},
		python = {},
	}
	-- use for codespell for all
	for ft, _ in pairs(lint.linters_by_ft) do
		table.insert(lint.linters_by_ft[ft], "codespell")
	end

	-- "BufWritePost" relevant due to nvim-autosave
	vim.api.nvim_create_autocmd({ "BufReadPost", "BufWritePost", "InsertLeave", "TextChanged" }, {
		pattern = "*",
		callback = function(ctx)
			local ft = vim.bo.filetype
			local event = ctx.event
			-- FIX weird error message for shellcheck
			if ft == "sh" and (event == "TextChanged" or event == "BufReadPost") then
				return
			end

			-- FIX some spurious lints on first enter for selene
			if ft == "lua" and event == "BufReadPost" then
				vim.defer_fn(lint.try_lint, 200)
				return
			end

			lint.try_lint()
		end,
	})

	-- https://github.com/mfussenegger/nvim-lint/tree/master/lua/lint/linters
	-- only changed severity for the parser
	lint.linters.codespell.parser = require("lint.parser").from_errorformat(
		"%f:%l:%m",
		{ severity = vim.diagnostic.severity.WARN, source = "codespell" }
	)
	lint.linters.codespell.args = {
		"--skip='*.css,*.bib'", -- filetypes/-names to ignore
		"--ignore-words",
		linterConfig .. "/codespell-ignore.txt",
	}

	lint.linters.markdownlint.args = { "--config", linterConfig .. "/markdownlintrc" }
	lint.linters.vale.args = {
		"--no-exit",
		"--output=JSON",
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
		"--format=parsable",
		"-",
	}

	-- not using stylelint-lsp due to: https://github.com/bmatcuk/stylelint-lsp/issues/36
	lint.linters.stylelint.args = {
		"--formatter=json",
		"--config",
		linterConfig .. "/stylelintrc.yml",
		"--stdin",
		"--stdin-filename",
		function() return vim.fn.expand("%:p") end,
	}

	lint.try_lint() -- run on first buffer once this plugin is initialized
end

--------------------------------------------------------------------------------

local function formatterConfigs()
	local util = require("formatter.util")

	local rome = {
		exe = "rome",
		stdin = false, -- using the stdin formatting of rome bugs with emojis
		try_node_modules = true,
		args = { "format", "--write", util.escape_path(util.get_current_buffer_file_path()) },
	}

	local stylelint = {
		exe = "stylelint",
		stdin = true,
		try_node_modules = true,
		args = {
			-- using config without ordering, since automatic re-ordering can be
			-- confusing. Config with stylelint-order is only run on build.
			"--config",
			linterConfig .. "/stylelintrc-formatting.yml",
			"--fix",
			"--stdin",
			"--stdin-filename",
			util.escape_path(util.get_current_buffer_file_path()),
		},
	}

	local prettier = function(parser)
		return {
			exe = "prettier",
			stdin = true,
			try_node_modules = true,
			args = {
				"--config",
				linterConfig .. "/prettierrc.yml",
				"--stdin-filepath",
				util.escape_path(util.get_current_buffer_file_path()),
				"--parser=" .. parser,
			},
		}
	end

	local codespell = {
		exe = "codespell",
		stdin = false,
		tempfile_dir = "/tmp", -- codespell requires a tmp dir
		args = {
			"--ignore-words",
			linterConfig .. "/codespell-ignore.txt",
			"--skip='*.css,*.bib'", -- filetypes/-names to ignore
			"--check-hidden",
			"--write-changes",
		},
	}

	-- https://github.com/jose-elias-alvarez/null-ls.nvim/tree/main/lua/null-ls/builtins/formatting
	-- https://github.com/mhartington/formatter.nvim/tree/master/lua/formatter/filetypes
	require("formatter").setup {
		filetype = {
			["*"] = { codespell }, -- filetype-exceptions defined in codespell config
			lua = { require("formatter.filetypes.lua").stylua },
			sh = { require("formatter.filetypes.sh").shfmt },
			zsh = { require("formatter.filetypes.sh").shfmt },
			python = { require("formatter.filetypes.python").black },
			html = { prettier("html") },
			yaml = { prettier("yaml") },
			javascript = { rome },
			typescript = { rome },
			json = { rome },
			css = { stylelint, prettier("css") },
			scss = { stylelint },
		},
	}
end

--------------------------------------------------------------------------------

return {
	{ -- auto-install missing linters & formatters
		"WhoIsSethDaniel/mason-tool-installer.nvim",
		event = "VeryLazy",
		dependencies = "williamboman/mason.nvim",
		config = function()
			-- needs to trigger myself, since `run_on_start`, does not work well
			-- with lazy-loading
			require("mason-tool-installer").setup {
				-- auto-install of lsp servers done via `mason-lspconfig.nvim`
				ensure_installed = lintersAndFormatters,
				run_on_start = false,
			}
			vim.defer_fn(vim.cmd.MasonToolsInstall, 1000)
		end,
	},
	{
		"mfussenegger/nvim-lint",
		event = "VeryLazy",
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
