local bo = vim.bo
--------------------------------------------------------------------------------

-- do not autowrap
bo.formatoptions = bo.formatoptions:gsub("t", "")

-- for some reason, bib files have no comment string defined, even though they
-- do have comments?
bo.commentstring = "% %s"

--------------------------------------------------------------------------------

local function checkCitekeysForDuplicates()
	local lines = vim.api.nvim_buf_get_lines(0, 0, -1, true)
	local linesWithAt = vim.tbl_filter(function(line) return line:match("^@") end, lines)
	local citekeys = vim.tbl_map(function(line) return line:match("^.-{(.*)") end, linesWithAt)
	local citekeyCount = {}
	for _, citekey in pairs(citekeys) do
		if not citekeyCount[citekey] then
			citekeyCount[citekey] = 1
		else
			citekeyCount[citekey] = citekeyCount[citekey] + 1
		end
	end
	local duplicateCitekeys = vim.tbl_filter(function(citekey) return citekeyCount[citekey] > 1 end, citekeys)
end

-- run on entering a bibtex buffer
checkCitekeysForDuplicates()
