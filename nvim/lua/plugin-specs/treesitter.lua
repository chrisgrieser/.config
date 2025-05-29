-- https://github.com/nvim-treesitter/nvim-treesitter/tree/main
-- https://github.com/nvim-treesitter/nvim-treesitter/blob/main/SUPPORTED_LANGUAGES.md
--------------------------------------------------------------------------------

local ensureInstalled = {
	programmingLangs = {
		"bash", -- also used for zsh
		"javascript",
		"lua",
		"python",
		"ruby", -- used by Brewfile
		"rust",
		"svelte",
		"swift",
		"typescript",
		"vim",
	},
	dataFormats = {
		"json",
		"json5",
		"jsonc",
		"toml",
		"xml", -- mac `.plist` are also xml
		"yaml",
	},
	content = {
		"css",
		"html",
		"markdown",
		"markdown_inline",
	},
	specialFiletypes = {
		"diff",
		"editorconfig",
		"git_config",
		"git_rebase",
		"gitcommit",
		"gitignore",
		"just",
		"make",
		"query", -- treesitter query files
		"requirements", -- pip requirements file
	},
	embeddedLangs = {
		"comment",
		"graphql",
		"jsdoc",
		"luadoc",
		"luap", -- lua patterns
		"regex",
		"rst", -- python reST
	},
}

return {
	"nvim-treesitter/nvim-treesitter",
	branch = "main", -- new versions follow `main`
	lazy = false,
	build = ":TSUpdate",

	opts = {
		install_dir = vim.fn.stdpath("data") .. "/treesitter-parsers",
	},
	config = function(_, opts)
		require("nvim-treesitter").setup(opts)

		-- auto-install parsers
		vim.defer_fn(function()
			local alreadyInstalled = require("nvim-treesitter.config").get_installed()
			local parsersToInstall = vim.iter(vim.tbl_values(ensureInstalled))
				:flatten()
				:filter(function(parser) return not vim.tbl_contains(alreadyInstalled, parser) end)
				:totable()
			require("nvim-treesitter").install(parsersToInstall)
		end, 1000)

		-- use bash parser for zsh files
		vim.treesitter.language.register("bash", "zsh")

		-- auto-start highlights & indentation
		vim.api.nvim_create_autocmd("FileType", {
			desc = "User: enable treesitter highlighting",
			callback = function(ctx)
				-- highlights
				local hasStarted = pcall(vim.treesitter.start) -- errors for filetypes with no parser

				-- indent
				local noIndent = { "bash", "zsh" }
				if hasStarted and not vim.list_contains(noIndent, ctx.match) then
					vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
				end
			end,
		})

		-- COMMENTS parser
		vim.api.nvim_create_autocmd({ "ColorScheme", "VimEnter" }, {
			desc = "User: Highlights for the Treesitter `comments` parser",
			callback = function()
				-- FIX lua todo-comments https://github.com/stsewd/tree-sitter-comment/issues/22
				-- https://github.com/LuaLS/lua-language-server/issues/1809
				vim.api.nvim_set_hl(0, "@lsp.type.comment.lua", {})
				vim.api.nvim_set_hl(0, "@lsp.type.comment.swift", {})

				-- Define `@comment.bold` for `queries/comment/highlights.scm`
				vim.api.nvim_set_hl(0, "@comment.bold", { bold = true })
			end,
		})
	end,
}
