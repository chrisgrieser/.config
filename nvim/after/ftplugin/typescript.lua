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
