-- TREESITTER QUERY FILETYPE

local optl = vim.opt_local

-- for `:InspectTree`
if vim.bo.buftype == "nofile" then
	optl.scrolloff = 10
	optl.listchars:append { lead = "│" }
	vim.keymap.set("n", "q", vim.cmd.close, { buffer = true, nowait = true })
end

-- for .scm files
if vim.bo.buftype == "" then
	optl.tabstop = 2
	optl.expandtab = true
end
