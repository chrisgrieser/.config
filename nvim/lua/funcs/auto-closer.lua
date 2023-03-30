-- https://neovim.io/doc/user/luvref.html#uv.new_timer()
local M = {}
--------------------------------------------------------------------------------

-- iterate all buffer and close outdated, non-special buffers
-- https://neovim.io/doc/user/builtin.html#getbufinfo()
local function checkOutdatedBuffer()
	
end

--------------------------------------------------------------------------------
function M.setup()
	local intervallMin = 
	-- setup timer https://neovim.io/doc/user/luvref.html#uv.new_timer()
	local timer = vim.loop.new_timer()
	if not timer then return end
	timer:start(1, 1000, checkOutdatedBuffer)
end

--------------------------------------------------------------------------------

return M
