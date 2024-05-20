local usedWithinMins = 15 -- CONFIG
local recentBufs = vim.iter(vim.fn.getbufinfo { buflisted = 1 })
	:filter(function(buf) return os.time() - buf.lastused < usedWithinMins * 60 end)
	:map(function(buf) return buf.bufnr end)
	:totable()
vim.notify("⭕ recentBufs: " .. vim.inspect(recentBufs))
