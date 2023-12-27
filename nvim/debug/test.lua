local function normal(cmd) vim.cmd.normal { cmd, bang = true } end

vim.opt_local.grepprg = "rg --vimgrep"
vim.ui.input({
	prompt = "Grep for:",
	default = vim.fn.expand("<cword>"),
}, function(input)
	if not input then return end
	vim.cmd("silent! grep " .. input)
	vim.cmd.copen()

end)

-- foobarbaz
-- foobarbaz
