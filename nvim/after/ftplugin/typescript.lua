-- inherit all javascript settings
vim.cmd.source(vim.fn.stdpath("config") .. "/after/ftplugin/javascript.lua")

-- sets correct `errorformat` for quickfix-list
vim.cmd.compiler("tsc")

--------------------------------------------------------------------------------

-- custom formatting function to run code actions before running `biome`
local keymap = require("config.utils").bufKeymap
keymap("n", "<D-s>", function()
	local actions = {
		"source.fixAll.ts",
		"source.addMissingImports.ts",
		"source.removeUnusedImports.ts",
		"source.organizeImports.biome",
	}
	for i = 1, #actions + 1 do
		vim.defer_fn(function()
			if i <= #actions then
				vim.lsp.buf.code_action {
					context = { only = { actions[i] } }, ---@diagnostic disable-line: assign-type-mismatch,missing-fields
					apply = true,
				}
			else
				vim.lsp.buf.format()
			end
		end, i * 60)
	end
end, { desc = "󰛦 Organize Imports & Format" })
