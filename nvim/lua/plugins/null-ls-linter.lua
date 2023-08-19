-- https://github.com/jose-elias-alvarez/null-ls.nvim/blob/main/doc/BUILTIN_CONFIG.md
--------------------------------------------------------------------------------

local linterConfig = require("config.utils").linterConfigFolder
local lintersAndFormatters = {
	"yamllint", -- only for diagnostics, not for formatting
	"shellcheck", -- needed for bash-lsp
	"shfmt", -- shell
	"markdownlint",
	"cbfmt", -- use other linters to format codeblocks in markdown
	"black", -- python formatter
	"vale", -- natural language
	"codespell", -- superset of `misspell`, therefore only using codespell
	"selene", -- lua
	"stylua", -- lua
	"prettier", -- only used for yaml and html https://github.com/mikefarah/yq/issues/515
	"rome", -- also an LSP; the lsp does diagnostics, the CLI via null-ls does formatting
	-- stylelint included in mason, but not its plugins, which then cannot be found https://github.com/williamboman/mason.nvim/issues/695
}
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
local function nullSources()
	local builtins = require("null-ls").builtins
	return {
		-- GLOBAL
		builtins.formatting.codespell.with {
			disabled_filetypes = { "css", "bib", "gitignore" },
			extra_args = { "--ignore-words", linterConfig .. "/codespell-ignore.txt" },
		},

		-- PYTHON
		builtins.formatting.black,

		-- SHELL
		builtins.formatting.shfmt.with {
			extra_filetypes = { "zsh" },
		},

		-- JS/TS/JSON
		builtins.formatting.rome, -- not available via LSP yet

		-- CSS
		builtins.formatting.stylelint.with {
			-- using config without ordering, since automatic re-ordering can be
			-- confusing. Config with stylelint-order is only run on build.
			extra_args = { "--config", linterConfig .. "/stylelintrc-formatting.yml" },
			timeout = 15000, -- longer timeout for large css files
		},

		-- LUA
		builtins.formatting.stylua,

		-- PRETTIER: YAML/HTML
		-- INFO use only for yaml/html, since rome handles the rest
		builtins.formatting.prettier.with {
			filetypes = { "yaml", "html" },
		},

		-- MARKDOWN & PROSE
		builtins.formatting.markdownlint.with {
			extra_args = { "--config", linterConfig .. "/markdownlintrc" },
		},
	}
end
--------------------------------------------------------------------------------

local function linterConfigs()
	local lint = require("lint")
	lint.linters_by_ft = {
		lua = { "selene", "codespell" },
		css = { "stylelint", "codespell" },
		sh = { "shellcheck", "codespell" },
		zsh = { "shellcheck", "codespell" },
		markdown = { "vale", "markdownlint", "codespell" },
		yaml = { "yamllint", "codespell" },
		json = { "codespell" },
		javascript = { "codespell" },
		typescript = { "codespell" },
		gitcommit = { "codespell" },
		toml = { "codespell" },
		python = { "codespell" },
	}
	-- "BufWritePost" relevant due to nvim-autosave
	vim.api.nvim_create_autocmd({ "BufReadPost", "BufWritePost", "InsertLeave", "TextChanged" }, {
		callback = function() lint.try_lint() end,
	})

	local function get_cur_file_extension(bufnr)
		bufnr = bufnr or 0
		return "." .. vim.fn.fnamemodify(vim.api.nvim_buf_get_name(bufnr), ':e')
	end

	-- Linter configs
	-- https://github.com/mfussenegger/nvim-lint/tree/master/lua/lint/linters
	lint.linters.codespell.args = { "--ignore-words", linterConfig .. "/codespell-ignore.txt" }
	lint.linters.markdownlint.args = { "--config", linterConfig .. "/markdownlintrc" }
	lint.linters.vale.args = {
		'--no-exit',
		'--output', 'JSON',
		'--ext', get_cur_file_extension
		"--config",
		linterConfig .. "/vale/vale.ini",
	}
	lint.linters.shellcheck.args = {
		"--shell", "bash", -- force to work with zsh
		'--format', 'json',
		'-',
	}
	lint.linters.yamllint.args = {
		"--config-file",
		linterConfig .. "/yamllint.yaml",
		'--format', 
		'parsable', 
		'-'
	}
	lint.linters.stylelint.args = {
		"-f",
		"json",
		"--quiet",
		-- "--config",
		-- linterConfig .. "/stylelintrc.yml",
		"--stdin",
		"--stdin-filename",
		function() return vim.fn.expand("%:p") end,
	} 
end


local function formatterConfigs() 
		-- https://github.com/mhartington/formatter.nvim/tree/master/lua/formatter/filetypes
	-- Provides the Format, FormatWrite, FormatLock, and FormatWriteLock commands
	require("formatter").setup {
	filetype = {
		-- Formatter configurations for filetype "lua" go here
		-- and will be executed in order
		lua = {
			require("formatter.filetypes.lua").stylua,
		},
		sh = {
			require("formatter.filetypes.sh").stylua,
		},
	}
	}
end
	

--------------------------------------------------------------------------------

return {
	{
		"jayp0521/mason-null-ls.nvim",
		enabled = false,
		opts = { ensure_installed = lintersAndFormatters },
	},
	{
		"mfussenegger/nvim-lint",
		event = "VeryLazy",
		config = linterConfigs,
	},
	{
		"mhartington/formatter.nvim",
		cmd = {"Format", "FormatWrite", "FormatLock", "FormatWriteLock"},
		init = function ()
			vim.keymap.set({"n", "x"}, "<D-s>", function()
				vim.cmd.FormatWrite()
				vim.cmd.update()
			end, { desc = "󰒕  Save & Format" })
		end,
		config = formatterConfigs,
	},
}

-- TODO
-- INFO alternatives for when null-ls is archived
-- - https://github.com/jay-babu/mason-null-ls.nvim/issues/82
-- - ensure_installed https://github.com/WhoIsSethDaniel/mason-tool-installer.nvim
-- - https://dotfyle.com/this-week-in-neovim/48#jose-elias-alvarez/null-ls.nvim
-- https://www.reddit.com/r/neovim/comments/15oue2o/finally_a_robust_autoformatting_solution/

