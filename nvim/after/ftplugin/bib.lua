local bo = vim.bo
--------------------------------------------------------------------------------

-- do not autowrap
bo.formatoptions = bo.formatoptions:gsub("t", "")

-- for some reason, bib files have no comment string defined, even though they
-- do have comments?
bo.commentstring = "% %s"

-- off, since too many false negatives
vim.opt_local.spell = false

--------------------------------------------------------------------------------

---checks a .bib file for duplicate citekeys and reports them via `vim.notify`
---when any are found. Does nothing, if there are no duplicate citekeys.
---@param bufnr? number when not provided, uses the current buffer
local function checkForDuplicateCitekeys(bufnr)
	if not bufnr then bufnr = 0 end

	local duplCitekeys = ""
	local citekeyCount = {}
	local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, true)

	for _, line in pairs(lines) do
		local citekey = line:match("^@.-{(.*),")
		if citekey then
			if not citekeyCount[citekey] then
				citekeyCount[citekey] = 1
			else
				duplCitekeys = duplCitekeys .. "\n" .. "- " .. citekey
			end
		end
	end
	if duplCitekeys == "" then return end

	vim.notify("# Duplicate Citkeys" .. duplCitekeys, vim.log.levels.WARN, {
		on_open = function(win)
			local buf = vim.api.nvim_win_get_buf(win)
			vim.api.nvim_buf_set_option(buf, "filetype", "markdown")
		end,
	})
end

-- run on entering a bibtex buffer
-- deferred, to ensure nvim-notify is loaded
vim.defer_fn(checkForDuplicateCitekeys, 1000)
