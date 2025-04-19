local config = {
	eventsToIgnore = {
		"search_cmd",
	},
}

--------------------------------------------------------------------------------
local ns = vim.api.nvim_create_namespace("ui")

local function attach()
	---@diagnostic disable-next-line: redundant-parameter
	vim.ui_attach(ns, { ext_messages = true }, function(event, ...)
		if event ~= "msg_show" then return end
		local kind, content = ...
		if config.eventsToIgnore[kind] then return end
		vim.schedule(function()
			vim.notify(vim.inspect(content), vim.log.levels.DEBUG, { title = kind })
		end)
	end)
end

local function detach() vim.ui_detach(ns) end

--------------------------------------------------------------------------------

local group = vim.api.nvim_create_augroup("ui", { clear = true })
vim.api.nvim_create_autocmd("CmdlineEnter", { group = group, callback = detach })
vim.api.nvim_create_autocmd("CmdlineLeave", { group = group, callback = attach })
attach() -- init
