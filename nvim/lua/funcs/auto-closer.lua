local M = {}
local ignoredFiletypes, retirementAgeMins

-- https://neovim.io/doc/user/builtin.html#getbufinfo() iterate all buffer and close outdated, non-special buffers
local function checkOutdatedBuffer()
	local openBuffers = vim.fn.getbufinfo { buflisted = 1 }
	for _, buf in pairs(openBuffers) do
		local bufFt = "?" -- TODO figure out how to get filetype from buffer
		local ignoredFt = vim.tbl_contains(ignoredFiletypes, bufFt)
		local recentlyUsed = (os.time() - buf.lastused) > retirementAgeMins * 60
		if not ignoredFt and not recentlyUsed then
			vim.cmd.bdelete(buf.bufnr)
		end
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
	timer:start(0,  1000, checkOutdatedBuffer)
end

return M
