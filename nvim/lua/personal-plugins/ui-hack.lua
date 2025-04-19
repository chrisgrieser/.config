-- INFO redirects cmdline messages to `vim.notify`, silencing `Press Enter to
-- cotninue` prompts.
-- REQUIRED a plugin that shows `vim.notify` outside of the cmdline, such as
-- `nvim-notify`, `snacks.notifier`, or `mini.notify`.
--------------------------------------------------------------------------------

local config = {
	msgKind = {
		ignore = {
			"search_cmd",
		},
		mini = { -- more minimal style when using `snacks.notifier`
			"bufwrite",
			"undo",
		},
	},
	notification = {
		icon = "󰍩",
	},
}

--------------------------------------------------------------------------------

local ns = vim.api.nvim_create_namespace("ui-hack")

local function attach()
	---@diagnostic disable-next-line: redundant-parameter
	vim.ui_attach(ns, { ext_messages = true }, function(event, ...)
		if event ~= "msg_history_show" and event ~= "msg_show" then
			return
		elseif event == "msg_history_show" then
			local messages = ...
			vim.notify(vim.inspect(messages)) -- 🪚
			local text = vim.iter(messages):fold("", function(acc, chunk) return acc .. chunk[2][2] end)
			return
		end

		local kind, content, _, _ = ...
		if vim.list_contains(config.msgKind.ignore, kind) then return end

		if kind == "return_prompt" then
			local esc = vim.api.nvim_replace_termcodes("<CR>", true, true, true)
			vim.api.nvim_feedkeys(esc, "n", false)
			return
		end

		local text = vim.iter(content):fold("", function(acc, chunk) return acc .. chunk[2] end)
		local notifOpts = { title = kind, icon = config.notification.icon, ft = "text" }
		if vim.list_contains(config.msgKind.mini, kind) and package.loaded["snacks"] then
			notifOpts.style = "minimal"
			if notifOpts.icon then notifOpts.icon = " " .. notifOpts.icon .. " " end
		end
		local level = vim.log.levels.INFO
		if kind == "emsg" then level = vim.log.levels.ERROR end
		if kind == "wmsg" then level = vim.log.levels.WARN end

		vim.schedule(function() vim.notify(vim.trim(text), level, notifOpts) end)
	end)
end

local function detach() vim.ui_detach(ns) end

--------------------------------------------------------------------------------

attach() -- init
local group = vim.api.nvim_create_augroup("ui-hack", { clear = true })
vim.api.nvim_create_autocmd("CmdlineEnter", { group = group, callback = detach })
vim.api.nvim_create_autocmd("CmdlineLeave", { group = group, callback = attach })
