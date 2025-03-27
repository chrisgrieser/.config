return {
	"nvim-treesitter/nvim-treesitter",
	event = "BufReadPost",
	build = ":TSUpdate",
	main = "nvim-treesitter.configs",
	opts = {
		-- easier than keeping track of new "special parsers", which are not
		-- auto-installed on entering a buffer (e.g., regex, luadocs, comments)
		ensure_installed = "all",

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
	-- context as statusline component
	config = function(_, opts)
		require("nvim-treesitter.configs").setup(opts)

		local function codeContext()
			local maxLen = vim.o.columns * 0.75
			local text = require("nvim-treesitter").statusline {
				indicator_size = math.huge, -- shortening ourselves later
				separator = "  ",
				type_patterns = { "class", "function", "method", "field", "pair" }, -- `pair` for yaml/json
				transform_fn = function(line)
					return line
						:gsub("^async ", "") -- js/ts
						:gsub("^local ", "") -- lua: vars
						:gsub("^class", "󰜁")
						:gsub("^%(.*%) =>", "") -- js/ts: anonymous arrow function
						:gsub(" ?[{}] ?$", "")
						:gsub(" ?[=:(].-$", "") -- remove values/parameters
						:gsub(" extends .-$", "") -- js/ts: classes
						:gsub("(%w)%(%)$", "%1") -- remove empty `()`
						:gsub("^function", "")
						:gsub("^def", "") -- python
				end,
			}
			if not text then return "" end
			if vim.str_utfindex(text, "utf-8") > maxLen then return text:sub(1, maxLen - 1) .. "…" end
			return text
		end

		vim.g.lualineAdd("tabline", "lualine_b", codeContext)
	end,
}
