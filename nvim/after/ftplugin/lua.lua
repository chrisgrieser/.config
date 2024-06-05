local u = require("config.utils")
--------------------------------------------------------------------------------

-- habits from writing too much in other languages
local function abbr(lhs, rhs) vim.keymap.set("ia", lhs, rhs, { buffer = true }) end

abbr("//", "--")
abbr("const", "local")
abbr("fi", "end")
abbr("!=", "~=")
abbr("!==", "~=")
abbr("===", "==")

--------------------------------------------------------------------------------

-- Put to EoL in cmdline
vim.keymap.set("n", "<leader>r", function()
	local line = vim.api.nvim_get_current_line()
	local col = vim.api.nvim_win_get_cursor(0)[2]
	local toEol = vim.trim(line:sub(col + 1))
	return ":lua = " .. toEol
end, { buffer = true, expr = true, desc = " Put to EoL in cmdline" })

vim.keymap.set("x", "<leader>r", function()
	u.leaveVisualMode()
	local pos = vim.region(0, "'<", "'>", "v", true)
	local row = vim.tbl_keys(pos)[1]
	local start, stop = unpack(vim.tbl_values(pos)[1])
	local sel = vim.api.nvim_buf_get_text(0, row, start, row, stop, {})[1]
	return ":lua = " .. sel
end, { buffer = true, expr = true, desc = " Put Selection in cmdline" })

--------------------------------------------------------------------------------
-- REQUIRE MODULE FROM CWD

-- lightweight version of telescope-import.nvim import (just for lua)
vim.keymap.set("n", "<leader>cr", function()
	local regex = [[local (\w+) = require\(["'](.*?)["']\)(\.\w*)?]]
	local rgArgs = { "rg", "--no-config", "--only-matching", "--no-filename", regex }
	local rgResult = vim.system(rgArgs):wait()
	assert(rgResult.code == 0, rgResult.stderr)
	local matches = vim.split(vim.trim(rgResult.stdout), "\n")

	vim.api.nvim_create_autocmd("FileType", {
		pattern = "TelescopeResults",
		once = true,
		callback = function() vim.bo.filetype = "lua" end,
	})

	vim.ui.select(vim.fn.uniq(matches), { prompt = " require" }, function(selection)
		if not selection then return end
		local lnum = vim.api.nvim_win_get_cursor(0)[1]
		vim.api.nvim_buf_set_lines(0, lnum, lnum, false, { selection })
		u.normal("j==")
	end)
end, { buffer = true, desc = " require module from cwd" })
