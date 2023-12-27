vim.opt_local.grepprg = "rg --vimgrep --no-column"

vim.ui.input({
	prompt = "Grep",
	default = vim.fn.expand("<cword>"),
}, function(input)
	if not input then return end

	vim.cmd("silent grep " .. input)
	vim.cmd("copen 13") -- to preview results

	local cmd = (":cdo s/%s//I"):format(input)
	vim.api.nvim_feedkeys(cmd, "i", true)

	-- position cursor
	local left2 = vim.api.nvim_replace_termcodes("<Left><Left>", true, false, true)
	vim.defer_fn(function() vim.api.nvim_feedkeys(left2, "i", false) end, 100)

	vim.api.nvim_create_autocmd("CmdlineLeave", {
		once = true,
		callback = function()
			vim.cmd.cclose()
			vim.defer_fn(vim.cmd.cfirst, 1)
		end,
	})
end)

-- MAYBE
-- MAYBE
