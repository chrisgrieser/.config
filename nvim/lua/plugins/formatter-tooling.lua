local u = require("config.utils")
--------------------------------------------------------------------------------

-- use formatting from conform.nvim
local ftToFormatter = {
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

---list of all tools that need to be auto-installed
---@param myFormatters object[]
---@return string[] tools
---@nodiscard
local function toolsToAutoinstall(myFormatters)
	-- formatters
	local notClis = { "trim_whitespace", "trim_newlines", "squeeze_blanks", "injected" }
	local formatters = vim.tbl_flatten(vim.tbl_values(myFormatters))
	formatters = vim.tbl_filter(function(f) return not vim.tbl_contains(notClis, f) end, formatters)

	-- dependencies of plugins (via lazy.nvim) -- PENDING https://github.com/folke/lazy.nvim/issues/1264
	local plugins = require("lazy").plugins() 
	local depsOfPlugins = vim.tbl_map(function(plugin) return plugin.extra_dependencies end, plugins)
	depsOfPlugins = vim.tbl_flatten(vim.tbl_values(depsOfPlugins))

	-- compile list
	local tools = vim.list_extend(depsOfPlugins, formatters)
	table.sort(tools)
	tools = vim.fn.uniq(tools)
	return tools
end

--------------------------------------------------------------------------------

local formatterConfig = {
	formatters_by_ft = ftToFormatter,
	formatters = {
		markdownlint = {
			prepend_args = { "--config=" .. vim.g.linterConfigFolder .. "/markdownlint.yaml" },
		},

		["bibtex-tidy"] = {
			-- stylua: ignore
			prepend_args = {
				"--tab", "--curly", "--strip-enclosing-braces", "--no-align", "--no-wrap",
				"--enclosing-braces=title,journal,booktitle", "--drop-all-caps",
				"---@diagnostic disable-line: unused-local", "--months", "--encode-urls",
				"--duplicates", "--sort-fields", "--remove-empty-fields", "--omit=month,issn,abstract",
			},
			condition = function(_, ctx)
				local biggerThan500Kb = vim.loop.fs_stat(ctx.filename).size > 500 * 1024
				if biggerThan500Kb then u.notify("conform.nvim", "Not formatting (file > 500kb).") end
				return not biggerThan500Kb
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
			require("conform.formatters.injected").options.ignore_errors = true
			require("conform").setup(formatterConfig)
		end,
		keys = {
			{ "<D-s>", formattingFunc, desc = "󰒕 Format & Save", mode = { "n", "x" } },
		},
	},
	{ -- package manager
		"williamboman/mason.nvim",
		init = function()
			-- system python is on 3.9, but some programs require 3.12 (e.g. autotools-ls)
			-- NOTE this has the drawback that `pynvim` cannot be installed anymore
			vim.g.python3_host_prog = vim.env.HOMEBREW_PREFIX .. "/bin/python3.12"
		end,
		keys = {
			{ "<leader>pm", vim.cmd.Mason, desc = " Mason" },
		},
		opts = {
			ui = {
				border = vim.g.myBorderStyle,
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
			require("mason-tool-installer").setup {
				ensure_installed = toolsToAutoinstall(ftToFormatter),
				run_on_start = false, -- manually, since otherwise not working with lazy-loading
			}
			vim.defer_fn(vim.cmd.MasonToolsInstall, 500)
			vim.defer_fn(vim.cmd.MasonToolsClean, 1000) -- delayed, so noice.nvim is loaded before
		end,
	},
}
