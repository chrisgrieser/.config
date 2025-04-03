local textObj = require("config.utils").extraTextobjMaps
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
			lsp_interop = { -- for `:TSTextobjectPeekDefinitionCode`
				floating_preview_opts = { title = "  Peek " },
			},
		},
	},
	keys = {
		-- stylua: ignore start

		-- MOVE
		{ "<C-j>", "<cmd>TSTextobjectGotoNextStart @function.outer<CR>", desc = " Goto next function" },
		{ "<C-k>", "<cmd>TSTextobjectGotoPreviousStart @function.outer<CR>", desc = " Goto prev function" },

		-- PEEK HOVER
		{ "<leader>H", "<cmd>TSTextobjectPeekDefinitionCode @class.outer<CR>", desc = " LSP Peek" },

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
		{ "a" .. textObj.func, "<cmd>TSTextobjectSelect @function.outer<CR>", mode = {"x","o"},desc = " outer function" },
		{ "i" .. textObj.func, "<cmd>TSTextobjectSelect @function.inner<CR>", mode = {"x","o"},desc = " inner function" },
		{ "a" .. textObj.condition, "<cmd>TSTextobjectSelect @conditional.outer<CR>", mode = {"x","o"},desc = "󱕆 outer condition" },
		{ "i" .. textObj.condition, "<cmd>TSTextobjectSelect @conditional.inner<CR>", mode = {"x","o"},desc = "󱕆 inner condition" },
		{ "a" .. textObj.call, "<cmd>TSTextobjectSelect @call.outer<CR>", mode = {"x","o"},desc = "󰡱 outer call" },
		{ "i" .. textObj.call, "<cmd>TSTextobjectSelect @call.inner<CR>", mode = {"x","o"},desc = "󰡱 inner call" },

		-- CUSTOM TEXTOBJECTS (defined via .scm files)
		{ "g" .. textObj.call, "<cmd>TSTextobjectSelect @call.caller<CR>", mode = "o", desc = "󰡱 caller" },

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
			desc = "󰆈 change single comment",
		},

		{
			"dq",
			function()
				local cursorBefore = vim.api.nvim_win_get_cursor(0)
				vim.cmd.TSTextobjectSelect("@comment.outer")
				vim.cmd.normal { "d", bang = true }
				local trimmedLine = vim.api.nvim_get_current_line():gsub("%s+$", "")
				vim.api.nvim_set_current_line(trimmedLine)
				vim.api.nvim_win_set_cursor(0, cursorBefore)
			end,
			desc = "󰆈 sticky single delete comment",
		},
	},
}
