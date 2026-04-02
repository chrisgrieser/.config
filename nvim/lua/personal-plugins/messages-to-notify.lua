-- INFO
-- This snippet redirects cmdline messages to `vim.notify`, silencing `Press
-- Enter to continue` prompts, even with `cmdheight=0`.
-- Alternative with `require('vim._core.ui2')`: https://www.reddit.com/r/neovim/comments/1sa95g4/no_more_press_enter_with_ui2_with_example/
--------------------------------------------------------------------------------
local hasNotificationPlugin = package.loaded["nvim-notify"]
	or package.loaded["snacks"]
	or package.loaded["mini.notify"]
if not hasNotificationPlugin then return end
--------------------------------------------------------------------------------

local config = {
	msgKind = { -- existing kinds: https://neovim.io/doc/user/api-ui-events/#ui-messages
		ignore = { "search_cmd", "undo", "empty" },
		mini = { "bufwrite" }, -- more minimal style when using `snacks.notifier`
	},
	notification = { icon = "󰍩" },
}

--------------------------------------------------------------------------------

local ns = vim.api.nvim_create_namespace("messages-to-notify")

local function attach()
	vim.ui_attach(ns, { ext_messages = true }, function(event, ...)
		if event == "msg_history_show" then
			local msgs = ...
			local out = vim.iter(msgs):fold("", function(acc, entry)
				local msg = vim.iter(entry[2]):fold("", function(acc2, msg) return acc2 .. msg[2] end)
				return acc .. msg .. "\n\n"
			end)
			vim.notify(out, nil, { title = ":messages", icon = config.notification.icon })
		end
		if event ~= "msg_show" then return end

		local kind, content, _replace, _history = ... -- for `msg_show` only https://neovim.io/doc/user/api-ui-events/#ui-messages
		if vim.list_contains(config.msgKind.ignore, kind) then return end

		-- notification text and options
		local text = vim.iter(content):fold("", function(acc, chunk) return acc .. chunk[2] end)
		text = vim.trim(text):gsub("^(E%d+):", "[%1]") -- emphasize error codes

		local level = vim.log.levels.INFO
		if kind == "emsg" or kind:find("erro?r?$") then -- typos: ignore-line
			level = vim.log.levels.ERROR
		elseif kind == "wmsg" then
			level = vim.log.levels.WARN
		end

		local opts = { title = kind, icon = config.notification.icon }
		if kind == "lua_print" then opts.ft = "lua" end
		if kind == "progress" then opts.id = "messages-to-notify" end
		if vim.list_contains(config.msgKind.mini, kind) and package.loaded["snacks"] then
			opts.style = "minimal"
			opts.id = "messages-to-notify"
			if opts.icon then opts.icon = " " .. opts.icon .. " " end
		end

		vim.schedule(function() vim.notify(text, level, opts) end)
	end)
end

local function detach() vim.ui_detach(ns) end

--------------------------------------------------------------------------------

local group = vim.api.nvim_create_augroup("ui-hack", { clear = true })
vim.api.nvim_create_autocmd("CmdlineLeave", { group = group, callback = attach })
vim.api.nvim_create_autocmd("CmdlineEnter", { group = group, callback = detach })
attach() -- initialize
