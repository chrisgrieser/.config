local textobj = require("config.utils").extraTextobjMaps
--------------------------------------------------------------------------------

return { -- treesitter-based textobjs
	"nvim-treesitter/nvim-treesitter-textobjects",
	dependencies = "nvim-treesitter/nvim-treesitter",
	cmd = {
		"TSTextobjectSelect",
		"TSTextobjectSwapNext",
		"TSTextobjectSwapPrevious",
		"TSTextobjectGotoNextStart",
		"TSTextobjectGotoPreviousStart",
		"TSTextobjectPeekDefinitionCode",
	},

	-- SIC configured via treesitter, not this plugin. 
	-- Running config twice is also not a problem.
	main = "nvim-treesitter.configs",

	opts = {
		textobjects = {
			select = {
				lookahead = true,
				-- `true` would even remove line breaks from charwise objects,
				-- thus staying with `false`
				include_surrounding_whitespace = false,
			},
		},
	},
	keys = {
		-- stylua: ignore start

		-- PEEK HOVER
		-- (useful e.g. for typescript types/interfaces, where regular hover does
		-- not show the fields.)
		{ "<leader>H", "<cmd>TSTextobjectPeekDefinitionCode @class.outer<CR>", desc = " LSP Peek" },

		-- MOVE
		{ "<C-j>", "<cmd>TSTextobjectGotoNextStart @function.outer<CR>", desc = " Goto next function" },
		{ "<C-k>", "<cmd>TSTextobjectGotoPreviousStart @function.outer<CR>", desc = " Goto prev function" },

		-- SWAP
		{ "ä", "<cmd>TSTextobjectSwapNext @parameter.inner<CR>", desc = " Swap next arg" },
		{ "Ä", "<cmd>TSTextobjectSwapPrevious @parameter.inner<CR>", desc = " Swap prev arg" },

		-- TEXT OBJECTS
		{ "a<CR>", "<cmd>TSTextobjectSelect @return.outer<CR>", mode = {"x","o"}, desc = "↩ outer return" },
		{ "i<CR>", "<cmd>TSTextobjectSelect @return.inner<CR>", mode = {"x","o"}, desc = "↩ inner return" },
		{ "a/", "<cmd>TSTextobjectSelect @regex.outer<CR>", mode = {"x","o"}, desc = " outer regex" },
		{ "i/", "<cmd>TSTextobjectSelect @regex.inner<CR>", mode = {"x","o"}, desc = " inner regex" },
		{ "aa", "<cmd>TSTextobjectSelect @parameter.outer<CR>", mode = {"x","o"}, desc = "󰏪 outer arg" },
		{ "ia", "<cmd>TSTextobjectSelect @parameter.inner<CR>", mode = {"x","o"}, desc = "󰏪 inner arg" },
		{ "iu", "<cmd>TSTextobjectSelect @loop.inner<CR>", mode = {"x","o"}, desc = "󰛤 inner loop" },
		{ "au", "<cmd>TSTextobjectSelect @loop.outer<CR>", mode = {"x","o"}, desc = "󰛤 outer loop" },
		{ "a" .. textobj.func, "<cmd>TSTextobjectSelect @function.outer<CR>", mode = {"x","o"},desc = " outer function" },
		{ "i" .. textobj.func, "<cmd>TSTextobjectSelect @function.inner<CR>", mode = {"x","o"},desc = " inner function" },
		{ "a" .. textobj.condition, "<cmd>TSTextobjectSelect @conditional.outer<CR>", mode = {"x","o"},desc = "󱕆 outer condition" },
		{ "i" .. textobj.condition, "<cmd>TSTextobjectSelect @conditional.inner<CR>", mode = {"x","o"},desc = "󱕆 inner condition" },
		{ "a" .. textobj.call, "<cmd>TSTextobjectSelect @call.outer<CR>", mode = {"x","o"},desc = "󰡱 outer call" },
		{ "i" .. textobj.call, "<cmd>TSTextobjectSelect @call.inner<CR>", mode = {"x","o"},desc = "󰡱 inner call" },

		-- CUSTOM TEXTOBJECTS (defined via .scm files)
		{ "g" .. textobj.call, "<cmd>TSTextobjectSelect @call.caller<CR>", mode = "o", desc = "󰡱 caller" },

		-- COMMENTS
		-- only operator-pending to not conflict with selection-commenting
		{ "q", "<cmd>TSTextobjectSelect @comment.outer<CR>", mode = "o", desc = "󰆈 single comment" },

		-- stylua: ignore end

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
