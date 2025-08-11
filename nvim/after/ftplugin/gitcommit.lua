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

vim.api.nvim_create_autocmd("TextChangedI", {
	desc = "User: improve auto-pairing for git commits",
	group = vim.api.nvim_create_augroup("gitcommit", { clear = true }),
	buffer = 0,
	callback = function()
		local line = vim.api.nvim_get_current_line()
		local col = vim.api.nvim_win_get_cursor(0)[2]
		local nextChar = line:sub(col + 1, col + 1)
		Chainsaw(nextChar) -- 🪚
		local prevChar = line:sub(col, col)
		Chainsaw(prevChar) -- 🪚
		local isFirstWord = line:find(" ") == nil
	end,
})

--------------------------------------------------------------------------------

local tinygitBuffer = vim.bo.buftype == "nofile"
if not tinygitBuffer then -- already has its own mappings
	bkeymap("n", "<CR>", "ZZ", { desc = " Confirm" }) -- quit with saving = confirm
	bkeymap("n", "q", vim.cmd.cquit, { desc = " Abort" }) -- quit with error = aborting
end

--------------------------------------------------------------------------------
