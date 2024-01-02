local u = require("config.utils")
local linterConfig = require("config.utils").linterConfigFolder
--------------------------------------------------------------------------------

-- use formatting from conform.nvim
local formatters = {
	applescript = { "trim_whitespace", "trim_newlines", "squeeze_blanks" },
	lua = { "stylua" },
	markdown = { "markdown-toc", "markdownlint", "injected" },
	sh = { "shellcheck", "shfmt" },
	bib = { "trim_whitespace", "bibtex-tidy" },
	css = { "squeeze_blanks" }, -- since the css formatter does not support that
	["*"] = { "typos" },
}
-- use formatting from the LSP
local lspFormatFt = {
	"javascript",
	"typescript",
	"json",
	"toml",
	"yaml",
	"html",
	"python",
	"css",
}

-- use auto-indenting as poor man's formatter
local autoIndentFt = {
	"query",
	"applescript",
}

--------------------------------------------------------------------------------

local dependencies = {
	"debugpy", -- nvim-dap-python
	"shellcheck", -- bash-lsp/efm, PENDING https://github.com/bash-lsp/bash-language-server/issues/663
	"markdownlint", -- efm
	"pynvim", -- semshi
}

-- not real formatters, but pseudo-formatters from conform.nvim
local dontInstall = {
	"trim_whitespace",
	"trim_newlines",
	"squeeze_blanks",
	"injected",
}

---list of all tools that need to be auto-installed
---@param myFormatters object[]
---@param extraTools string[]
---@param ignoreTools string[]
---@return string[] tools
---@nodiscard
local function toolsToAutoinstall(myFormatters, myLsps, extraTools, ignoreTools)
	-- get all lsps, formatters, & extra tools and merge them into one list
	local formatterList = vim.tbl_flatten(vim.tbl_values(myFormatters))
	local tools = vim.list_extend(myLsps, formatterList)

	-- only unique tools
	table.sort(tools)
	tools = vim.fn.uniq(tools)

	-- exceptions & extras
	tools = vim.tbl_filter(function(tool) return not vim.tbl_contains(ignoreTools, tool) end, tools)
	vim.list_extend(tools, extraTools)
	return tools
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
			prepend_args = {
				"--tab", "--curly", "--strip-enclosing-braces", "--no-align", "--no-wrap",
				"--enclosing-braces=title,journal,booktitle", "--drop-all-caps",
				"end", "--months", "--encode-urls",
				"--duplicates", "--sort-fields", "--remove-empty-fields", "--omit=month,issn,abstract",
			},
			condition = function(self, ctx) ---@diagnostic disable-line: unused-local
				local biggerThan500Kb = vim.loop.fs_stat(ctx.filename).size > 500 * 1024;
				if biggerThan500Kb then
					u.notify("conform.nvim", "Not formatting (file > 500kb).")
					return false
				end
				return true
			end,
		},
	},
}

local function formattingFunc()
	-- HACK since `fixAll` is not part of ruff-lsp formatting capabilities
	-- PENDING https://github.com/astral-sh/ruff-lsp/issues/335
	local function pythonRuffFixall()
		if vim.bo.ft == "python" then
			vim.lsp.buf.code_action { apply = true, context = { only = { "source.fixAll.ruff" } } }
		end
	end

	-- PENDING https://github.com/stevearc/conform.nvim/issues/255
	if vim.tbl_contains(autoIndentFt, vim.bo.ft) then u.normal("gg=G``") end

	local useLsp = vim.tbl_contains(lspFormatFt, vim.bo.ft) and "always" or false
	require("conform").format({ lsp_fallback = useLsp }, pythonRuffFixall)
end

--------------------------------------------------------------------------------

return {
	{ -- Formatter integration
		"stevearc/conform.nvim",
		cmd = "ConformInfo",
		config = function()
			-- FIX silence injected formatter
			require("conform.formatters.injected").options.ignore_errors = true

			require("conform").setup(formatterConfig)
		end,
		keys = {
			{ "<D-s>", formattingFunc, desc = "󰒕 Format & Save", mode = { "n", "x" } },
		},
	},
	{ -- package manager
		"williamboman/mason.nvim",
		keys = {
			{ "<leader>pm", vim.cmd.Mason, desc = " Mason" },
		},
		opts = {
			-- PENDING https://github.com/mason-org/mason-registry/pull/3926
			registries = {
				"github:chrisgrieser/mason-registry", -- only has pynvim
				"github:mason-org/mason-registry",
			},
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
	{ -- auto-install lsps & formatters
		"WhoIsSethDaniel/mason-tool-installer.nvim",
		event = "VeryLazy",
		dependencies = "williamboman/mason.nvim",
		config = function()
			local lsps = vim.tbl_values(vim.g.lspToMasonMap)
			local myTools = toolsToAutoinstall(formatters, lsps, dependencies, dontInstall)

			require("mason-tool-installer").setup {
				ensure_installed = myTools,
				run_on_start = false, -- manually, since otherwise not working with lazy-loading
			}
			vim.defer_fn(vim.cmd.MasonToolsInstall, 500)
			vim.defer_fn(vim.cmd.MasonToolsClean, 1000) -- delayed, so noice.nvim is loaded before
		end,
	},
}
