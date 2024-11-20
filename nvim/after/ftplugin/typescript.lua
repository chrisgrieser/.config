-- inherit all javascript settings
vim.cmd.source(vim.fn.stdpath("config") .. "/after/ftplugin/javascript.lua")

-- sets `errorformat` for quickfix-list
vim.cmd.compiler("tsc")

--------------------------------------------------------------------------------

-- custom formatting function to run code actions before running `biome`
local bkeymap = require("config.utils").bufKeymap
bkeymap("n", "<D-s>", function()
	local actions = {
		"source.addMissingImports.ts",
		"source.removeUnusedImports.ts",
		"source.organizeImports.biome",
	}
	for i = 1, #actions do
		vim.defer_fn(function()
			vim.lsp.buf.code_action {
				context = { only = { actions[i] } }, ---@diagnostic disable-line: assign-type-mismatch,missing-fields
				apply = true,
			}
		end, i * 60)
	end

	vim.defer_fn(vim.lsp.buf.format, (#actions + 1) * 60)
end, { desc = "󰛦 Organize Imports & Format" })

--------------------------------------------------------------------------------

-- When typing "await" add "async" to the function declaration
local function add_async()
	-- This function should be executed when the user types "t" in insert mode,
	-- but "t" is not inserted because it's the trigger.
	vim.api.nvim_feedkeys("t", "n", true)

	local textBeforeCursor = vim.fn.getline("."):sub(vim.fn.col(".") - 4, vim.fn.col(".") - 1)
	if textBeforeCursor ~= "awai" then return end

	-----------------------------------------------------------------------------

	local function findAncestor(node, types)
		if not node then return nil end
		if vim.tbl_contains(types, node:type()) then return node end
		return findAncestor(types, node:parent())
	end

	local node = vim.treesitter.get_node()
	local functionNode = findAncestor(node, { "arrow_function", "function_declaration", "function" })
	if not functionNode then return end

	local functionText = vim.treesitter.get_node_text(functionNode, 0)
	if vim.startswith(functionText, "async") then return end

	local startRow, startCol = functionNode:start()
	vim.api.nvim_buf_set_text(0, startRow, startCol, startRow, startCol, { "async " })
end

vim.keymap.set("i", "t", add_async, { buffer = true })
