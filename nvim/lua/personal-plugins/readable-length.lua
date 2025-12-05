local M = {}

local dummyWin
local originalColorcol = vim.o.colorcolumn
--------------------------------------------------------------------------------

local function getWidth()
	return vim.o.columns - (vim.o.textwidth + 1) - tonumber(vim.o.signcolumn:match("%d")) * 2
end

local function disable()
	if not dummyWin then return end
	vim.api.nvim_win_close(dummyWin, true)
	dummyWin = nil
	vim.o.colorcolumn = originalColorcol
end

local function enable()
	local bufnr = vim.api.nvim_create_buf(false, true)
	local width = getWidth()
	if width < 1 then return end
	local winid = vim.api.nvim_open_win(bufnr, false, {
		split = "right",
		width = width,
		style = "minimal",
	})
	vim.wo[winid].winhighlight = "Normal:Colorcolumn"
	vim.wo[winid].winfixbuf = true
	vim.bo[bufnr].modifiable = false
	dummyWin = winid
	vim.o.colorcolumn = "" -- disable since wrapped as well
end

--------------------------------------------------------------------------------
local group = vim.api.nvim_create_augroup("MarkdownReadableLength", { clear = true })

vim.api.nvim_create_autocmd("BufEnter", {
	group = group,
	callback = function(ctx)
		if vim.bo[ctx.buf].buftype ~= "" then return end
		local isMarkdown = vim.bo[ctx.buf].filetype == "markdown"

		if isMarkdown and not dummyWin then
			enable()
		elseif not isMarkdown and dummyWin then
			disable()
		end
	end,
})

vim.api.nvim_create_autocmd("VimResized", {
	group = group,
	callback = function(ctx)
		local isMarkdown = vim.bo[ctx.buf].filetype == "markdown"
		local width = getWidth()
		if isMarkdown and not dummyWin then
			enable()
		elseif width < 1 and dummyWin then
			disable()
		elseif dummyWin then
			vim.api.nvim_win_set_config(dummyWin, { width = width })
		end
	end,
})

-- initialize
if vim.bo.filetype == "markdown" then enable() end

--------------------------------------------------------------------------------
return M
