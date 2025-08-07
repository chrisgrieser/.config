-- SOURCE inherit all javascript settings
vim.cmd.source(vim.fn.stdpath("config") .. "/after/ftplugin/javascript.lua")
--------------------------------------------------------------------------------

-- sets `errorformat` for quickfix-list
vim.cmd.compiler("tsc")

--------------------------------------------------------------------------------

local bkeymap = require("config.utils").bufKeymap

-- custom formatting function to run code actions before running `biome`
bkeymap("n", "<D-s>", function()
	local actions = {
		"source.addMissingImports.ts",
		"source.removeUnusedImports.ts",
		"source.fixAll.biome",
	}
	for i = 1, #actions do
		vim.defer_fn(
			function()
				vim.lsp.buf.code_action {
					---@diagnostic disable-next-line: missing-fields, assign-type-mismatch
					context = { only = { actions[i] } },
					apply = true,
				}
			end,
			i * 60
		)
	end

	vim.defer_fn(vim.lsp.buf.format, (#actions + 1) * 60)
end, { desc = "󰛦 Organize Imports & Format" })

-- When typing `await`, automatically add `async` to the function declaration
bkeymap("i", "t", function()
	vim.api.nvim_feedkeys("t", "n", true) -- pass through the trigger char
	local col = vim.api.nvim_win_get_cursor(0)[2]
	local textBeforeCursor = vim.api.nvim_get_current_line():sub(col - 3, col)
	if textBeforeCursor ~= "awai" then return end
	-----------------------------------------------------------------------------

	local funcNode = vim.treesitter.get_node()
	local functionNodes = { "arrow_function", "function_declaration", "function" }

	repeat -- loop trough ancestors till function node found
		funcNode = funcNode and funcNode:parent()
		if not funcNode then return end
	until vim.tbl_contains(functionNodes, funcNode:type())

	local functionText = vim.treesitter.get_node_text(funcNode, 0)
	if vim.startswith(functionText, "async") then return end -- already async
	local startRow, startCol = funcNode:start()
	vim.api.nvim_buf_set_text(0, startRow, startCol, startRow, startCol, { "async " })
end, { desc = "󰛦 Auto-add `async`" })
