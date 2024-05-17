-- `%` not actually a comment character, just convention of some programs
-- https://tex.stackexchange.com/questions/261261/are-comments-discouraged-in-a-bibtex-file
vim.bo.commentstring = '% %s'
vim.opt_local.formatoptions:append { r = true }

--------------------------------------------------------------------------------

-- since treesitter has not symbol support for bibtex, we just use a small
-- function to search the buffer for citekeys
vim.keymap.set("n", "gs", function()
	local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
	local citekeyLines = vim.tbl_filter(function(line) return line:find("^@") end, lines)
	local citekeys = vim.tbl_map(function(line) return line:match("^@.*{(.*),") end, citekeyLines)
	vim.ui.select(citekeys, {
		prompt = "Select citekey:",
		format_item = function(citekey) return "@" .. citekey end,
		kind = "bibtex.citekey-search",
	}, function(citekey)
		if not citekey then return end
		vim.fn.search(citekey .. ",")
	end)
end, { buffer = true })

--------------------------------------------------------------------------------

---checks a .bib file for duplicate citekeys and reports them via `vim.notify`
---when any are found. Does nothing, if there are no duplicate citekeys.
local function checkForDuplicateCitekeys()
	local duplCitekeys = ""
	local citekeyCount = {}
	local lines = vim.api.nvim_buf_get_lines(0, 0, -1, true)

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

	vim.notify(duplCitekeys, vim.log.levels.WARN, { title = "Duplicate Citekeys" })
end

-- run on entering a bibtex buffer
-- deferred, to ensure nvim-notify is loaded
vim.defer_fn(checkForDuplicateCitekeys, 1000)
