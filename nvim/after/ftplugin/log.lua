-- Go to tail of the log
vim.defer_fn(function() vim.cmd.normal { "G", bang = true } end, 1)
