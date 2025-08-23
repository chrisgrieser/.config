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

bkeymap("i", "(", function()
	local line = vim.api.nvim_get_current_line()
	local row, col = unpack(vim.api.nvim_win_get_cursor(0))
	local isFirstWord = line:find(" ") == nil
	local toAdd = isFirstWord and "(): " or "()"
	local newLine = line:sub(1, col) .. toAdd .. line:sub(col + 1)
	vim.api.nvim_set_current_line(newLine)
	vim.api.nvim_win_set_cursor(0, { row, col + 1 }) -- move cursor to the right
end, { desc = "`():` autopairing for gitcommit" })

--------------------------------------------------------------------------------

local tinygitBuffer = vim.bo.buftype == "nofile"
if not tinygitBuffer then -- already has its own mappings
	bkeymap("n", "<CR>", "ZZ", { desc = " Confirm" }) -- quit with saving = confirm
	bkeymap("n", "q", vim.cmd.cquit, { desc = " Abort" }) -- quit with error = aborting
end

--------------------------------------------------------------------------------
