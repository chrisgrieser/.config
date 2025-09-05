-- DOCS
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
		"xml", -- macOS `.plist` are also `.xml`
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
		"gitattributes",
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
	dependencies = {
		"html_tags",
		"ecma",
		"jsx",
	},
}

--------------------------------------------------------------------------------

---@module "lazy.types"
---@type LazyPluginSpec
return {
	"nvim-treesitter/nvim-treesitter",
	branch = "main", -- new versions follow `main`
	lazy = false,
	build = ":TSUpdate",

	opts = {
		install_dir = vim.fn.stdpath("data") .. "/treesitter",
	},
	init = function()
		-- auto-install parsers
		local parsersToInstall = vim.iter(vim.tbl_values(ensureInstalled)):flatten():totable()
		vim.defer_fn(function() require("nvim-treesitter").install(parsersToInstall) end, 1000)

		-- use bash parser for zsh files
		vim.treesitter.language.register("bash", "zsh")

		-- auto-start highlights & indentation
		vim.api.nvim_create_autocmd("FileType", {
			desc = "User: enable treesitter highlighting",
			callback = function(ctx)
				-- highlights
				local hasStarted = pcall(vim.treesitter.start, ctx.buf) -- errors for filetypes with no parser

				-- indent
				local dontUseTreesitterIndent = { "bash", "zsh", "markdown" }
				if hasStarted and not vim.list_contains(dontUseTreesitterIndent, ctx.match) then
					vim.bo[ctx.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
				end
			end,
		})

		-- COMMENTS parser
		vim.api.nvim_create_autocmd({ "ColorScheme", "VimEnter" }, {
			desc = "User: highlights for the Treesitter `comments` parser",
			callback = function()
				-- FIX todo-comments in languages where LSP overwrites their highlight
				-- https://github.com/stsewd/tree-sitter-comment/issues/22
				-- https://github.com/LuaLS/lua-language-server/issues/1809
				vim.api.nvim_set_hl(0, "@lsp.type.comment", {})

				-- Define `@comment.bold` for `queries/comment/highlights.scm`
				vim.api.nvim_set_hl(0, "@comment.bold", { bold = true })
			end,
		})
	end,
}
