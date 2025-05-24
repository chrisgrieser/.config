return {
	"nvim-treesitter/nvim-treesitter",
	event = "BufReadPost",
	build = ":TSUpdate",
	main = "nvim-treesitter.configs",
	opts = {
		ensure_installed = {
			-- programming languages
			"lua",
			"bash", -- also used for zsh
			"javascript",
			"typescript",
			"python",
			"vim",
			"ruby", -- brewfile
			"swift",

			-- data formats
			"json",
			"jsonc",
			"yaml",
			"toml",

			-- content
			"markdown",
			"markdown_inline",
			"css",
			"html",

			-- special filetypes
			"query", -- treesitter query files
			"just",
			"editorconfig",
			"diff",
			"git_config",
			"git_rebase",
			"gitcommit",
			"gitignore",

			-- embedded languages
			"regex",
			"luap", -- lua patterns
			"luadoc",
			"comment",
			"requirements", -- pip requirements
			"jsdoc",
			"graphql",
		},

		highlight = { enable = true },
		indent = {
			enable = true,
			disable = {
				"typescript", -- sometimes indentation wrong
				"javascript", -- ^
				"markdown", -- indentation at bullet points is worse
			},
		},
	},
	init = function()
		-- use bash parser for zsh files
		vim.treesitter.language.register("bash", "zsh")

		-- fixes/improvements for the comments parser
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

	keys = {
		{ -- copy code context
			"<leader>yb",
			function()
				local codeContext = require("nvim-treesitter").statusline {
					indicator_size = math.huge, -- disable shortening
					type_patterns = { "class", "function", "method", "field", "pair" }, -- `pair` for yaml/json
					separator = ".",
				}
				if codeContext and codeContext ~= "" then
					codeContext = codeContext:gsub(" ?[:=][^:=]-$", ""):gsub(" ?= ?", "")
					vim.fn.setreg("+", codeContext)
					vim.notify(codeContext, nil, { title = "Copied", icon = "󰅍", ft = vim.bo.ft })
				else
					vim.notify("No code context.", vim.log.levels.WARN)
				end
			end,
			desc = "󰅍 Code context",
		},
	},
}
