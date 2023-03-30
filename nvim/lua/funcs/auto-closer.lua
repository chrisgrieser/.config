local M = {}
local ignoredFiletypes, retirementAgeMins

-- https://neovim.io/doc/user/builtin.html#getbufinfo() iterate all buffer and close outdated, non-special buffers
local function checkOutdatedBuffer()
	local openBuffers = vim.fn.getbufinfo { buflisted = 1 }
	for _, buf in pairs(openBuffers) do
		local usedSecsGo = os.time() - buf.lastused
		local recentlyUsed = usedSecsGo < retirementAgeMins * 60
		local bufFt = vim.api.nvim_buf_get_option(buf.bufnr)
		if not recentlyUsed then
			local filename = buf.name:gsub(".*/", "")
			print("Closing Buffer" .. filename)
			vim.api.nvim_buf_delete(buf.bufnr, { force = false, unload = false })
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
	timer:start(0, 5000, vim.schedule_wrap(checkOutdatedBuffer))
end

return M
