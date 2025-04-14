local bkeymap = require("config.utils").bufKeymap
--------------------------------------------------------------------------------

vim.opt_local.listchars:remove("multispace") -- spacing in comments

-- auto-break on textwidth
vim.defer_fn(function() vim.opt_local.formatoptions:append("t") end, 1)

-- SPELLING
vim.opt_local.spell = true
bkeymap("n", "ge", "]s", { desc = "󰓆 Next misspelling" })
bkeymap("n", "gE", "[s", { desc = "󰓆 Previous misspelling" })

--------------------------------------------------------------------------------

-- UTILITY KEYMAPS
bkeymap("i", "<Tab>", "<End>", { desc = " Goto EoL" })
bkeymap("n", "<Tab>", "A", { desc = " Goto EoL" })

local tinygitBuffer = vim.bo.buftype == "nofile"
if not tinygitBuffer then -- already has its own mappings
	bkeymap("n", "<CR>", "ZZ", { desc = " Confirm" }) -- quitting with saving = committing
	bkeymap("n", "q", vim.cmd.cquit, { desc = " Abort" }) -- quitting with error = aborting commit
end

--------------------------------------------------------------------------------
