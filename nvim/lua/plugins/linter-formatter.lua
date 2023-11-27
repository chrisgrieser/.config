--# selene: allow(mixed_table) -- lazy.nvim uses them
local u = require("config.utils")
local linterConfig = require("config.utils").linterConfigFolder
--------------------------------------------------------------------------------

local linters = {
	lua = { "selene" },
	css = { "stylelint" },
	sh = { "zsh", "shellcheck" },
	markdown = { "markdownlint", "vale" },
	python = { "pylint" },
	yaml = {},
	json = {},
	javascript = {},
	typescript = {},
	toml = {},
	applescript = {},
	bib = {},
}

for _, list in pairs(linters) do
	table.insert(list, "typos")
	table.insert(list, "editorconfig-checker")
end

local formatters = {
	javascript = { "biome" },
	typescript = { "biome" },
	json = { "biome" },
	lua = { "stylua", "ast-grep" },
	python = { "ruff_format", "ruff_fix" },
	markdown = { "markdown-toc", "markdownlint", "injected" },
	css = { "stylelint", "prettier" },
	sh = { "shellcheck", "shfmt" },
	bib = { "trim_whitespace", "bibtex-tidy" },
	["_"] = { "trim_whitespace", "trim_newlines", "squeeze_blanks" }, -- filetypes w/o formatter
	["*"] = { "typos" }, -- all filetypes
}

-- filetypes that should use lsp-formatting (after the formatters)
local lspFormatting = {
	"toml",
	"yaml",
	"html",
}

--------------------------------------------------------------------------------

local extraInstalls = {
	"debugpy", -- debugger
	"ruff", -- since ruff_format and ruff_fix aren't the real names
}

local dontInstall = {
	"stylelint", -- installed externally due to its plugins: https://github.com/williamboman/mason.nvim/issues/695
	"zsh", -- builtin
	"trim_whitespace", -- not real formatters, but pseudo-formatters from conform.nvim
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
local function toolsToAutoinstall(myLinters, myFormatters, myLsps, extraTools, ignoreTools)
	-- get all linters, formatters, & extra tools and merge them into one list
	local linterList = vim.tbl_flatten(vim.tbl_values(myLinters))
	local formatterList = vim.tbl_flatten(vim.tbl_values(myFormatters))
	local tools = vim.list_extend(linterList, formatterList)
	vim.list_extend(tools, myLsps)
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

	lint.linters.shellcheck.args = { "--shell=bash", "--format=json", "--external-sources", "-" }
	lint.linters.vale.args =
		{ "--output=JSON", "--ext=.md", "--no-exit", "--config=" .. linterConfig .. "/vale/vale.ini" }
	lint.linters["editorconfig-checker"].args =
		{ "--no-color", "--config=" .. linterConfig .. "/editorconfig-checker-rc.json" }
	lint.linters.markdownlint.args = {
		"--disable=no-trailing-spaces", -- not disabled in config, so it's enabled for formatting
		"--disable=no-multiple-blanks",
		"--config=" .. linterConfig .. "/markdownlint.yaml",
	}
	-- PENDING https://github.com/mfussenegger/nvim-lint/pull/474
	lint.linters.typos.args = {
		"--format=json",
		"--force-exclude", -- so excluded files from `typos.toml` are still linted
	}
	lint.linters.typos.stdin = false -- so filenames are available
end

local function lintTriggers()
	local function doLint()
		vim.defer_fn(function()
			if vim.bo.buftype ~= "" then return end

			-- GUARD only when in lua, only lint when selene file available
			-- https://github.com/mfussenegger/nvim-lint/issues/370#issuecomment-1729671151
			if vim.bo.ft == "lua" then
				local noSeleneConfig = vim.loop.fs_stat((vim.loop.cwd() or "") .. "/selene.toml") == nil
				if noSeleneConfig then
					local luaLinters = require("lint").linters_by_ft.lua
					local noSelene = vim.tbl_filter(
						function(linter) return linter ~= "selene" end,
						luaLinters
					)
					require("lint").try_lint(noSelene)
					return
				end
			end

			require("lint").try_lint()
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

local formatterConfig = {
	formatters_by_ft = formatters,
	formatters = {
		markdownlint = {
			prepend_args = { "--config=" .. linterConfig .. "/markdownlint.yaml" },
		},
		-- stylua: ignore
		["bibtex-tidy"] = {
			prepend_args =
				"--tab", "--curly", "--strip-enclosing-braces", "--no-align", "--no-wrap",
				"--enclosing-braces=title,journal,booktitle", "--drop-all-caps",
				"--numeric", "--months", "--encode-urls",
				"--duplicates", "--sort-fields", "--remove-empty-fields", "--omit=month,issn,abstract",
			condition = function(ctx)
				local ignore = vim.fs.basename(ctx.filename) == "main-bibliography.bib"
				if ignore then u.notify("conform.nvim", "Ignoring main-bibliography.bib.") end
				return not ignore
			end,
		},
		-- PENDING https://github.com/stevearc/conform.nvim/pull/219
		typos = {
			stdin = false,
			args = {
				"--write-changes",
				"--force-exclude",
				"$FILENAME",
			},
		},
	},
}

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
		opts = formatterConfig,
		cmd = "ConformInfo",
		keys = {
			{
				"<D-s>",
				function()
					local useLsp = vim.tbl_contains(lspFormatting, vim.bo.ft) and "always" or false
					require("conform").format {
						lsp_fallback = useLsp,
						async = false,
						callback = vim.cmd.update,
					}
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
				height = 0.8, -- so statusline is still visible
				width = 0.8,
				icons = {
					package_installed = "✓",
					package_pending = "󰔟",
					package_uninstalled = "✗",
				},
				keymaps = { -- consistent with keymaps for lazy.nvim
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
			local myTools =
				toolsToAutoinstall(linters, formatters, vim.g.myLsps, extraInstalls, dontInstall)

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
