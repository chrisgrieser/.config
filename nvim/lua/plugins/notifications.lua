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

-- filter out annoying buggy messages from plugins:
local function banned(msg)
	-- satellite https://github.com/lewis6991/satellite.nvim/issues/36
	-- guess-indent https://github.com/NMAC427/guess-indent.nvim/issues/13
	return msg:find("^error%(satellite.nvim%):")
		or msg:find("code = %-32801,")
		or vim.startswith(msg, "Did set indentation to ")
		or vim.startswith(msg, "Failed to detect indentation style")
end

local function notifyConfig()
	-- Base config
	local notifyWidth = 55

	require("notify").setup {
		render = "minimal",
		stages = "slide",
		level = 0, -- minimum severity level to display (0 = display all)
		max_height = 30,
		max_width = notifyWidth, -- HACK see below
		minimum_width = 13,
		timeout = 4000,
		top_down = false,
		on_open = function(win)
			if not vim.api.nvim_win_is_valid(win) then return end
			vim.api.nvim_win_set_config(win, { border = require("config.utils").borderStyle })
		end,
	}

	vim.notify = function(msg, level, opts) ---@diagnostic disable-line: duplicate-set-field
		if msg == nil then
			msg = "NIL"
		elseif banned(msg) then
			return
		elseif msg == "" then
			msg = '""' -- make empty string more apparent
		end

		local msgLines = vim.split(msg, "\n", { trimepty = true })
		local wrappesLines = {}
		for _, line in pairs(msgLines) do
			local new_lines = split_length(line, notifyWidth)
			for _, nl in ipairs(new_lines) do
				-- nl = nl:gsub("^%s*", ""):gsub("%s*$", "")
				if nl and nl ~= "" then table.insert(wrappesLines, " " .. nl .. " ") end
			end
		end
		local out = table.concat(wrappesLines, "\n")
		return require("notify")(out, level, opts)
	end
end

--------------------------------------------------------------------------------

return {
	"rcarriga/nvim-notify",
	event = "UIEnter",
	init = function()
		vim.opt.termguicolors = true
		local printDurationSecs = 7

		-- replace lua's print message with notify.nvim → https://www.reddit.com/r/neovim/comments/xv3v68/tip_nvimnotify_can_be_used_to_display_print/
		function print(...)
			local hasNonString = false
			local args = vim.tbl_map(function(arg)
				if type(arg) == "string" then return arg end
				hasNonString = true
				return vim.inspect(arg)
			end, { ... })
			local out = table.concat(args, " ")
			local ft = hasNonString and "lua" or "text"

			vim.notify(out, vim.log.levels.INFO, {
				timeout = printDurationSecs * 1000,
				on_open = function(win)
					local buf = vim.api.nvim_win_get_buf(win)
					-- filetype enables treesitter highlighting in the notification
					vim.api.nvim_buf_set_option(buf, "filetype", ft)
				end,
			})
		end
	end,
	config = notifyConfig,
}
