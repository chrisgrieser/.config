local M = {}
local ignoredFiletypes, retirementAgeMins

-- https://neovim.io/doc/user/builtin.html#getbufinfo() iterate all buffer and close outdated, non-special buffers
local function checkOutdatedBuffer()
	local openBuffers
	vim.schedule_wrap( function() openBuffers = vim.fn.getbufinfo { buflisted = 1 } end)()

	if openBuffers == nil then
		print("offenbuffers is nil")
		return
	end
	for _, buf in pairs(openBuffers) do
		local recentlyUsed = (os.time() - buf.lastused) > retirementAgeMins * 60
		if not recentlyUsed then vim.api.nvim_buf_delete(buf.bufnr, { force = false, unload = false }) end
	end
end

---@param opts table
function M.setup(opts)
	if not opts then opts = {} end
	retirementAgeMins = opts.retirementAgeMins or 30
	ignoredFiletypes = opts.ignoredFiletypes or {}

	-- setup timer https://neovim.io/doc/user/luvref.html#uv.new_timer()
	local timer = vim.loop.new_timer()
	if not timer then return end
	timer:start(0, 5000, checkOutdatedBuffer)
end

return M
