-- update parsers on update of the plugin
vim.api.nvim_create_autocmd("PackChanged", {
	callback = function(ctx)
		local name, kind = ctx.data.spec.name, ctx.data.kind
		if name == "nvim-treesitter" and kind == "update" then
			if not ctx.data.active then vim.cmd.packadd("nvim-treesitter") end
			vim.cmd("TSUpdate")
		end
	end,
})

vim.pack.add { "https://github.com/nvim-treesitter/nvim-treesitter" }

require("nvim-treesitter").setup {
	install_dir = vim.fn.stdpath("data") .. "/treesitter",
}
--------------------------------------------------------------------------------

local ensureInstalled = {
	-- PROGRAMMING LANGS
	"zsh",
	"javascript",
	"typescript",
	"lua",
	"python",
	"ruby", -- used by `Brewfile`
	"rust",
	"svelte",
	"swift",
	"vim",

	-- DATAFORMATS
	"json",
	"toml",
	"xml", -- also used by .plist and .svg files, since they are essentially xml
	"yaml",
	"bibtex",
	-- "csv", -- disabled, since bad highlighting

	-- CONTENT
	"css",
	"html",
	"markdown",
	"markdown_inline",

	-- SPECIAL FILETYPES
	"diff",
	"editorconfig",
	"git_config",
	"git_rebase",
	"gitattributes",
	"gitcommit",
	"gitignore",
	"just",
	"query", -- treesitter query files (.scm)
	"requirements", -- python's `requirements.txt`
	"vimdoc", -- `:help` files

	-- EMBEDDED LANGUAGES
	"comment",
	"graphql",
	"jsdoc",
	"luadoc",
	"luap", -- lua patterns
	"regex",
	"bash", -- embedded in GitHub Actions, etc.
}

--------------------------------------------------------------------------------

-- auto-install parsers (no-op if already installed)
if vim.fn.executable("tree-sitter") == 1 then
	vim.defer_fn(function() require("nvim-treesitter").install(ensureInstalled) end, 2000)
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
		local dontUseTreesitterIndent = { "zsh", "bash", "markdown", "javascript" }
		if hasStarted and not vim.list_contains(dontUseTreesitterIndent, ctx.match) then
			vim.bo[ctx.buf].indentexpr = "v:lua.require('nvim-treesitter').indentexpr()"
		end
	end,
})

-- comments parser
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

-- tell `ts_query_ls` to use the custom directory set in the treesitter config
local tsDir = require("nvim-treesitter.config").get_install_dir("parser")
vim.lsp.config("ts_query_ls", {
	init_options = { parser_install_directories = { tsDir } },
})
