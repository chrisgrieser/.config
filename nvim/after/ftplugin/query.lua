-- query = treesitter query language
--------------------------------------------------------------------------------

vim.bo.commentstring = "; %s" -- add space
vim.bo.iskeyword = vim.go.iskeyword -- inherit global one instead of overwriting it

--------------------------------------------------------------------------------

-- for `.scm` files
if vim.bo.buftype == "" then
	vim.opt_local.tabstop = 2
	vim.opt_local.expandtab = true
end

-- for `:InspectTree` buffers
if vim.bo.buftype == "nofile" then
	vim.opt_local.listchars:append { lead = "│" }
	-- to remove the delay for `q`
	local bufnr = vim.api.nvim_get_current_buf()
	vim.schedule(function()
		if not vim.api.nvim_buf_is_valid(bufnr) then return end
		vim.keymap.set("n", "q", vim.cmd.close, { buffer = true, nowait = true })
	end)
end
