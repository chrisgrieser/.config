local linterConfig = require("config.utils").linterConfigFolder

local linters = {
	lua = { "selene", "codespell" },
	css = { "stylelint" },
	sh = { "shellcheck", "codespell" },
	markdown = { "markdownlint", "vale" },
	yaml = { "yamllint", "codespell" },
	python = { "pylint", "codespell" },
	gitcommit = { "codespell" },
	json = { "codespell" },
	javascript = { "codespell" },
	typescript = { "codespell" },
	toml = { "codespell" },
	text = { "codespell" },
	applescript = { "codespell" },
}
-- teh

local formatters = {
	javascript = { "biome" },
	typescript = { "biome" },
	json = { "biome" },
	jsonc = { "biome" },
	lua = { "stylua" },
	python = { "black" },
	yaml = { "prettier" },
	html = { "prettier" },
	markdown = { "markdownlint" },
	css = { "stylelint", "prettier" },
	sh = { "shfmt", "shellharden" },
	bib = { "trim_whitespace", "bibtex-tidy" },
	applescript = { "trim_whitespace", "trim_newlines" },
	["*"] = { "codespell" }, -- ignores .bib and .css via codespell config
}

local debuggers = {
	"debugpy",
}

local dontInstall = {
	"shellharden", -- cannot be installed via mason: https://github.com/williamboman/mason.nvim/issues/1481
	"stylelint", -- stylelint included in mason, but not its plugins: https://github.com/williamboman/mason.nvim/issues/695
	"trim_whitespace", -- not a real formatter
	"trim_newlines", -- not a real formatter
}

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

---@param myLinters object[]
---@param myFormatters object[]
---@param myDebuggers string[]
---@param ignoreTools string[]
---@return string[] tools
---@nodiscard
local function toolsToAutoinstall(myLinters, myFormatters, myDebuggers, ignoreTools)
	-- get all linters & formatters
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

	lint.linters.vale.args = {
		"--output=JSON",
		"--ext=.md",
		"--config",
		linterConfig .. "/vale/vale.ini",
	}

	lint.linters.codespell.args = {
		"--ignore-words",
		"--check-hidden",
		linterConfig .. "/codespell-ignore.txt",
		"--builtin=rare,clear,informal,code,names,en-GB_to_en-US",
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
	vim.api.nvim_create_autocmd({ "BufReadPost", "InsertLeave", "TextChanged", "FocusGained" }, {
		callback = function() vim.defer_fn(require("lint").try_lint, 1) end,
	})

	-- due to auto-save.nvim, we need the custom event "AutoSaveWritePost"
	-- instead of "BufWritePost" to trigger linting to prevent race conditions
	vim.api.nvim_create_autocmd("User", {
		pattern = "AutoSaveWritePost",
		callback = function() require("lint").try_lint() end,
	})
	-- run once on initialization
	require("lint").try_lint()
end

--------------------------------------------------------------------------------

local formatterConfig = {
	formatters_by_ft = formatters,

	formatters = {
		-- PENDING https://github.com/stevearc/conform.nvim/issues/44
		-- shellcheck = {
		-- 	command = "shellcheck",
		-- 	-- Using `git apply` is the officially recommended way for auto-fixing
		-- 	-- https://github.com/koalaman/shellcheck/issues/1220#issuecomment-594811243
		-- 	arg = "--shell=bash --format=diff '$FILENAME' | git apply",
		-- 	stdin = false,
		-- },
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
				"--builtin=rare,clear,informal,code,names,en-GB_to_en-US",
				"--check-hidden", -- conform.nvim's temp file is hidden
				"--ignore-words",
				linterConfig .. "/codespell-ignore.txt",
			},
			-- don't run on css or bib files
			condition = function(ctx)
				local name = ctx.filename
				return not (vim.endswith(name, ".css") or vim.endswith(name, ".bib"))	
			end,
		},
		["bibtex-tidy"] = {
			command = "bibtex-tidy",
			stdin = true,
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
			require("mason-tool-installer").setup { ensure_installed = myTools, run_on_start = false }
			vim.defer_fn(vim.cmd.MasonToolsInstall, 1000)
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
