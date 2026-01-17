-- Go to tail of the log
if vim.b.already_scrolled_logfile then return end
vim.defer_fn(function()
	vim.cmd.normal { "G", bang = true }
	vim.b.already_scrolled_logfile = true
end, 1)
