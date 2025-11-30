-- TREESITTER QUERY FILETYPE
vim.bo.commentstring = "; %s" -- add space
vim.bo.iskeyword = vim.go.iskeyword -- inherit global one instead of overwriting it

-- for `:InspectTree`
if vim.bo.buftype == "nofile" then
	vim.opt_local.listchars:append { lead = "│" }

	vim.schedule(function() -- to remove the delay for `q`
		vim.keymap.set("n", "q", vim.cmd.close, { buffer = true, nowait = true })
	end)
end

-- for `.scm` files
if vim.bo.buftype == "" then
	vim.opt_local.tabstop = 2
	vim.opt_local.expandtab = true
end
