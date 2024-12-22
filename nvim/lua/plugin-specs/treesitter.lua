return {
	"nvim-treesitter/nvim-treesitter",
	event = "BufReadPost",
	build = ":TSUpdate",
	main = "nvim-treesitter.configs",
	opts = {
		-- easier than keeping track of new "special parsers", which are not
		-- auto-installed on entering a buffer (e.g., regex, luadocs, comments)
		ensure_installed = "all",

		highlight = {
			enable = true,
			disable = function(_, bufnr)
				-- disable on large files
				local maxFilesizeKb = 100
				local ok, stats = pcall(vim.uv.fs_stat, vim.api.nvim_buf_get_name(bufnr))
				if not (ok and stats) then return false end
				if stats.size > maxFilesizeKb * 1024 then
					local msg = "Disabled since file is larger than " .. maxFilesizeKb .. "kb"
					vim.notify(msg, nil, { title = "Treesitter", icon = "" })
					return true
				end
			end,
		},
		indent = {
			enable = true,
			disable = { "markdown" }, -- indentation at bullet points is worse
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
		-- stylua: ignore
		{ "<leader>ot", function() vim.cmd.TSBufToggle("highlight") end, desc = " Treesitter highlights" },
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
			local maxLen = 80
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
			if vim.str_utfindex(text) > maxLen then return text:sub(1, maxLen - 1) .. "…" end
			return text
		end

		vim.g.lualineAdd("tabline", "lualine_b", codeContext, "after")
	end,
}
