local textObj = require("config.utils").extraTextobjMaps
--------------------------------------------------------------------------------

return { -- treesitter-based textobjs
	"nvim-treesitter/nvim-treesitter-textobjects",
	dependencies = "nvim-treesitter/nvim-treesitter",
	-- stylua: ignore
	cmd = { "TSTextobjectSelect", "TSTextobjectSwapNext", "TSTextobjectSwapPrevious", "TSTextobjectGotoNextStart", "TSTextobjectGotoPreviousStart" },
	-- SIC yes, configured via treesitter, not this plugin. Also, calling
	-- treesitter's `setup` a second time is apparently not a problem.
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
		-- MOVE & SWAP
		-- stylua: ignore start
		{ "<C-j>", "<cmd>TSTextobjectGotoNextStart @function.outer<CR>", desc = " Goto next function" },
		{ "<C-k>", "<cmd>TSTextobjectGotoPreviousStart @function.outer<CR>", desc = " Goto prev function" },
		{ "ä", "<cmd>TSTextobjectSwapNext @parameter.inner<CR>", desc = " Swap next arg" },
		{ "Ä", "<cmd>TSTextobjectSwapPrevious @parameter.inner<CR>", desc = " Swap prev arg" },
		-- stylua: ignore end

		-- TEXT OBJECTS
		-- stylua: ignore start
		{ "a<CR>", "<cmd>TSTextobjectSelect @return.outer<CR>", mode = {"x","o"}, desc = "↩ outer return" },
		{ "i<CR>", "<cmd>TSTextobjectSelect @return.inner<CR>", mode = {"x","o"}, desc = "↩ inner return" },
		{ "a/", "<cmd>TSTextobjectSelect @regex.outer<CR>", mode = {"x","o"}, desc = " outer regex" },
		{ "i/", "<cmd>TSTextobjectSelect @regex.inner<CR>", mode = {"x","o"}, desc = " inner regex" },
		{ "aa", "<cmd>TSTextobjectSelect @parameter.outer<CR>", mode = {"x","o"}, desc = "󰏪 outer arg" },
		{ "ia", "<cmd>TSTextobjectSelect @parameter.inner<CR>", mode = {"x","o"}, desc = "󰏪 inner arg" },
		{ "iu", "<cmd>TSTextobjectSelect @loop.inner<CR>", mode = {"x","o"}, desc = "󰛤 inner loop" },
		{ "au", "<cmd>TSTextobjectSelect @loop.outer<CR>", mode = {"x","o"}, desc = "󰛤 outer loop" },
		{ "a" .. textObj.func, "<cmd>TSTextobjectSelect @function.outer<CR>", mode = {"x","o"},desc = " outer function" },
		{ "i" .. textObj.func, "<cmd>TSTextobjectSelect @function.inner<CR>", mode = {"x","o"},desc = " inner function" },
		{ "a" .. textObj.condition, "<cmd>TSTextobjectSelect @conditional.outer<CR>", mode = {"x","o"},desc = "󱕆 outer c[o]ndition" },
		{ "i" .. textObj.condition, "<cmd>TSTextobjectSelect @conditional.inner<CR>", mode = {"x","o"},desc = "󱕆 inner c[o]ndition" },
		{ "a" .. textObj.call, "<cmd>TSTextobjectSelect @call.outer<CR>", mode = {"x","o"},desc = "󰡱 outer ca[l]l" },
		{ "i" .. textObj.call, "<cmd>TSTextobjectSelect @call.inner<CR>", mode = {"x","o"},desc = "󰡱 inner ca[l]l" },
		-- only operator-pending to not conflict with selection-commenting
		{ "q", "<cmd>TSTextobjectSelect @comment.outer<CR>", mode = "o", desc = "󰆈 single comment" },

		-- CUSTOM TEXTOBJECTS
		{"g" .. textObj.call, "<cmd>TSTextobjectSelect @call.caller<CR>", mode = "o", desc = "󰡱 ca[l]ler" },

		-- stylua: ignore end
	},
}