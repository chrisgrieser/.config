local linterConfig = require("config.utils").linterConfigFolder
--------------------------------------------------------------------------------

local toolsToAutoinstall = {
	"debugpy", -- just here to install ensure auto-install
	"codespell",
	"yamllint",
	"shellcheck",
	"shfmt",
	"markdownlint",
	"black",
	"selene",
	"stylua",
	"pylint",
	"proselint",
	"bibtex-tidy",
	"prettier", -- only yaml formatter preserving blank lines https://github.com/mikefarah/yq/issues/515
	-- INFO stylelint included in mason, but not its plugins, which then cannot be found https://github.com/williamboman/mason.nvim/issues/695
}

--------------------------------------------------------------------------------

local function linterConfigs()
	local lint = require("lint")
	lint.linters_by_ft = {
		lua = { "selene" },
		css = { "stylelint" },
		sh = { "shellcheck" },
		zsh = { "shellcheck" },
		markdown = { "proselint", "markdownlint" },
		yaml = { "yamllint" },
		python = { "pylint" },
		json = {},
		javascript = {},
		typescript = {},
		gitcommit = {},
		toml = {},
	}

	-- use for codespell/cspell for all except bib and css
	for ft, _ in pairs(lint.linters_by_ft) do
		if ft ~= "bib" and ft ~= "css" then table.insert(lint.linters_by_ft[ft], "codespell") end
	end

	-- https://github.com/mfussenegger/nvim-lint/tree/master/lua/lint/linters
	-- only changed severity for the parser
	lint.linters.codespell.args = {
		"--ignore-words",
		linterConfig .. "/codespell-ignore.txt",
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

	lint.linters.markdownlint.args = {
		"--disable=no-trailing-spaces", -- not disabled in config, so it's enabled for formatting
		"--disable=no-multiple-blanks",
		"--config=" .. linterConfig .. "/markdownlint.yaml",
	}

	-- FIX auto-save.nvim creating spurious errors for some reason. Therefore
	-- removing stylelint-error from it. Also, suppress warnings
	-- lint.linters.stylelint.args = {
	-- 	"--quiet", -- suppresses warnings (since stylelint-order stuff too noisy)
	-- 	"--formatter=json",
	-- 	"--stdin",
	-- 	"--stdin-filename",
	-- 	function() return vim.fn.expand("%:p") end,
	-- }
	-- lint.linters.stylelint.parser = function(output)
	-- 	local status, decoded = pcall(vim.json.decode, output)
	-- 	if not status or not decoded then return {} end
	-- 	decoded = decoded[1]
	-- 	if not decoded.errored then return {} end
	-- 	local diagnostics = {}
	-- 	for _, diag in ipairs(decoded.warnings) do
	-- 		-- filtering order-violations, since they are auto-fixed and would
	-- 		-- only add noise.
	-- 		if diag.rule ~= "order/properties-order" then
	-- 			table.insert(diagnostics, {
	-- 				lnum = diag.line - 1,
	-- 				col = diag.column - 1,
	-- 				end_lnum = diag.line - 1,
	-- 				end_col = diag.column - 1,
	-- 				message = diag.text:gsub("%b()", ""),
	-- 				code = diag.rule,
	-- 				user_data = { lsp = { code = diag.rule } },
	-- 				severity = vim.diagnostic.severity.WARN, -- output all as warnings
	-- 				source = "stylelint",
	-- 			})
	-- 		end
	-- 	end
	-- 	return diagnostics
	-- end

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
	-- run once on start
	require("lint").try_lint()
end

--------------------------------------------------------------------------------

local formatterConfig = {
	formatters_by_ft = {
		lua = { "stylua" },
		python = { "black" },
		yaml = { "prettier" },
		html = { "prettier" },
		markdown = { "markdownlint" },
		css = { "stylelint", "prettier" },
		sh = { "shfmt", "shellharden" },
		bib = { "bibtex_tidy" },
		["*"] = { "codespell" },
	},
	-- teh

	-- custom formatters
	formatters = {
		-- stylelint = {},
		codespell = {
			command = "codespell",
			args = {
				"$FILENAME",
				"--write-changes",
				-- "--ignore-words",
				-- linterConfig .. "/codespell-ignore.txt",
			},
			stdin = false,
			-- condition = function(ctx)
			-- 	return not (ctx.filename:find("%.css$") or ctx.filename:find("%.bib$"))
			-- end,
		},
		markdownlint = {
			command = "markdownlint",
			args = { "--fix", "--config", linterConfig .. "/markdownlint.yaml", "$FILENAME" },
			stdin = false,
		},
		bibtex_tidy = {
			command = "bibtex-tidy",
			args = {
				"--quiet",
				"--tab",
				"--curly",
				"--strip-enclosing-braces",
				"--enclosing-braces=title,journal,booktitle",
				"--numeric",
				"--months",
				"--no-align",
				"--encode-urls",
				"--duplicates",
				"--drop-all-caps",
				"--sort-fields",
				"--remove-empty-fields",
				"--no-wrap",
			},
			stdin = true,
		},
	},
}

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
				ensure_installed = toolsToAutoinstall,
				run_on_start = false,
			}
			vim.defer_fn(vim.cmd.MasonToolsInstall, 2000)
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
		"stevearc/conform.nvim",
		opts = formatterConfig,
		keys = {
			{
				"<D-s>",
				function()
					require("conform").format { lsp_fallback = true }
					vim.cmd.update()
				end,
				mode = { "n", "x" },
				desc = "󰒕 Format & Save",
			},
		},
	},
}
