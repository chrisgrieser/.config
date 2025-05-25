local textobj = require("config.utils").extraTextobjMaps

local function select(obj)
	return function()
		require("nvim-treesitter-textobjects.select").select_textobject(obj, "textobjects")
	end
end
--------------------------------------------------------------------------------

return { -- treesitter-based textobjs
	"nvim-treesitter/nvim-treesitter-textobjects",
	dependencies = "nvim-treesitter/nvim-treesitter",
	branch = "main", -- needed for nvim-treesitter's `main` branch

	opts = {
		select = {
			lookahead = true,
			-- `true` would even remove line breaks from charwise objects,
			-- thus staying with `false`
			include_surrounding_whitespace = false,
		},
	},
	keys = {

		-- MOVE
		{
			"<C-j>",
			function()
				local move = require("nvim-treesitter-textobjects.move")
				move.goto_next_start("@function.outer", "textobjects")
			end,
			desc = " Goto next function",
		},
		{
			"<C-k>",
			function()
				local move = require("nvim-treesitter-textobjects.move")
				move.goto_previous_start("@function.outer", "textobjects")
			end,
			desc = " Goto prev function",
		},

		-- SWAP
		{
			"ä",
			function() require("nvim-treesitter-textobjects.swap").swap_next("@parameter.inner") end,
			desc = " Swap next arg",
		},
		{
			"Ä",
			function() require("nvim-treesitter-textobjects.swap").swap_previous("@parameter.inner") end,
			desc = " Swap prev arg",
		},

		-- TEXT OBJECTS
		{ "a<CR>", select("@return.outer"), mode = { "x", "o" }, desc = "↩ outer return" },
		{ "i<CR>", select("@return.inner"), mode = { "x", "o" }, desc = "↩ inner return" },
		{ "a/", select("@regex.outer"), mode = { "x", "o" }, desc = " outer regex" },
		{ "i/", select("@regex.inner"), mode = { "x", "o" }, desc = " inner regex" },
		{ "aa", select("@parameter.outer"), mode = { "x", "o" }, desc = "󰏪 outer arg" },
		{ "ia", select("@parameter.inner"), mode = { "x", "o" }, desc = "󰏪 inner arg" },
		{ "iu", select("@loop.inner"), mode = { "x", "o" }, desc = "󰛤 inner loop" },
		{ "au", select("@loop.outer"), mode = { "x", "o" }, desc = "󰛤 outer loop" },
		{ "a" .. textobj.call, select("@call.outer"), mode = { "x", "o" }, desc = "󰡱 outer call" },
		{ "i" .. textobj.call, select("@call.inner"), mode = { "x", "o" }, desc = "󰡱 inner call" },
		-- stylua: ignore start
		{ "a" .. textobj.func, select("@function.outer"), mode = { "x", "o" }, desc = " outer function" },
		{ "i" .. textobj.func, select("@function.inner"), mode = { "x", "o" }, desc = " inner function" },
		{ "a" .. textobj.condition, select("@conditional.outer"), mode = { "x", "o" }, desc = "󱕆 outer condition" },
		{ "i" .. textobj.condition, select("@conditional.inner"), mode = { "x", "o" }, desc = "󱕆 inner condition" },
		-- stylua: ignore end

		-- CUSTOM TEXTOBJECTS (defined via .scm files)
		{
			"r" .. textobj.call,
			"<cmd>TSTextobjectSelect @call.justCaller<CR>",
			mode = "o",
			desc = "󰡱 rest of caller",
		},
		{
			"ad",
			"<cmd>TSTextobjectSelect @docstring.outer<CR>",
			mode = { "x", "o" },
			desc = "󰌠 outer docstring",
			ft = "python",
		},
		{
			"id",
			"<cmd>TSTextobjectSelect @docstring.inner<CR>",
			mode = { "x", "o" },
			desc = "󰌠 inner docstring",
			ft = "python",
		},
		{ -- override default inner conditional for some languages
			"i" .. textobj.condition,
			"<cmd>TSTextobjectSelect @conditional.conditionOnly<CR>",
			mode = { "x", "o" },
			desc = "󱕆 inner conditional",
			ft = { "javascript", "typescript", "lua", "swift", "python", "bash", "zsh" },
		},

		-- COMMENTS
		-- only operator-pending to not conflict with selection-commenting
		{
			"q",
			"<cmd>TSTextobjectSelect @comment.outer<CR>",
			mode = "o",
			desc = "󰆈 single comment",
		},

		{
			"cq",
			function()
				-- not using `@comment.inner`, since not yet supported for many languages
				vim.cmd.TSTextobjectSelect("@comment.outer")
				local comStr = vim.bo.commentstring:format("")
				vim.cmd.normal { "c" .. comStr, bang = true }
				vim.cmd.startinsert { bang = true }
			end,
			desc = "󰆈 Change single comment",
		},

		{
			"dq",
			function()
				-- as opposed to regular usage of the textobj, also trims the line
				-- and preserves the cursor position
				local cursorBefore = vim.api.nvim_win_get_cursor(0)
				vim.cmd.TSTextobjectSelect("@comment.outer")
				vim.cmd.normal { "d", bang = true }
				local trimmedLine = vim.api.nvim_get_current_line():gsub("%s+$", "")
				vim.api.nvim_set_current_line(trimmedLine)
				vim.api.nvim_win_set_cursor(0, cursorBefore)
			end,
			desc = "󰆈 Delete single comment",
		},
	},
}
