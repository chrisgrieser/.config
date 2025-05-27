-- https://github.com/nvim-treesitter/nvim-treesitter/tree/main
-- https://github.com/nvim-treesitter/nvim-treesitter/blob/main/SUPPORTED_LANGUAGES.md
--------------------------------------------------------------------------------

local ensureInstalled = {
	programmingLangs = {
		"lua",
		"bash", -- also used for zsh
		"javascript",
		"typescript",
		"python",
		"svelte",
		"swift",
		"vim",
		"ruby", -- used by Brewfile
		"rust",
	},
	dataFormats = {
		"json",
		"json5",
		"jsonc",
		"yaml",
		"toml",
		"xml", -- mac `.plist` are also xml
	},
	content = {
		"markdown",
		"markdown_inline",
		"css",
		"html",
	},
	specialFiletypes = {
		"query", -- treesitter query files
		"make",
		"just",
		"editorconfig",
		"diff",
		"git_config",
		"git_rebase",
		"gitcommit",
		"gitignore",
		"requirements", -- pip requirements file
	},
	embeddedLangs = {
		"regex",
		"luap", -- lua patterns
		"luadoc",
		"comment",
		"jsdoc",
		"graphql",
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
		local alreadyInstalled = require("nvim-treesitter.config").installed_parsers()
		local parsersToInstall = vim.iter(vim.tbl_values(ensureInstalled))
			:flatten()
			:filter(function(parser) return not vim.tbl_contains(alreadyInstalled, parser) end)
			:totable()
		vim.defer_fn(function() require("nvim-treesitter").install(parsersToInstall) end, 1000)

		-- use bash parser for zsh files
		vim.treesitter.language.register("bash", "zsh")

		-- auto-start highlights & indentation
		vim.api.nvim_create_autocmd("FileType", {
			desc = "User: enable treesitter highlighting",
			callback = function(ctx)
				-- highlights
				local hasStarted = pcall(vim.treesitter.start) -- errors for filetypes with no parser

				-- indent
				local noIndent = { "markdown", "javascript", "typescript" }
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
