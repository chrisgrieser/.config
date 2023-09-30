local u = require("config.utils")
local linterConfig = require("config.utils").linterConfigFolder
--------------------------------------------------------------------------------

local linters = {
	lua = { "selene" },
	css = { "stylelint" },
	sh = { "shellcheck" },
	markdown = { "markdownlint", "vale" },
	yaml = { "yamllint" },
	python = { "pylint" },
	gitcommit = {},
	json = {},
	javascript = {},
	typescript = {},
	toml = {},
	applescript = {},
	bib = {},
}

-- PENDING https://github.com/mfussenegger/nvim-lint/issues/355
for ft, _ in pairs(linters) do
	table.insert(linters[ft], "codespell")
	table.insert(linters[ft], "editorconfig-checker")
end

local formatters = {
	javascript = { "biome" },
	typescript = { "biome" },
	json = { "biome" },
	jsonc = { "biome" },
	lua = { "stylua" },
	python = { "black" },
	yaml = { "prettier" },
	html = { "prettier" },
	markdown = { "markdown-toc", "markdownlint", "injected" },
	css = { "stylelint", "prettier" },
	sh = { "shellcheck", "shfmt" },
	bib = { "trim_whitespace", "bibtex-tidy" },
	["_"] = { "trim_whitespace", "trim_newlines", "squeeze_blanks" },
	["*"] = { "codespell" },
}

local debuggers = { "debugpy" }

local dontInstall = {
	-- installed externally due to its plugins: https://github.com/williamboman/mason.nvim/issues/695
	"stylelint",
	-- not real formatters, but pseudo-formatters from conform.nvim
	"trim_whitespace",
	"trim_newlines",
	"squeeze_blanks",
	"injected",
}

---given the linter- and formatter-list of nvim-lint and conform.nvim, extract a
---list of all tools that need to be auto-installed
---@param myLinters object[]
---@param myFormatters object[]
---@param myDebuggers string[]
---@param ignoreTools string[]
---@return string[] tools
---@nodiscard
local function toolsToAutoinstall(myLinters, myFormatters, myDebuggers, ignoreTools)
	-- get all linters, formatters, & debuggers and merge them into one list
	local linterList = vim.tbl_flatten(vim.tbl_values(myLinters))
	local formatterList = vim.tbl_flatten(vim.tbl_values(myFormatters))
	local tools = vim.list_extend(linterList, formatterList)
	vim.list_extend(tools, myDebuggers)

	-- only unique tools
	table.sort(tools)
	tools = vim.fn.uniq(tools)

	-- remove exceptions not to install
	tools = vim.tbl_filter(function(tool) return not vim.tbl_contains(ignoreTools, tool) end, tools)
	return tools
end

--------------------------------------------------------------------------------

local function linterConfigs()
	local lint = require("lint")
	lint.linters_by_ft = linters

	lint.linters.codespell.args = { "--toml=" .. linterConfig .. "/codespell.toml" }
	lint.linters.shellcheck.args = { "--shell=bash", "--format=json", "-" }
	lint.linters.yamllint.args =
		{ "--config-file=" .. linterConfig .. "/yamllint.yaml", "--format=parsable", "-" }
	lint.linters.vale.args =
		{ "--output=JSON", "--ext=.md", "--no-exit", "--config=" .. linterConfig .. "/vale/vale.ini" }
	lint.linters.markdownlint.args = {
		"--disable=no-trailing-spaces", -- not disabled in config, so it's enabled for formatting
		"--disable=no-multiple-blanks",
		"--config=" .. linterConfig .. "/markdownlint.yaml",
	}
	lint.linters["editorconfig-checker"].args = {
		"-no-color",
		"-disable-max-line-length", -- only rule of thumb
		"-disable-trim-trailing-whitespace", -- will be formatted anyway
	}
end

local function lintTriggers()
	local function doLint()
		if vim.bo.buftype ~= "" then return end

		-- condition when to lint https://github.com/mfussenegger/nvim-lint/issues/370#issuecomment-1729671151
		local lintersToUse = require("lint").linters_by_ft[vim.bo.filetype]
		local hasNoSeleneConfig = vim.loop.fs_stat(vim.loop.cwd() .. "/selene.toml") == nil
		if hasNoSeleneConfig and vim.bo.filetype == "lua" then
			lintersToUse = vim.tbl_filter(function(l) return l ~= "selene" end, lintersToUse)
		end

		vim.defer_fn(function() require("lint").try_lint(lintersToUse) end, 1)
	end

	vim.api.nvim_create_autocmd({ "BufReadPost", "InsertLeave", "TextChanged", "FocusGained" }, {
		callback = doLint,
	})

	-- due to auto-save.nvim, we need the custom event "AutoSaveWritePost"
	-- instead of "BufWritePost" to trigger linting to prevent race conditions
	vim.api.nvim_create_autocmd("User", {
		pattern = "AutoSaveWritePost",
		callback = doLint,
	})

	doLint() -- run once on initialization
end

--------------------------------------------------------------------------------

local function formatterConfig()
	require("conform").setup { formatters_by_ft = formatters }

	-- stylua: ignore
	require("conform.formatters.bibtex-tidy").args = {
		"--quiet",
		"--tab", "--curly", "--strip-enclosing-braces", "--no-align", "--no-wrap",
		"--enclosing-braces=title,journal,booktitle", "--drop-all-caps",
		"--numeric", "--months", "--encode-urls",
		"--duplicates", "--sort-fields", "--remove-empty-fields", "--omit=month,issn,abstract",
	}
	require("conform.formatters.bibtex-tidy").condition = function(ctx)
		local ignore = vim.fs.basename(ctx.filename) == "main-bibliography.bib"
		if ignore then u.notify("conform.nvim", "Ignoring main-bibliography.bib") end
		return not ignore
	end

	require("conform.formatters.markdownlint").args = {
		"--fix",
		"--config=" .. linterConfig .. "/markdownlint.yaml",
		"$FILENAME",
	}
	require("conform.formatters.codespell").args = {
		"$FILENAME",
		"--write-changes",
		"--check-hidden", -- conform.nvim's temp file is hidden
		"--toml=" .. linterConfig .. "/codespell.toml",
	}
end

--------------------------------------------------------------------------------

return {
	{ -- Linter integration
		"chrisgrieser/nvim-lint", -- PENDING https://github.com/mfussenegger/nvim-lint/pull/377
		event = "VeryLazy",
		config = function()
			linterConfigs()
			lintTriggers()
		end,
	},
	{ -- Formatter integration
		"stevearc/conform.nvim",
		config = formatterConfig,
		cmd = "ConformInfo",
		keys = {
			{
				"<D-s>",
				function()
					require("conform").format { lsp_fallback = "always" }
					vim.cmd.update()
				end,
				mode = { "n", "x" },
				desc = "󰒕 Format & Save",
			},
		},
	},
	{ -- package manager
		"williamboman/mason.nvim",
		keys = {
			{ "<leader>pm", vim.cmd.Mason, desc = " Mason Home" },
		},
		opts = {
			ui = {
				border = u.borderStyle,
				height = 0.8, -- so it won't cover the statusline
				icons = { package_installed = "✓", package_pending = "󰔟", package_uninstalled = "✗" },
				-- consistent keymaps with lazy.nvim
				keymaps = {
					uninstall_package = "x",
					toggle_help = "?",
				},
			},
		},
	},
	{ -- auto-install missing linters & formatters
		"WhoIsSethDaniel/mason-tool-installer.nvim",
		event = "VeryLazy",
		keys = {
			{ "<leader>pM", vim.cmd.MasonToolsUpdate, desc = " Mason Update" },
		},
		dependencies = { "williamboman/mason.nvim", "williamboman/mason-lspconfig.nvim" },
		config = function()
			local myTools = toolsToAutoinstall(linters, formatters, debuggers, dontInstall)
			vim.list_extend(myTools, vim.g.myLsps)

			require("mason-tool-installer").setup {
				ensure_installed = myTools,
				run_on_start = false, -- triggered manually, since not working with lazy-loading
			}

			-- clean unused & install missing
			vim.defer_fn(vim.cmd.MasonToolsInstall, 500)
			vim.defer_fn(vim.cmd.MasonToolsClean, 1000) -- delayed, so noice.nvim is loaded before
		end,
	},
	{ -- add ignore-comments & lookup rules
		"chrisgrieser/nvim-rulebook",
		opts = {
			-- FIX lua_ls has indentation issue when used via code action
			ignoreComments = {
				["Lua Diagnostics."] = {
					comment = "---@diagnostic disable-next-line: %s",
					location = "prevLine",
				},
			},
		},
		keys = {
			{ "<leader>d", function() require("rulebook").lookupRule() end, desc = "󰒕 Lookup Rule" },
			{ "<leader>C", function() require("rulebook").ignoreRule() end, desc = "󰒕 Ignore Rule" },
		},
	},
}
