-- Go to tail
vim.defer_fn(function() vim.cmd.normal { "G", bang = true } end, 1)

-- `%` not actually a comment character, just convention of some programs
-- https://tex.stackexchange.com/questions/261261/are-comments-discouraged-in-a-bibtex-file
vim.bo.commentstring = "% %s"
vim.opt_local.formatoptions:append { r = true }

--------------------------------------------------------------------------------

-- since treesitter has not symbol support for bibtex, we just use a small
-- function to search the buffer for citekeys
vim.keymap.set("n", "gs", function()
	local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
	local citekeys = vim.iter(lines)
		:filter(function(line) return line:find("^@") end)
		:map(function(line) return line:match("^@.*{(.*),") end)
		:totable()
	vim.ui.select(citekeys, {
		prompt = "Select citekey:",
		format_item = function(citekey) return "@" .. citekey end,
		kind = "bibtex.citekey-search",
	}, function(citekey)
		if not citekey then return end
		vim.fn.search(citekey .. ",")
	end)
end, { buffer = true })
