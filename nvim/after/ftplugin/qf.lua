local bkeymap = require("config.utils").bufKeymap
--------------------------------------------------------------------------------

bkeymap("n", "q", vim.cmd.close, { desc = " Close" })

-- keep <CR> behavior of going to entry, even if <CR> is mapped to something else otherwise
bkeymap("n", "<CR>", "<CR>")

-- delete entry under cursor from quickfix
bkeymap("n", "dd", function()
	local lnum = vim.api.nvim_win_get_cursor(0)[1]

	local qf = vim.fn.getqflist { title = true, items = true }
	table.remove(qf.items, lnum)
	vim.fn.setqflist(qf.items, "r") -- "r" = replace = overwrite
	vim.fn.setqflist({}, "a", { title = qf.title }) -- preserve title of qflist

	vim.api.nvim_win_set_cursor(0, { math.min(#qf.items, lnum), 0 })
end, { desc = " Remove quickfix entry" })


--------------------------------------------------------------------------------

function _G.myQuickfixText(info)
	if info.quickfix == 0 then return {} end -- for loclist, use default

	local qf = vim.fn.getqflist { items = true, qfbufnr = true }
	local ns = vim.api.nvim_create_namespace("qflist")
	local function highlight(ln, startCol, endCol, hlGroup)
		vim.hl.range(qf.qfbufnr, ns, hlGroup, { ln - 1, startCol }, { ln, endCol })
	end

	local lines = {}
	for ln, item in ipairs(qf.items) do
		local lnumStr = item.lnum .. " "
		local filename = vim.fs.basename(vim.api.nvim_buf_get_name(item.bufnr)) .. ":"
		table.insert(lines, filename .. lnumStr .. vim.trim(item.text))

		vim.schedule(function()
			highlight(ln, 0, #filename, "qfFileName")
			highlight(ln, #filename, #filename + #lnumStr, "qfLineNr")
			highlight(ln, #filename + #lnumStr, -1, "qfText")
		end)
	end

	return lines
end
vim.opt.quickfixtextfunc = "v:lua.myQuickfixText"
