vim.opt_local.tabstop = 2
vim.opt_local.shiftwidth = 2
vim.opt_local.expandtab = true

--------------------------------------------------------------------------------

-- TRUTHY RULE: https://yamllint.readthedocs.io/en/stable/rules.html#module-yamllint.rules.truthy
-- implementing myself, since I do not want to install a linter just for one rule

local function checkForYamlTruthy()
	local lines = vim.api.nvim_buf_get_lines(0, 0, -1, true)
	local msg = {}
	for lnum = 1, #lines do
		local line = lines[lnum]
		local truthy = line:match(" yes$") or line:match(" no$")
		if truthy then
			table.insert(msg, ("%s: %q"):format(lnum, vim.trim(line)))
			-- go to first occurrence
			if #msg == 1 then vim.api.nvim_win_set_cursor(0, { lnum, #line }) end
		end
	end
	if #msg > 0 then
		vim.notify(table.concat(msg, "\n"), vim.log.levels.WARN, { title = "Truthy Warning" })
	end
end

-- run on entering a bibtex buffer
-- deferred, to ensure nvim-notify is loaded
vim.defer_fn(checkForYamlTruthy, 1000)
