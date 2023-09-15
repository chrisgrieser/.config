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
	text = {},
	applescript = {},
	bib = {},
}

-- PENDING https://github.com/mfussenegger/nvim-lint/issues/355
for ft, _ in pairs(linters) do
	table.insert(linters[ft], "codespell")
end

local formatters = {
	javascript = { "biome" },
	typescript = { "biome" },
	json = { "biome" },
	jsonc = { "biome" },
	lua = { "stylua" },
	python = { "black" },
	yaml = { "prettierd" },
	html = { "prettierd" },
	markdown = { "markdownlint" },
	css = { "stylelint", "prettierd" },
	sh = { "shellcheck" },
	bib = { "trim_whitespace", "bibtex-tidy" },
	applescript = { "trim_whitespace", "trim_newlines" },
	["*"] = { "codespell" }, -- ignores .bib and .css via codespell config
}

local debuggers = { "debugpy" }

local dontInstall = {
	"stylelint", -- stylelint included in mason, but not its plugins: https://github.com/williamboman/mason.nvim/issues/695
	"trim_whitespace", -- not a real formatter
	"trim_newlines", -- not a real formatter
}

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

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

---uninstalls non-LSP tools
---@param toolsToKeep string[]
local function autoUninstall(toolsToKeep)
	local installedTools = require("mason-registry").get_installed_packages()
	local toUninstall = vim.tbl_filter(function(t)
		local toKeep = vim.tbl_contains(toolsToKeep, t.name)
		local isLsp = vim.tbl_contains(t.spec.categories, "LSP")
		return not (toKeep or isLsp)
	end, installedTools)

	for _, tool in ipairs(toUninstall) do
		u.notify("mason.nvim", "Cleaning up: " .. tool.name)
		tool:uninstall()
	end
end

--------------------------------------------------------------------------------

local function linterConfigs()
	local lint = require("lint")
	lint.linters_by_ft = linters

	lint.linters.vale.args = {
		"--output=JSON",
		"--ext=.md",
		"--config",
		linterConfig .. "/vale/vale.ini",
	}

	lint.linters.codespell.args = {
		"--toml",
		linterConfig .. "/codespell.toml",
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
end

local function lintTriggers()
	local function doLint() vim.defer_fn(require("lint").try_lint, 1) end

	vim.api.nvim_create_autocmd({ "BufReadPost", "InsertLeave", "TextChanged", "FocusGained" }, {
		callback = doLint,
	})

	-- due to auto-save.nvim, we need the custom event "AutoSaveWritePost"
	-- instead of "BufWritePost" to trigger linting to prevent race conditions
	vim.api.nvim_create_autocmd("User", {
		pattern = "AutoSaveWritePost",
		callback = doLint,
	})

	-- run once on initialization
	doLint()
end

--------------------------------------------------------------------------------

local formatterConfig = {
	log_level = vim.log.levels.DEBUG,
	formatters_by_ft = formatters,

	formatters = {
		shellcheck = {
			command = "shellcheck",
			args = "$FILENAME --shell=bash --format=diff | patch -p1 $FILENAME",
			stdin = false,
		},
		markdownlint = {
			command = "markdownlint",
			stdin = false,
			args = { "--fix", "--config", linterConfig .. "/markdownlint.yaml", "$FILENAME" },
		},
		codespell = {
			command = "codespell",
			stdin = false,
			args = {
				"$FILENAME",
				"--write-changes",
				"--check-hidden", -- conform.nvim's temp file is hidden
				"--toml",
				linterConfig .. "/codespell.toml",
			},
		},
		["bibtex-tidy"] = {
			command = "bibtex-tidy",
			stdin = true,
			args = {
				"--quiet",
				"--omit=month,issn,abstract",
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
			-- main bibliography too big
			condition = function(ctx) return vim.fs.basename(ctx.filename) ~= "main-bibliography.bib" end,
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
			local myTools = toolsToAutoinstall(linters, formatters, debuggers, dontInstall)

			-- triggered myself, since `run_on_start`, does not work w/ lazy-loading
			require("mason-tool-installer").setup {
				ensure_installed = myTools,
				run_on_start = false,
			}
			vim.defer_fn(function()
				vim.cmd.MasonToolsInstall()
				autoUninstall(myTools)
			end, 1000)
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
		branch = "stevearc-run-with-tty",
		opts = formatterConfig,
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
}
