-- DOCS
-- https://github.com/nvim-treesitter/nvim-treesitter/tree/main
-- https://github.com/nvim-treesitter/nvim-treesitter/blob/main/SUPPORTED_LANGUAGES.md
--------------------------------------------------------------------------------

local ensureInstalled = {
	programmingLangs = {
		"bash", -- used for zsh
		"zsh",
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
}

--------------------------------------------------------------------------------

return {
	"nvim-treesitter/nvim-treesitter",
	lazy = false,
	build = ":TSUpdate",
	branch = "main", -- new versions follow `main`

	opts = {
		install_dir = vim.fn.stdpath("data") .. "/treesitter",
	},
	init = function()
		-- auto-install parsers
		if vim.fn.executable("tree-sitter") == 1 then
			local parsersToInstall = vim.iter(vim.tbl_values(ensureInstalled)):flatten():totable()
			vim.defer_fn(function() require("nvim-treesitter").install(parsersToInstall) end, 1000)
		else
			local msg = "`tree-sitter-cli` not found. Skipping auto-install of parsers."
			vim.notify(msg, vim.log.levels.WARN, { title = "Treesitter" })
		end

		-- auto-start highlights & indentation
		vim.api.nvim_create_autocmd("FileType", {
			desc = "User: enable treesitter highlighting",
			callback = function(ctx)
				-- highlights
				local hasStarted = pcall(vim.treesitter.start, ctx.buf) -- errors for filetypes with no parser

				-- indent
				local dontUseTreesitterIndent = { "bash", "zsh", "markdown", "javascript" }
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
