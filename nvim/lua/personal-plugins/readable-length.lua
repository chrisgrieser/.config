local M = {}

local dummyWin, dummyBuf
local originalColorcol = vim.o.colorcolumn
--------------------------------------------------------------------------------

local function getWidth()
	return vim.o.columns - (vim.o.textwidth + 1) - tonumber(vim.o.signcolumn:match("%d") or "0") * 2
end

local function disable()
	vim.api.nvim_buf_delete(dummyBuf, { force = true })
	vim.wo[dummyWin].winhighlight = ""
	pcall(vim.api.nvim_win_close, dummyWin, true)
	dummyWin = nil
	vim.opt.colorcolumn = originalColorcol
end

local function enable()
	dummyBuf = vim.api.nvim_create_buf(false, true)
	local width = getWidth()
	if width < 1 then return end
	dummyWin = vim.api.nvim_open_win(dummyBuf, false, {
		split = "right",
		style = "minimal",
		width = width,
	})
	vim.wo[dummyWin].winhighlight = "Normal:Colorcolumn"
	vim.bo[dummyBuf].modifiable = false
	vim.o.colorcolumn = "" -- disable since wrapped as well
end

--------------------------------------------------------------------------------
local group = vim.api.nvim_create_augroup("ReadableLength", { clear = true })

vim.api.nvim_create_autocmd("BufEnter", {
	group = group,
	callback = function(ctx)
		if vim.bo[ctx.buf].buftype ~= "" then return end
		local shouldEnable = vim.b[ctx.buf].readableLength

		if shouldEnable and not dummyWin then
			enable()
		elseif not shouldEnable and dummyWin then
			disable()
		end
	end,
})

vim.api.nvim_create_autocmd("BufDelete", {
	group = group,
	callback = function(ctx)
		if vim.b[ctx.buf].readableLength then disable() end
	end,
})

vim.api.nvim_create_autocmd("VimResized", {
	group = group,
	callback = function(ctx)
		local width = getWidth()
		local shouldEnable = vim.b[ctx.buf].readableLength
		if shouldEnable and not dummyWin then
			enable()
		elseif width < 1 and dummyWin then
			disable()
		elseif dummyWin then
			vim.api.nvim_win_set_config(dummyWin, { width = width })
		end
	end,
})

-- initialize
if vim.b.readableLength then enable() end

--------------------------------------------------------------------------------
return M
