local bkeymap = require("config.utils").bufKeymap
--------------------------------------------------------------------------------

vim.opt_local.listchars:remove("multispace") -- spacing in comments

-- SPELLING
vim.opt_local.spell = true
vim.opt_local.spelloptions = "camel"
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

-- REVERT
-- replace first line of `git revert` with Conventional Commit keyword `revert`
-- (assumes `git config --global revert.reference false`)
local firstLine = vim.api.nvim_get_current_line()
if firstLine == "# *** SAY WHY WE ARE REVERTING ON THE TITLE LINE ***" then
	vim.api.nvim_set_current_line("revert: ")
	vim.cmd.startinsert { bang = true }
	vim.cmd.normal { "3gww", bang = true } -- reflow description line for readability
end
