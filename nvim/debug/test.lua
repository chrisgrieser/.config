
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

-- vim.api.nvim_create_autocmd("FileType", {
-- 	pattern = "noice",
-- 	callback = function(ctx)
-- 		local bufnr = ctx.buf
--
-- 		-- highlight name + line number
-- 		vim.api.nvim_buf_call(bufnr, function()
-- 			vim.fn.matchadd("WarningMsg", [[\w\+\.lua:\d\+\ze:]]) -- \ze: lookahead
-- 		end)
--
-- 		-- copy line number
-- 		vim.defer_fn(function()
-- 			if not vim.api.nvim_buf_is_valid(bufnr) then return end
-- 			local bufText = table.concat(vim.api.nvim_buf_get_lines(bufnr, 0, -1, false), "\n")
-- 			local lineNum = bufText:match("%w+%.lua:(%d+):")
-- 			if lineNum then vim.fn.setreg("+", lineNum) end
-- 		end, 1)
-- 	end,
-- })

local msg =
	".../nvim-chainsaw/lua/chainsaw/init.lua:99: attempt to call field 'normal' (a nil value)\n"
local lineNum = msg:match("[^/]+%.lua:(%d+):") -- assumes lua file
vim.notify(lineNum)
