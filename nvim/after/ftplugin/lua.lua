local bkeymap = require("config.utils").bufKeymap
local abbr = require("config.utils").bufAbbrev
--------------------------------------------------------------------------------

-- FIXES HABITS
-- from writing too much in other languages
abbr("//", "--")
abbr("const", "local")
abbr("let", "local")
abbr("===", "==")
abbr("!=", "~=")
abbr("!==", "~=")
abbr("=~", "~=") -- shell uses `=~`
abbr("fi", "end")

---@param sign "+"|"-"
local function plusPlusMinusMinus(sign)
	local row, col = unpack(vim.api.nvim_win_get_cursor(0))
	local textBeforeCursor = vim.api.nvim_get_current_line():sub(col - 1, col)
	if not textBeforeCursor:find("%a%" .. sign) then
		vim.api.nvim_feedkeys(sign, "n", true) -- pass through the trigger char
	else
		local line = vim.api.nvim_get_current_line()
		local updated = line:gsub("(%w+)%" .. sign, "%1 = %1 " .. sign .. " 1")
		vim.api.nvim_set_current_line(updated)
		local diff = #updated - #line
		vim.api.nvim_win_set_cursor(0, { row, col + diff })
	end
end
bkeymap("i", "+", function() plusPlusMinusMinus("+") end, { desc = "i++  i = i+1" })
bkeymap("i", "-", function() plusPlusMinusMinus("-") end, { desc = "i--  i = i-1" })

--------------------------------------------------------------------------------
-- YANK MODULE NAME

bkeymap("n", "<leader>ym", function()
	local absPath = vim.api.nvim_buf_get_name(0)
	local relPath = absPath:sub(#(vim.uv.cwd()) + 2)
	local module = relPath:gsub("%.lua$", ""):gsub("^lua/", ""):gsub("/", "."):gsub("%.init$", "")
	local req = ("require(%q)"):format(module)
	vim.fn.setreg("+", req)
	vim.notify(req, nil, { icon = "󰅍", title = "Copied", ft = "lua" })
end, { desc = "󰢱 Module (require)" })
