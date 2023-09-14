local linterConfig = require("config.utils").linterConfigFolder
--------------------------------------------------------------------------------

local linters = {
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

local formatters = {
	lua = { "stylua" },
	python = { "black" },
	yaml = { "prettier" },
	html = { "prettier" },
	markdown = { "markdownlint" },
	css = { "stylelint", "prettier" },
	sh = { "shfmt", "shellharden" },
	-- bib = { bibtexTidy },
}


--------------------------------------------------------------------------------

local function linterConfigs()
	local lint = require("lint")
	lint.linters_by_ft = linters

	-- use for codespell/cspell for all except bib and css
	for ft, _ in pairs(linters) do
		if ft ~= "bib" and ft ~= "css" then table.insert(lint.linters_by_ft[ft], "codespell") end
	end

	-- https://github.com/mfussenegger/nvim-lint/tree/master/lua/lint/linters
	-- only changed severity for the parser
	lint.linters.codespell.args = {
		"--ignore-words",
		linterConfig .. "/codespell-ignore.txt",
	}

	lint.linters.markdownlint.args = { "--config", linterConfig .. "/markdownlint.yaml" }
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
end

--------------------------------------------------------------------------------

return {
	{ -- auto-install missing linters & formatters
		-- (auto-install of lsp servers done via `mason-lspconfig.nvim`)
		"WhoIsSethDaniel/mason-tool-installer.nvim",
		event = "VeryLazy",
		dependencies = "williamboman/mason.nvim",
		config = function()
			local toolsToAutoinstall = {}
			for _, linterObj in pairs(linters) do
				local linterStr = vim.tbl_flatten(linterObj)
				table.insert(toolsToAutoinstall, linterStr)
			end


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
		opts = { formatters_by_ft = formatters },
		keys = {
			{
				"<D-s>",
				function()
					require("conform").format()
					vim.cmd.update()
				end,
				mode = { "n", "x" },
				desc = "󰒕 Format & Save",
			},
		},
	},
}
