local linterConfig = require("config.utils").linterConfigFolder
--------------------------------------------------------------------------------

local toolsToAutoinstall = {
	"debugpy", -- just here to install ensure auto-install
	"codespell",
	"yamllint",
	"shellcheck",
	"shfmt",
	"markdownlint",
	"vale",
	"black",
	"selene",
	"stylua",
	"pylint",
	"bibtex-tidy",
	"prettier", -- only yaml formatter preserving blank lines https://github.com/mikefarah/yq/issues/515
	-- INFO stylelint included in mason, but not its plugins, which then cannot be found https://github.com/williamboman/mason.nvim/issues/695
}

--------------------------------------------------------------------------------

local function linterConfigs()
	local lint = require("lint")
	local linters = require("lint").linters
	lint.linters_by_ft = {
		lua = { "selene" },
		css = { "stylelint" },
		sh = { "shellcheck" },
		zsh = { "shellcheck" },
		markdown = { "markdownlint", "vale" },
		yaml = { "yamllint" },
		python = { "pylint" },
		json = {},
		javascript = {},
		typescript = {},
		gitcommit = {},
		toml = {},
	}

	-- use for codespell/cspell for all except bib and css
	for ft, _ in pairs(lint.linters_by_ft) do
		if ft ~= "bib" and ft ~= "css" then table.insert(lint.linters_by_ft[ft], "codespell") end
	end

	linters.vale.args = {
		"--output=JSON",
		"--ext=.md",
		"--config",
		linterConfig .. "/vale/vale.ini",
	}

	linters.codespell.args = {
		"--ignore-words",
		linterConfig .. "/codespell-ignore.txt",
		"--builtin=rare,clear,informal,code,names,en-GB_to_en-US",
	}

	linters.shellcheck.args = {
		"--shell=bash", -- force to work with zsh
		"--format=json",
		"-",
	}

	linters.yamllint.args = {
		"--config-file",
		linterConfig .. "/yamllint.yaml",
		"--format=parsable",
		"-",
	}

	linters.markdownlint.args = {
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
	-- run once on start
	require("lint").try_lint()
end

--------------------------------------------------------------------------------

local formatterConfig = {
	log_level = vim.log.levels.DEBUG,
	formatters_by_ft = {
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
		bib = { "bibtex_tidy" },
		["*"] = { "codespell" },
	},

	-- custom formatters
	formatters = {
		-- PENDING https://github.com/stevearc/conform.nvim/issues/44
		-- shellcheck = {
		-- 	command = "shellcheck",
		-- 	-- Using `git apply` is the officially recommended way for auto-fixing
		-- 	-- https://github.com/koalaman/shellcheck/issues/1220#issuecomment-594811243
		-- 	arg = "--shell=bash --format=diff '$FILENAME' | git apply",
		-- 	stdin = false,
		-- },
		-- PENDING https://github.com/stevearc/conform.nvim/pull/45
		biome = {
			command = "biome",
			stdin = true,
			args = { "format", "--stdin-file-path", "$FILENAME" },
		},
		stylelint = {
			command = "stylelint",
			args = { "--stdin", "--fix" },
			stdin = true,
		},
		markdownlint = {
			command = "markdownlint",
			stdin = false,
			args = { "--fix", "--config", linterConfig .. "/markdownlint.yaml", "$FILENAME" },
		},
		--------------------------------------------------------------------------
		codespell = {
			command = "codespell",
			stdin = false,
			args = {
				"$FILENAME",
				"--write-changes",
				"--builtin=rare,clear,informal,code,names,en-GB_to_en-US",
				"--check-hidden", -- conform temp file is hidden
				"--ignore-words",
				linterConfig .. "/codespell-ignore.txt",
			},
			-- don't run on css or bib files
			condition = function(ctx)
				return not (ctx.filename:find("%.css$") or ctx.filename:find("%.bib$"))
			end,
		},
		bibtex_tidy = {
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
		opts = formatterConfig,
		cmd = "ConformInfo",
		keys = {
			{
				"<D-s>",
				function()
					require("conform").format { lsp_fallback = true }
					vim.cmd.update()
				end,
				mode = { "n", "x" },
				desc = "󰒕 Format & Save",
			},
		},
	},
}
