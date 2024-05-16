vim.opt_local.tabstop = 2
vim.opt_local.shiftwidth = 2
vim.opt_local.expandtab = true

--------------------------------------------------------------------------------

-- emulate truthy rule: https://yamllint.readthedocs.io/en/stable/rules.html#module-yamllint.rules.truthy
-- implementing myself, since I do not want to install a linter just for one rule

local function checkForYamlTruthy()
	local lines = vim.api.nvim_buf_get_lines(0, 0, -1, true)

	for _, line in pairs(lines) do
		local truthy = line:find("[^\"']")
		if truthy then
			if not citekeyCount[citekey] then
				citekeyCount[citekey] = 1
			else
				duplCitekeys = duplCitekeys .. "\n" .. "- " .. citekey
			end
		end
	end

	vim.notify(lnum, vim.log.levels.WARN, { title = "Truthy" })
end

-- run on entering a bibtex buffer
-- deferred, to ensure nvim-notify is loaded
vim.defer_fn(checkForYamlTruthy, 1000)
