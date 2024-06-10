local u = require("config.utils")
--------------------------------------------------------------------------------

-- habits from writing too much in other languages
local function abbr(lhs, rhs) vim.keymap.set("ia", lhs, rhs, { buffer = true }) end

abbr("//", "--")
abbr("const", "local")
abbr("fi", "end")
abbr("!=", "~=")
abbr("!==", "~=")
abbr("=~", "~=") -- shell uses `=~`
abbr("===", "==")

--------------------------------------------------------------------------------

-- Mini-Repl
-- as opposed to `:lua =`, uses `vim.notify` for better output
vim.keymap.set("n", "<leader>e", function()
	local line = vim.api.nvim_get_current_line()
	local col = vim.api.nvim_win_get_cursor(0)[2]
	local toEol = vim.trim(line:sub(col + 1))
	return vim.notify(vim.inspect(vim.fn.luaeval(toEol)))
end, { buffer = true, desc = " Eval to EoL" })

vim.keymap.set("x", "<leader>e", function()
	u.leaveVisualMode()
	local pos = vim.region(0, "'<", "'>", "v", true)
	local row = vim.tbl_keys(pos)[1]
	local start, stop = unpack(vim.tbl_values(pos)[1])
	local sel = vim.api.nvim_buf_get_text(0, row, start, row, stop, {})[1]
	return vim.notify(vim.inspect(vim.fn.luaeval(sel)))
end, { buffer = true, desc = " Eval Selection" })

--------------------------------------------------------------------------------
-- REQUIRE MODULE FROM CWD

-- lightweight version of telescope-import.nvim import (just for lua)
vim.keymap.set("n", "<leader>cr", function()
	local regex = [[local (\w+) = require\(["'](.*?)["']\)(\.\w*)?]]
	local rgArgs = { "rg", "--no-config", "--only-matching", "--no-filename", regex }
	local rgResult = vim.system(rgArgs):wait()
	assert(rgResult.code == 0, rgResult.signal)
	local matches = vim.split(vim.trim(rgResult.stdout), "\n")
	table.sort(matches)
	local uniqMatches = vim.fn.uniq(matches)

	vim.api.nvim_create_autocmd("FileType", {
		pattern = "TelescopeResults",
		once = true,
		callback = function(ctx)
			vim.api.nvim_set_option_value("filetype", "lua", { buf = ctx.buf })
			-- make discernible as the results are now colored
			local ns = vim.api.nvim_create_namespace("telescope-import")
			vim.api.nvim_win_set_hl_ns(0, ns)
			vim.api.nvim_set_hl(ns, "TelescopeMatching", { reverse = true })
		end,
	})

	vim.ui.select(uniqMatches, { prompt = " require" }, function(selection)
		if not selection then return end
		local lnum = vim.api.nvim_win_get_cursor(0)[1]
		vim.api.nvim_buf_set_lines(0, lnum, lnum, false, { selection })
		u.normal("j==")
	end)
end, { buffer = true, desc = " require module from cwd" })

--------------------------------------------------------------------------------
