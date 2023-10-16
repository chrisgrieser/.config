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
	python = { "ruff_format", "ruff_fix" },
	yaml = { "prettier" },
	html = { "prettier" },
	markdown = { "markdown-toc", "markdownlint", "injected" },
	css = { "stylelint", "prettier" },
	sh = { "shellcheck", "beautysh", "squeeze_blanks", "trim_newlines" },
	bib = { "trim_whitespace", "bibtex-tidy" },
	["_"] = { "trim_whitespace", "trim_newlines", "squeeze_blanks" },
	["*"] = { "codespell" },
}

-- filetypes that should use lsp formatting
local lspFormatting = {
	"toml",
}

--------------------------------------------------------------------------------

local extraInstalls = {
	"debugpy", -- debugger
	"ruff", -- since ruff_format and ruff_fix aren't the real names
}

local dontInstall = {
	-- installed externally due to its plugins: https://github.com/williamboman/mason.nvim/issues/695
	"stylelint",
	-- not real formatters, but pseudo-formatters from conform.nvim
	"trim_whitespace",
	"trim_newlines",
	"squeeze_blanks",
	"injected",
	"ruff_format",
	"ruff_fix",
}

---given the linter- and formatter-list of nvim-lint and conform.nvim, extract a
---list of all tools that need to be auto-installed
---@param myLinters object[]
---@param myFormatters object[]
---@param extraTools string[]
---@param ignoreTools string[]
---@return string[] tools
---@nodiscard
local function toolsToAutoinstall(myLinters, myFormatters, extraTools, ignoreTools)
	-- get all linters, formatters, & extra tools and merge them into one list
	local linterList = vim.tbl_flatten(vim.tbl_values(myLinters))
	local formatterList = vim.tbl_flatten(vim.tbl_values(myFormatters))
	local tools = vim.list_extend(linterList, formatterList)
	vim.list_extend(tools, extraTools)

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
	lint.linters.shellcheck.args = { "--shell=bash", "--format=json", "--external-sources", "-" }
	lint.linters.yamllint.args =
		{ "--config-file=" .. linterConfig .. "/yamllint.yaml", "--format=parsable", "-" }
	lint.linters.vale.args =
		{ "--output=JSON", "--ext=.md", "--no-exit", "--config=" .. linterConfig .. "/vale/vale.ini" }
	lint.linters["editorconfig-checker"].args =
		{ "--no-color", "--config=" .. linterConfig .. "/editorconfig-checker-rc.json" }
	lint.linters.markdownlint.args = {
		"--disable=no-trailing-spaces", -- not disabled in config, so it's enabled for formatting
		"--disable=no-multiple-blanks",
		"--config=" .. linterConfig .. "/markdownlint.yaml",
	}
end

local function lintTriggers()
	local function doLint()
		vim.defer_fn(function()
			if vim.bo.buftype ~= "" then return end

			-- condition when to lint https://github.com/mfussenegger/nvim-lint/issues/370#issuecomment-1729671151
			local lintersToUse = require("lint").linters_by_ft[vim.bo.filetype]
			local pwd = vim.loop.cwd()
			if not pwd then return end
			local hasNoSeleneConfig = vim.loop.fs_stat(pwd .. "/selene.toml") == nil
			if hasNoSeleneConfig and vim.bo.filetype == "lua" then
				lintersToUse = vim.tbl_filter(function(l) return l ~= "selene" end, lintersToUse)
			end
			require("lint").try_lint(lintersToUse)
		end, 1)
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

	doLint() -- run on initialization
end

--------------------------------------------------------------------------------

local function formatterConfig()
	require("conform").setup {
		formatters_by_ft = formatters,
		formatters = {
			-- stylua: ignore
			["bibtex-tidy"] = {
				prepend_args =
					"--tab", "--curly", "--strip-enclosing-braces", "--no-align", "--no-wrap",
					"--enclosing-braces=title,journal,booktitle", "--drop-all-caps",
					"--numeric", "--months", "--encode-urls",
					"--duplicates", "--sort-fields", "--remove-empty-fields", "--omit=month,issn,abstract",

				condition = function(ctx)
					local ignore = vim.fs.basename(ctx.filename) == "main-bibliography.bib"
					if ignore then u.notify("conform.nvim", "Ignoring main-bibliography.bib") end
					return not ignore
				end,
			},
			markdownlint = {
				prepend_args = { "--config=" .. linterConfig .. "/markdownlint.yaml" },
			},
			codespell = {
				
				"--toml=" .. linterConfig .. "/codespell.toml",
			},
			injected = {
				-- errors in injected fields should not make the other formatters fail https://github.com/stevearc/conform.nvim/issues/111#issuecomment-1750658745
				options = { ignore_errors = true },
			},
		},
	}

	require("conform.formatters.codespell").args = {
		"$FILENAME",
		"--write-changes",
		"--check-hidden", -- conform.nvim's temp file is hidden
		"--toml=" .. linterConfig .. "/codespell.toml",
	}
	require("conform.formatters.beautysh").args = { "--force-function-style=fnonly", "--tab", "-" }
end

--------------------------------------------------------------------------------

return {
	{ -- Linter integration
		"mfussenegger/nvim-lint",
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
					if vim.tbl_contains(lspFormatting, vim.bo.filetype) then
						vim.lsp.buf.format()
					else
						require("conform").format { lsp_fallback = false }
					end
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
				height = 0.9,
				width = 0.8,
				icons = {
					package_installed = "✓",
					package_pending = "󰔟",
					package_uninstalled = "✗",
				},
				keymaps = { -- consistent keymaps with lazy.nvim
					uninstall_package = "x",
					toggle_help = "?",
					toggle_package_expand = "<Tab>",
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
			local myTools = toolsToAutoinstall(linters, formatters, extraInstalls, dontInstall)
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
		keys = {
			{
				"<leader>d",
				function() require("rulebook").lookupRule() end,
				desc = "󰒕 Lookup Rule",
			},
			{
				"<leader>C",
				function() require("rulebook").ignoreRule() end,
				desc = "󰒕 Ignore Rule",
			},
		},
	},
}
