require("config/utils")
opt.termguicolors = true
--------------------------------------------------------------------------------

local notifyWidth = 55

require("notify").setup {
	render = "minimal",
	stages = "slide",
	level = 0, -- minimum severity level to display (0 = display all)
	max_height = 25,
	max_width = notifyWidth, -- HACK see below
	minimum_width = 13,
	timeout = 4000,
	top_down = false,
	on_open = function(win)
		if api.nvim_win_is_valid(win) then api.nvim_win_set_config(win, { border = borderStyle }) end
	end,
}

-- HACK requires custom wrapping setup https://github.com/rcarriga/nvim-notify/issues/129
-- replaces vim.notify = require("notify")
local function split_length(text, length)
	local lines = {}
	local next_line
	while true do
		if #text == 0 then return lines end
		next_line, text = text:sub(1, length), text:sub(length)
		lines[#lines + 1] = next_line
	end
end

vim.notify = function(msg, level, opts) ---@diagnostic disable-line: duplicate-set-field
	if type(msg) == "string" then msg = vim.split(msg, "\n", { trimepty = true }) end
	local truncated = {}
	for _, line in pairs(msg) do
		local new_lines = split_length(line, notifyWidth)
		new_lines = new_lines:gsub("^%s*"):gsub("%s*$")
		for _, nl in ipairs(new_lines) do
			table.insert(truncated, " " .. nl .. " ")
		end
	end
	return require("notify")(truncated, level, opts)
end

-- replace lua's print message with notify.nvim → https://www.reddit.com/r/neovim/comments/xv3v68/tip_nvimnotify_can_be_used_to_display_print/
-- selene: allow(incorrect_standard_library_use)
print = function(...)
	local print_safe_args = {}
	local _ = { ... }
	for i = 1, #_ do
		table.insert(print_safe_args, tostring(_[i]))
	end
	vim.notify(table.concat(print_safe_args, " "), vim.log.levels.INFO, { timeout = 10000 })
end
