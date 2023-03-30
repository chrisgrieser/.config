local M = {}
local ignoredFiletypes, retirementAgeMins, notificationOnAutoClose
--------------------------------------------------------------------------------

-- iterate all buffer and close inactive, non-special buffers
local function checkOutdatedBuffer()
	local openBuffers = vim.fn.getbufinfo { buflisted = 1 } -- https://neovim.io/doc/user/builtin.html#getbufinfo

	for _, buf in pairs(openBuffers) do
		local usedSecsGo = os.time() - buf.lastused
		local recentlyUsed = usedSecsGo < retirementAgeMins * 60
		local bufFt = vim.api.nvim_buf_get_option(buf.bufnr, "filetype")
		local isIgnoredFt = vim.tbl_contains(ignoredFiletypes, bufFt)
		local isSpecialBuffer = vim.api.nvim_buf_get_option(buf.bufnr, "buftype") ~= ""

		if not (recentlyUsed or isIgnoredFt or isSpecialBuffer) then
			local filename = buf.name:gsub(".*/", "")
			if notificationOnAutoClose then vim.notify("Auto-Closing Buffer: " .. filename) end
			vim.api.nvim_buf_delete(buf.bufnr, { force = false, unload = false })
		end
	end
end

--------------------------------------------------------------------------------

---@class opts
---@field retirementAgeMins number minutes after which an inactive buffer is closed
---@field ignoredFiletypes string[] list of filetypes to never close
---@field notificationOnAutoClose boolean list of filetypes to never close

---@param opts opts
function M.setup(opts)
	if not opts then opts = {} end
	-- default values
	retirementAgeMins = opts.retirementAgeMins or 10
	ignoredFiletypes = opts.ignoredFiletypes or { "lazy" }
	notificationOnAutoClose = opts.notificationOnAutoClose or false

	local timer = vim.loop.new_timer() -- https://neovim.io/doc/user/luvref.html#uv.new_timer()
	if not timer then return end
	timer:start(0, 5000, vim.schedule_wrap(checkOutdatedBuffer)) -- schedule wrapper required for timers
end

--------------------------------------------------------------------------------
return M
