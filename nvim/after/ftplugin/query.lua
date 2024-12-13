-- TREESITTER QUERY FILETYPE
vim.bo.commentstring = "; %s" -- add space

-- for `:InspectTree`
if vim.bo.buftype == "nofile" then
	vim.opt_local.listchars:append { lead = "│" }
	vim.keymap.set("n", "q", vim.cmd.close, { buffer = true, nowait = true })
end

-- for `scm` files
if vim.bo.buftype == "" then
	vim.opt_local.tabstop = 2
	vim.opt_local.expandtab = true
end
