vim.opt_local.listchars:remove("multispace") -- spacing in comments

-- auto-break on textwidth
vim.defer_fn(function() vim.opt_local.formatoptions:append("t") end, 1)

-- SPELLING
vim.opt_local.spell = true
Bufmap { "ge", "]s", desc = "󰓆 Next misspelling" }
Bufmap { "gE", "[s", desc = "󰓆 Previous misspelling" }

--------------------------------------------------------------------------------

-- UTILITY KEYMAPS
Bufmap { "<Tab>", "<End>", mode = "i", desc = " Goto EoL" }
Bufmap { "<Tab>", "A", desc = " Goto EoL" }

Bufmap {
	"(",
	function()
		local line = vim.api.nvim_get_current_line()
		local row, col = unpack(vim.api.nvim_win_get_cursor(0))
		local isFirstWord = line:find(" ") == nil
		local toAdd = isFirstWord and "(): " or "()"
		local newLine = line:sub(1, col) .. toAdd .. line:sub(col + 1)
		vim.api.nvim_set_current_line(newLine)
		vim.api.nvim_win_set_cursor(0, { row, col + 1 }) -- move cursor to the right
	end,
	mode = "i",
	desc = "`():` autopairing for gitcommit",
}

--------------------------------------------------------------------------------

local tinygitBuffer = vim.bo.buftype == "nofile"
if not tinygitBuffer then -- already has its own mappings
	Bufmap { "<CR>", "ZZ", desc = " Confirm" } -- quit with saving = confirm
	Bufmap { "q", vim.cmd.cquit, desc = " Abort" } -- quit with error = aborting
end

--------------------------------------------------------------------------------
