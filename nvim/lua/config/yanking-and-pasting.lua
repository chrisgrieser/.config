local keymap = require("config.utils").uniqueKeymap
--------------------------------------------------------------------------------

-- OPTIONS
vim.opt.clipboard = "unnamedplus"

vim.api.nvim_create_autocmd("TextYankPost", {
	desc = "User: Highlighted Yank",
	callback = function() vim.highlight.on_yank { timeout = 1000 } end,
})

--------------------------------------------------------------------------------
-- STICKY YANK/DELETE

do
	local cursorBefore
	keymap({ "n", "x" }, "y", function()
		cursorBefore = vim.api.nvim_win_get_cursor(0)
		return "y"
	end, { expr = true })
	keymap("n", "Y", function()
		cursorBefore = vim.api.nvim_win_get_cursor(0)
		return "y$"
	end, { expr = true, unique = false }) -- `unique`, since it's a nvim-builtin
	keymap({ "n", "x" }, "d", function()
		cursorBefore = vim.api.nvim_win_get_cursor(0)
		return "d"
	end, { expr = true })
	keymap("n", "dd", function()
		cursorBefore = vim.api.nvim_win_get_cursor(0)
		local lineEmpty = vim.trim(vim.api.nvim_get_current_line()) == ""
		return (lineEmpty and [["_dd]] or "dd")
	end, { expr = true })
	keymap("n", "D", function()
		cursorBefore = vim.api.nvim_win_get_cursor(0)
		return "D"
	end, { expr = true })

	vim.api.nvim_create_autocmd("TextYankPost", {
		desc = "User: Sticky yank/delete",
		callback = function()
			if vim.v.event.regname ~= "" or not cursorBefore then return end

			if vim.v.event.operator == "y" then
				vim.api.nvim_win_set_cursor(0, cursorBefore)
			elseif vim.v.event.operator == "d" then
				local cursorNow = vim.api.nvim_win_get_cursor(0)
				local cursorWasInFront = cursorNow[1] > cursorBefore[1]
					or (cursorNow[1] == cursorBefore[1] and cursorNow[2] > cursorBefore[2])
				if not cursorWasInFront then return end

				vim.defer_fn(function() vim.api.nvim_win_set_cursor(0, cursorBefore) end, 1)
			end
		end,
	})
end

--------------------------------------------------------------------------------
-- KEEP THE REGISTER CLEAN

keymap({ "n", "x" }, "x", '"_x')
keymap({ "n", "x" }, "c", '"_c')
keymap("n", "C", '"_C')
keymap("x", "p", "P")

-- PASTING
keymap("n", "P", function()
	local curLine = vim.api.nvim_get_current_line():gsub("%s*$", "")
	local reg = vim.trim(vim.fn.getreg("+"))
	vim.api.nvim_set_current_line(curLine .. " " .. reg)
end, { desc = " Sticky paste at EoL" })

keymap("i", "<D-v>", function()
	local reg = vim.trim(vim.fn.getreg("+")):gsub("\n%s*$", "\n") -- remove indentation if multi-line
	vim.fn.setreg("+", reg, "v")
	return "<C-g>u<C-r><C-o>+" -- `<C-g>u` adds undopoint before the paste
end, { desc = " Paste charwise", expr = true })

-- for compatibility with macOS clipboard managers
keymap("n", "<D-v>", "p", { desc = " Paste" })

--------------------------------------------------------------------------------
-- SPECIAL YANK OPERATIONS

keymap("n", "<leader>yl", function()
	-- not using `:glocal // yank` because it yanks lines one after the other
	vim.ui.input({ prompt = "󰅍 Yank lines matching:" }, function(input)
		if not input then return end
		local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
		local matchLines = vim.tbl_filter(function(l) return l:find(input, nil, true) end, lines)
		vim.fn.setreg("+", table.concat(matchLines, "\n"))
		local pluralS = #matchLines == 1 and "" or "s"
		local msg = ("%d line%s"):format(#matchLines, pluralS)
		vim.notify(msg, nil, { title = "Copied", icon = "󰅍" })
	end)
end, { desc = "󰦨 Lines matching pattern" })

keymap("n", "<leader>y:", function()
	local lastCmd = vim.fn.getreg(":"):gsub("^lua ?", "")
	vim.fn.setreg("+", lastCmd)
	vim.notify(lastCmd, nil, { title = "Copied", icon = "󰅍" })
end, { desc = "󰘳 Last :excmd" })
