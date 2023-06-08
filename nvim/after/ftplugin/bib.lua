local bo = vim.bo
--------------------------------------------------------------------------------

-- do not autowrap
bo.formatoptions = bo.formatoptions:gsub("t", "")

-- for some reason, bib files have no comment string defined, even though they
-- do have comments?
bo.commentstring = "% %s"

--------------------------------------------------------------------------------

---checks a .bib file for duplicate citekeys and reports them via `vim.notify`
---when any are found. Does nothing, if there are no duplicate citekeys. 
---@param bufnr? number when not provided, uses the current buffer
local function checkForDuplicateCitekeys(bufnr)
	if not bufnr then bufnr = 0 end
	local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, true)

	local linesWithAt = vim.tbl_filter(function(line) return line:match("^@") end, lines)
	local citekeys = vim.tbl_map(function(line) return line:match("^.-{(.*),") end, linesWithAt)
	local citekeyCount = {}
	for _, citekey in pairs(citekeys) do
		if not citekeyCount[citekey] then
			citekeyCount[citekey] = 1
		else
			citekeyCount[citekey] = citekeyCount[citekey] + 1
		end
	end

	local duplicateCitekeys = {}
	for citekey, count in pairs(citekeyCount) do
		if count > 1 then table.insert(duplicateCitekeys, citekey) end
	end
	if vim.tbl_isempty(duplicateCitekeys) then return end

	local msg = "# DUPLICATE CITEKEYS"
	for _, dup in pairs(duplicateCitekeys) do
		msg = msg .. "\n- " .. dup
	end

	vim.notify(msg, vim.log.levels.WARN, {
		on_open = function(win)
			local buf = vim.api.nvim_win_get_buf(win)
			vim.api.nvim_buf_set_option(buf, "filetype", "markdown")
		end,
	})
end

-- run on entering a bibtex buffer
-- deferred, to ensure nvim-notify is loaded
vim.defer_fn(checkForDuplicateCitekeys, 1000)
