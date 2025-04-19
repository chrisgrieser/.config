-- REQUIRED
-- a plugin that shows `vim.notify` outside of the cmdline, e.g. nvim-notify or
-- snacks.notifier
--------------------------------------------------------------------------------

local config = {
	enabled = true,
	events = {
		ignore = {
			"search_cmd",
		},
		mini = {
			"bufwrite",
			"undo",
		},
	},
	notification = {
		icon = "󰍩",
		level = vim.log.levels.DEBUG,
	},
}

--------------------------------------------------------------------------------
local ns = vim.api.nvim_create_namespace("ui-hack")

local function attach()
	---@diagnostic disable-next-line: redundant-parameter
	vim.ui_attach(ns, { ext_messages = true }, function(event, ...)
		if event ~= "msg_show" then return end
		local kind, content, _, _ = ...
		if vim.list_contains(config.eventsToIgnore, kind) then return end

		local text = vim.iter(content):fold("", function(acc, chunk) return acc .. chunk[2] end)
		local notifOpts = { title = kind, icon = config.icon }

		vim.schedule(function() vim.notify(vim.trim(text), nil, notifOpts) end)
	end)
end

local function detach() vim.ui_detach(ns) end

--------------------------------------------------------------------------------

if config.enabled then
	local group = vim.api.nvim_create_augroup("ui", { clear = true })
	vim.api.nvim_create_autocmd("CmdlineEnter", { group = group, callback = detach })
	vim.api.nvim_create_autocmd("CmdlineLeave", { group = group, callback = attach })
	attach() -- init
end
