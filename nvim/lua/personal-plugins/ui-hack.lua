-- REQUIRED a plugin that shows `vim.notify` outside of the cmdline, such as
-- `nvim-notify`, `snacks.notifier`, or `mini.notify`.
--------------------------------------------------------------------------------

local config = {
	events = {
		ignore = {
			"search_cmd",
		},
		mini = { -- requires `snacks.notifier`
			"bufwrite",
			"undo",
		},
	},
	notification = {
		icon = "󰍩",
	},
}

--------------------------------------------------------------------------------

local function attach()
	local ns = vim.api.nvim_create_namespace("ui-hack")

	---@diagnostic disable-next-line: redundant-parameter
	vim.ui_attach(ns, { ext_messages = true }, function(event, ...)
		if event ~= "msg_show" then return end
		local kind, content, _, _ = ...
		if vim.list_contains(config.events.ignore, kind) then return end

		if kind == "return_prompt" then
			local esc = vim.api.nvim_replace_termcodes("<CR>", true, true, true)
			vim.api.nvim_feedkeys(esc, "n", false)
			return
		end

		local text = vim.iter(content):fold("", function(acc, chunk) return acc .. chunk[2] end)
		local notifOpts = { title = kind, icon = config.notification.icon }
		if vim.list_contains(config.events.mini, kind) and package.loaded["snacks"] then
			notifOpts.style = "minimal"
			if notifOpts.icon then notifOpts.icon = " " .. notifOpts.icon .. " " end
		end
		local level = kind == "emsg" and vim.log.levels.ERROR or vim.log.levels.INFO

		vim.schedule(function() vim.notify(vim.trim(text), level, notifOpts) end)
	end)
end

local function detach()
	local ns = vim.api.nvim_create_namespace("ui-hack")
	vim.ui_detach(ns)
end

--------------------------------------------------------------------------------

attach() -- init
local group = vim.api.nvim_create_augroup("ui", { clear = true })
vim.api.nvim_create_autocmd("CmdlineEnter", { group = group, callback = detach })
vim.api.nvim_create_autocmd("CmdlineLeave", { group = group, callback = attach })
