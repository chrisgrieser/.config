-- vim.fn.matchadd("WarningMsg", [[\w\+\.lua:\d\+\ze:]]) -- \ze: lookahead
-- vim.fn.matchadd("WarningMsg", [[\w\+\.lua:\d\+\ze:]]) -- \ze: lookahead

-- .../nvim-data/lazy/nvim-chainsaw/lua/chainsaw/init.lua:31: attempt to call field 'normal' (a nil value)

-- vim.api.nvim_create_autocmd("FileType", {
-- 	pattern = "noice",
-- 	callback = function(ctx)
-- 		local bufnr = ctx.buf
-- 		vim.api.nvim_buf_call(bufnr, function()
-- 			vim.fn.matchadd("WarningMsg", [[\w\+\.lua:\d\+\ze:]]) -- \ze: lookahead
-- 			vim.defer_fn(function ()
-- 				local bufText = table.concat(vim.api.nvim_buf_get_lines(bufnr, 0, -1, false), "\n")
-- 				-- PENDING copy filename + line number, once telescope PR merged https://github.com/nvim-telescope/telescope.nvim/pull/2791
-- 				local lineNum = bufText:match("%w+%.lua:(%d+):")
-- 				if lineNum then vim.fn.setreg("+", lineNum) end
-- 			end, 1)
-- 		end)
-- 	end,
-- })




vim.notify("All parsers are up-to%-date")
