local u = require("config.utils")
local linterConfig = require("config.utils").linterConfigFolder
--------------------------------------------------------------------------------

local linters = {
	lua = {},
	css = { "stylelint" },
	sh = { "shellcheck" },
	markdown = { "vale" }, -- PENDING https://github.com/errata-ai/vale-ls/issues/8
	python = {},
	yaml = {},
	json = {},
	javascript = {},
	typescript = {},
	toml = {},
	applescript = {},
	bib = {},
}

for _, list in pairs(linters) do
	table.insert(list, "editorconfig-checker")
end

local formatters = {
	javascript = { "biome" },
	typescript = { "biome" },
	json = { "biome" },
	lua = { "stylua", "ast-grep" },
	python = { "ruff_fix" },
	markdown = { "markdown-toc", "markdownlint", "injected" },
	css = { "stylelint", "squeeze_blanks" },
	sh = { "shellcheck", "shfmt" },
	bib = { "trim_whitespace", "bibtex-tidy" },
	["_"] = { "trim_whitespace", "trim_newlines", "squeeze_blanks" }, -- filetypes w/o formatter
	["*"] = { "typos" },
}

local lspFormattingFiletypes = {
	"toml",
	"yaml",
	"html",
	"python",
	"css",
}

--------------------------------------------------------------------------------

local extraInstalls = {
	"debugpy", -- debugger
	"ruff", -- since ruff_format and ruff_fix aren't the real names
	{ "jedi-language-server", version = "0.41.0" }, -- PENDING https://github.com/pappasam/jedi-language-server/issues/296
}

local dontInstall = {
	"jedi-language-server", -- PENDING https://github.com/pappasam/jedi-language-server/issues/296
	"stylelint", -- installed externally due to its plugins: https://github.com/williamboman/mason.nvim/issues/695
	"trim_whitespace", -- not real formatters, but pseudo-formatters from conform.nvim
	"trim_newlines",
	"squeeze_blanks",
	"injected",
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

	-- only unique tools
	table.sort(tools)
	tools = vim.fn.uniq(tools)

	-- exceptions & extras
	tools = vim.tbl_filter(function(tool) return not vim.tbl_contains(ignoreTools, tool) end, tools)
	vim.list_extend(tools, extraTools)
	return tools
end

--------------------------------------------------------------------------------

local function linterConfigs()
	local lint = require("lint")
	lint.linters_by_ft = linters

	lint.linters.shellcheck.args = { "--shell=bash", "--format=json", "--external-sources", "-" }
	lint.linters["editorconfig-checker"].args =
		{ "--no-color", "--config=" .. linterConfig .. "/editorconfig-checker-rc.json" }
	vim.env.VALE_CONFIG_PATH = u.linterConfigFolder .. "/vale/vale.ini"
end

local function lintTriggers()
	local function doLint()
		if vim.bo.buftype ~= "" then return end
		require("lint").try_lint()
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

		-- PENDING https://github.com/mason-org/mason-registry/pull/3671
		biome = {
			stdin = false,
			args = { "format", "--write", "$FILENAME" },
		},

		-- stylua: ignore
		["bibtex-tidy"] = {
			prepend_args = {
				"--tab", "--curly", "--strip-enclosing-braces", "--no-align", "--no-wrap",
				"--enclosing-braces=title,journal,booktitle", "--drop-all-caps",
				"--numeric", "--months", "--encode-urls",
				"--duplicates", "--sort-fields", "--remove-empty-fields", "--omit=month,issn,abstract",
			},
			condition = function(ctx)
				local biggerThan500Kb = vim.loop.fs_stat(ctx.filename).size > 500 * 1024;
				if biggerThan500Kb then u.notify("conform.nvim", "Not formatting (file > 500kb).") end
				return not biggerThan500Kb
			end,
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
					local useLsp = vim.tbl_contains(lspFormattingFiletypes, vim.bo.ft) and "always"
						or false
					require("conform").format {
						lsp_fallback = useLsp,
						async = false,
						callback = vim.cmd.update,
					}
				end,
				desc = "󰒕 Format & Save",
			},
			{
				"<D-s>",
				function()
					vim.opt.formatexpr = "v:lua.require'conform'.formatexpr()"
					vim.cmd.normal { "gq", bang = true }
					vim.cmd.update()
				end,
				desc = "󰒕 Format Selection & Save",
				mode = "x",
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
		dependencies = "williamboman/mason.nvim",
		config = function()
			local lsps = vim.tbl_values(vim.g.lspToMasonMap)
			local myTools = toolsToAutoinstall(linters, formatters, lsps, extraInstalls, dontInstall)

			require("mason-tool-installer").setup {
				ensure_installed = myTools,
				run_on_start = false, -- manually, since otherwise not working with lazy-loading
			}
			vim.defer_fn(vim.cmd.MasonToolsInstall, 500)
			vim.defer_fn(vim.cmd.MasonToolsClean, 1000) -- delayed, so noice.nvim is loaded before
		end,
	},
	{ -- add ignore-comments & lookup rules
		"chrisgrieser/nvim-rulebook",
		keys = {
			-- stylua: ignore start
			{ "<leader>d", function() require("rulebook").lookupRule() end, desc = "󰒕 Lookup Rule" },
			{ "<leader>C", function() require("rulebook").ignoreRule() end, desc = "󰒕 Ignore Rule" },
			-- stylua: ignore end
		},
	},
}
