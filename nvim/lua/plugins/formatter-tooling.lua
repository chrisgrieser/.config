local u = require("config.utils")
local linterConfig = require("config.utils").linterConfigFolder
--------------------------------------------------------------------------------

local formatters = {
	javascript = { "biome" },
	typescript = { "biome" },
	applescript = { "trim_whitespace", "trim_newlines", "squeeze_blanks" },
	json = { "biome" },
	lua = { "stylua" },
	markdown = { "markdown-toc", "markdownlint", "injected" },
	sh = { "shellcheck", "shfmt" },
	bib = { "trim_whitespace", "bibtex-tidy" },
	["*"] = { "typos" },
}

local lspFormatFiletypes = {
	"toml",
	"yaml",
	"html",
	"python",
	"css",
}

--------------------------------------------------------------------------------

local extraInstalls = {
	"debugpy",
	"shellcheck", -- needed by bash-lsp
	{ "jedi-language-server", version = "0.41.0" }, -- PENDING https://github.com/pappasam/jedi-language-server/issues/296
}

local dontInstall = {
	"jedi-language-server", -- PENDING https://github.com/pappasam/jedi-language-server/issues/296
	"trim_whitespace", -- not real formatters, but pseudo-formatters from conform.nvim
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
			condition = function(self, ctx) ---@diagnostic disable-line: unused-local
				local biggerThan500Kb = vim.loop.fs_stat(ctx.filename).size > 500 * 1024;
				if biggerThan500Kb then u.notify("conform.nvim", "Not formatting (file > 500kb).") end
				return not biggerThan500Kb
			end,
		},
	},
}

--------------------------------------------------------------------------------

return {
	{ -- Formatter integration
		"stevearc/conform.nvim",
		opts = formatterConfig,
		cmd = "ConformInfo",
		keys = {
			{
				"<D-s>",
				function()
					local useLsp = vim.tbl_contains(lspFormatFiletypes, vim.bo.ft) and "always" or false
					require("conform").format({ lsp_fallback = useLsp }, function()
						-- HACK since `fixAll` is not part of ruff-lsp formatting capabilities
						-- PENDING https://github.com/astral-sh/ruff-lsp/issues/335
						if vim.bo.ft == "python" then
							vim.lsp.buf.code_action {
								apply = true,
								context = { only = { "source.fixAll.ruff" } },
							}
						end
					end)
				end,
				desc = "󰒕 Format & Save",
				mode = { "n", "x" },
			},
		},
	},
	{ -- package manager
		"williamboman/mason.nvim",
		keys = {
			{ "<leader>pm", vim.cmd.Mason, desc = " Mason Home" },
		},
		opts = {
			registries = {
				"github:mason-org/mason-registry",
				"github:chrisgrieser/mason-registry",
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
		keys = {
			{ "<leader>pM", vim.cmd.MasonToolsUpdate, desc = " Mason Update" },
		},
		dependencies = "williamboman/mason.nvim",
		config = function()
			local lsps = vim.tbl_values(vim.g.lspToMasonMap)
			local myTools = toolsToAutoinstall(formatters, lsps, extraInstalls, dontInstall)

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
