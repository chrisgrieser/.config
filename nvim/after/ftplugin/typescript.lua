-- inherit all javascript settings
vim.cmd.source(vim.fn.stdpath("config") .. "/after/ftplugin/javascript.lua")

-- sets correct `errorformat` for quickfix-list
vim.cmd.compiler("tsc")

--------------------------------------------------------------------------------

-- custom formatting function to run code actions before running `biome`
local bkeymap = require("config.utils").bufKeymap
bkeymap("n", "<D-s>", function()
	-- code actions
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

	-- formatting
	local codeActionDuration = (#actions + 1) * 60
	vim.defer_fn(vim.lsp.buf.format, codeActionDuration + 50)
	-- FIX manually close folds PENDING https://github.com/biomejs/biome/issues/4393
	vim.defer_fn(
		function() require("ufo").openFoldsExceptKinds { "comment", "imports" } end,
		codeActionDuration + 400
	)
end, { desc = "󰛦 Organize Imports & Format" })
