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

	-- use for codespell for all except bib and css
	for ft, _ in pairs(lint.linters_by_ft) do
		if ft ~= "bib" and ft ~= "css" then table.insert(lint.linters_by_ft[ft], "codespell") end
	end

	-- https://github.com/mfussenegger/nvim-lint/tree/master/lua/lint/linters
	-- only changed severity for the parser
	lint.linters.codespell.parser = require("lint.parser").from_errorformat(
		"%f:%l:%m",
		{ severity = vim.diagnostic.severity.WARN, source = "codespell" }
	)
	lint.linters.codespell.args = {
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

	-- FIX auto-save.nvim creating spurious errors for some reason. therefore
	-- removing stylelint-error from it. Also, suppress warnings
	lint.linters.stylelint.args = {
		"--quiet", -- suppresses warnings (since stylelint-order stuff too noisy)
		"--formatter=json",
		"--stdin",
		"--stdin-filename",
		function() return vim.fn.expand("%:p") end,
	}
	lint.linters.stylelint.parser = function(output)
		local status, decoded = pcall(vim.json.decode, output)
		if not status or not decoded or vim.tbl_isempty(decoded) then return {} end
		decoded = decoded[1]
		local diagnostics = {}
		if decoded.errored then
			for _, message in ipairs(decoded.warnings) do
				table.insert(diagnostics, {
					lnum = message.line - 1,
					col = message.column - 1,
					end_lnum = message.line - 1,
					end_col = message.column - 1,
					message = message.text,
					code = message.rule,
					user_data = { lsp = { code = message.rule } },
					severity = vim.diagnostic.severity.ERROR,
					source = "stylelint",
				})
			end
		end
		return diagnostics
	end

	-- SETUP LINTING AUTOCMD
	lint.try_lint() -- run on first buffer once this plugin is initialized

	-- "BufWritePost" relevant due to nvim-autosave
	vim.api.nvim_create_autocmd(
		{ "BufReadPost", "AutoSaveWritePost", "InsertLeave", "TextChanged", "FocusGained" },
		{
			pattern = "*",
			callback = function(ctx)
				local fileDoesNotExist = vim.fn.filereadable(vim.fn.expand("%")) == 0
				local specialBuffer = vim.bo.buftype ~= ""
				if fileDoesNotExist and not specialBuffer then return end

				local ft = vim.bo.filetype
				local event = ctx.event
				-- FIX weird error message for shellcheck
				if ft == "sh" and (event == "TextChanged" or event == "BufReadPost") then return end

				-- FIX spurious lints on first enter for selene
				if ft == "lua" and event == "BufReadPost" then
					vim.defer_fn(lint.try_lint, 100)
					return
				end

				lint.try_lint()
			end,
		}
	)
end

--------------------------------------------------------------------------------

local function formatterConfigs()
	local util = require("formatter.util")

	local rome = {
		exe = "rome",
		tempfile_dir = "/tmp",
		stdin = false, -- using the stdin formatting of rome has bugs with emojis
		try_node_modules = true,
		args = { "format", "--write", util.escape_path(util.get_current_buffer_file_path()) },
	}

	local stylelint = {
		exe = "stylelint",
		try_node_modules = true,
		args = {
			"--fix",
			"--stdin",
			"--stdin-filename",
			util.escape_path(util.get_current_buffer_file_path()),
		},
	}

	local codespell = {
		exe = "codespell",
		stdin = false,
		tempfile_dir = "/tmp", -- codespell requires a tmp dir
		args = {
			"--ignore-words",
			linterConfig .. "/codespell-ignore.txt",
			"--check-hidden",
			"--write-changes",
		},
	}

	local filetypes = {
		lua = { require("formatter.filetypes.lua").stylua },
		sh = { require("formatter.filetypes.sh").shfmt },
		zsh = { require("formatter.filetypes.sh").shfmt },
		python = { require("formatter.filetypes.python").black },
		html = { require("formatter.filetypes.html").prettier },
		yaml = { require("formatter.filetypes.yaml").prettier },
		javascript = { rome },
		typescript = { rome },
		json = { rome },
		css = { stylelint, require("formatter.filetypes.css").prettier },
		scss = { stylelint },
		gitcommit = {},
		toml = {},
	}

	-- use for codespell for all except bib and css
	for ft, _ in pairs(filetypes) do
		if ft ~= "bib" and ft ~= "css" then table.insert(filetypes[ft], codespell) end
	end

	-- https://github.com/jose-elias-alvarez/null-ls.nvim/tree/main/lua/null-ls/builtins/formatting
	-- https://github.com/mhartington/formatter.nvim/tree/master/lua/formatter/filetypes
	require("formatter").setup {
		filetype = filetypes,
	}
end

--------------------------------------------------------------------------------

return {
	{ -- auto-install missing linters & formatters
		-- (auto-install of lsp servers done via `mason-lspconfig.nvim`)
		"WhoIsSethDaniel/mason-tool-installer.nvim",
		event = "VeryLazy",
		dependencies = "williamboman/mason.nvim",
		config = function()
			-- triggered myself, since `run_on_start`, does not work w/ lazy-loading
			require("mason-tool-installer").setup {
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
			{ "<D-s>", "<cmd>FormatWriteLock<CR>", desc = "󰒕  Save & Format" },
		},
		config = formatterConfigs,
	},
}
