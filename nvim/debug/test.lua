local function getRowsWithMarker()
	local ns = vim.api.nvim_create_namespace("chainsaw.markers")
	local extmarks = vim.api.nvim_buf_get_extmarks(0, ns, 0, -1, { details = true })
	local rows = vim.iter(extmarks)
		:filter(function(extm) return not extm[4].invalid end) -- not deleted
		:map(function(extm) return extm[2] + 1 end)
		:totable()
	return rows
end

vim.notify("🖨️ 🟩")

vim.notify("🖨️ ⭐")
local out = getRowsWithMarker()
vim.notify(vim.inspect(out), nil, { title = "🖨️ out", ft = "lua" })
-- ffffffffffffffff

-- ffffffffffffffff
-- ffffffffffffffff
-- ffffffffffffffff
-- ffffffffffffffff
-- ffffffffffffffff
-- ffffffffffffffff
-- ffffffffffffffff
-- ffffffffffffffff
-- ffffffffffffffff
-- ffffffffffffffff
-- ffffffffffffffff
-- ffffffffffffffff
-- ffffffffffffffff
-- ffffffffffffffff
-- ffffffffffffffff
-- ffffffffffffffff
-- ffffffffffffffff
-- ffffffffffffffff
-- ffffffffffffffff
-- ffffffffffffffff
-- ffffffffffffffff
-- ffffffffffffffff
-- ffffffffffffffff
-- ffffffffffffffff
-- ffffffffffffffff
-- ffffffffffffffff
-- ffffffffffffffff
-- ffffffffffffffff
