local bo = vim.bo
local u = require("config.utils")
--------------------------------------------------------------------------------

-- do not autowrap
bo.formatoptions = bo.formatoptions:gsub("t", "")

-- for some reason, bib files have no commentstring defined, even though they
-- do have comments?
bo.commentstring = "% %s"

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

		
	u.notify("Duplicate Citkeys", duplCitekeys, "warn")
end

-- run on entering a bibtex buffer
-- deferred, to ensure nvim-notify is loaded
vim.defer_fn(checkForDuplicateCitekeys, 1000)
