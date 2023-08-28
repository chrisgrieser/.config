local linterConfig = require("config.utils").linterConfigFolder
local lintersAndFormatters = {
	"codespell",
	"yamllint",
	"shellcheck",
	"shfmt", -- shell
	"markdownlint",
	"ruff", -- python linter/formatter, the lsp does diagnostics, the CLI does formatting
	"black", -- python formatter
	"vale", -- natural language
	"selene", -- lua
	"stylua", -- lua
	"prettier", -- only used for yaml and html https://github.com/mikefarah/yq/issues/515
	"rome", -- also an LSP; the lsp does diagnostics, the CLI does formatting
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
		python = {},
		json = {},
		javascript = {},
		typescript = {},
		gitcommit = {},
		toml = {},
	}

	-- use for codespell/cspell for all except bib and css
	for ft, _ in pairs(lint.linters_by_ft) do
		if ft ~= "bib" and ft ~= "css" then
			table.insert(lint.linters_by_ft[ft], "codespell")
		end
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

	-- FIX auto-save.nvim creating spurious errors for some reason. Therefore
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
		if not status or not decoded then return {} end
		decoded = decoded[1]
		if not decoded.errored then return {} end
		local diagnostics = {}
		for _, diag in ipairs(decoded.warnings) do
			-- filtering order-violations, since they are auto-fixed and would
			-- only add noise.
			if diag.rule ~= "order/properties-order" then
				table.insert(diagnostics, {
					lnum = diag.line - 1,
					col = diag.column - 1,
					end_lnum = diag.line - 1,
					end_col = diag.column - 1,
					message = diag.text:gsub("%b()", ""),
					code = diag.rule,
					user_data = { lsp = { code = diag.rule } },
					severity = vim.diagnostic.severity.WARN, -- output all as warnings
					source = "stylelint",
				})
			end
		end
		return diagnostics
	end

	-----------------------------------------------------------------------------
end

local function lintTriggers()
	vim.api.nvim_create_autocmd({ "BufReadPost", "InsertLeave", "TextChanged", "FocusGained" }, {
		callback = function() vim.defer_fn(require("lint").try_lint, 1) end,
	})

	-- due to auto-save.nvim, we need the custom event "AutoSaveWritePost"
	-- instead of "BufWritePost" to trigger linting to prevent race conditions
	vim.api.nvim_create_autocmd("User", {
		pattern = "AutoSaveWritePost",
		callback = function() require("lint").try_lint() end,
	})
end

--------------------------------------------------------------------------------

-- TODO add formatters when there are some PRs merged?
-- https://github.com/mhartington/formatter.nvim/pulls
local function formatterConfigs()
	local util = require("formatter.util")
	local rome = {
		exe = "rome",
		stdin = false, -- using the stdin formatting of rome has bugs with emojis
		args = { "format", "--write" },
	}

	local ruff = {
		exe = "ruff",
		stdin = true,
		args = {
			"check",
			"--fix-only",
			"--no-cache",
			"--stdin-filename",
			util.escape_path(util.get_current_buffer_file_path()),
		},
	}

	local stylelint = {
		exe = "stylelint",
		stdin = true,
		args = { "--fix", "--stdin" },
	}

	-- defined
	local codespell = {
		exe = "codespell",
		tmpdir = "/tmp",
		stdin = false,
		ignore_exitcode = true,
		args = {
			"--ignore-words",
			linterConfig .. "/codespell-ignore.txt",
			"--check-hidden",
			"--write-changes",
		},
	}

	local shellharden = {
		exe = "shellharden",
		stdin = false, -- using `--transform` and stdin does not seem to work
		args = { "--replace" },
	}

	local filetypes = {
		lua = { require("formatter.filetypes.lua").stylua },
		sh = { require("formatter.filetypes.sh").shfmt, shellharden },
		python = { require("formatter.filetypes.python").black, ruff },
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
			vim.defer_fn(vim.cmd.MasonToolsInstall, 500)
		end,
	},
	{
		"mfussenegger/nvim-lint",
		event = "VeryLazy",
		config = function()
			linterConfigs()
			lintTriggers()
		end,
	},
	{
		"mhartington/formatter.nvim",
		config = formatterConfigs,
		cmd = { "Format", "FormatWrite" },
		keys = {
			{ "<D-s>", vim.cmd.FormatWrite, desc = "󰒕  Save & Format" },
		},
	},
}
