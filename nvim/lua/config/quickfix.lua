local keymap = require("config.utils").uniqueKeymap
local bkeymap = require("config.utils").bufKeymap
--------------------------------------------------------------------------------
-- KEYMAPS

keymap("n", "gq", function()
	local ok = pcall(vim.cmd.cnext)
	if not ok then
		vim.notify("Wrapped.")
		vim.cmd.cfirst()
	end
end, { desc = " Next quickfix" })
keymap("n", "gQ", vim.cmd.cprevious, { desc = " Prev quickfix" })
keymap("n", "dQ", function() vim.cmd.cexpr("[]") end, { desc = " Clear quickfix" })

keymap("n", "<leader>q", function()
	local windows = vim.fn.getwininfo()
	for _, win in pairs(windows) do
		if win.quickfix == 1 then
			vim.cmd.cclose()
			return
		end
	end
	vim.cmd.copen()
end, { desc = " Toggle quickfix window" })

vim.api.nvim_create_autocmd("FileType", {
	pattern = "qf",
	callback = function()
		bkeymap("n", "q", vim.cmd.close, { desc = "Close" })
		bkeymap("n", "dd", function()
			local qfItems = vim.fn.getqflist()
			local lnum = vim.api.nvim_win_get_cursor(0)[1]
			table.remove(qfItems, lnum)
			vim.fn.setqflist(qfItems, "r")
			vim.api.nvim_win_set_cursor(0, { lnum, 0 })
		end, { desc = " Remove quickfix entry" })
	end,
})

--------------------------------------------------------------------------------

-- ADD SIGNS
local quickfixSign = "" -- CONFIG
vim.api.nvim_create_autocmd("QuickFixCmdPost", {
	callback = function()
		local ns = vim.api.nvim_create_namespace("quickfixSigns")

		local function setSigns(qf)
			vim.api.nvim_buf_set_extmark(qf.bufnr, ns, qf.lnum - 1, qf.col - 1, {
				sign_text = quickfixSign,
				sign_hl_group = "DiagnosticSignInfo",
				priority = 200, -- Gitsigns uses 6 by default, we want to be above
				invalidate = true, -- deletes the extmark if the line is deleted
				undo_restore = true, -- makes undo restore those
			})
		end

		-- clear signs
		local group = vim.api.nvim_create_augroup("quickfixSigns", { clear = true })
		vim.iter(vim.api.nvim_list_bufs())
			:each(function(bufnr) vim.api.nvim_buf_clear_namespace(bufnr, ns, 0, -1) end)

		-- set signs
		for _, qf in pairs(vim.fn.getqflist()) do
			if vim.api.nvim_buf_is_loaded(qf.bufnr) then
				setSigns(qf)
			else
				vim.api.nvim_create_autocmd("BufReadPost", {
					group = group,
					once = true,
					buffer = qf.bufnr,
					callback = function() setSigns(qf) end,
				})
			end
		end
	end,
})

--------------------------------------------------------------------------------

-- GOTO 1ST ITEM
vim.api.nvim_create_autocmd("QuickFixCmdPost", {
	-- `pcall` as event also triggered on empty quickfix, where `:cfirst` fails
	callback = function()
		vim.defer_fn(function() pcall(vim.cmd.cfirst) end, 100)
	end,
})
--------------------------------------------------------------------------------
local M = {}

function M.quickfixCounterStatusbar()
	local qf = vim.fn.getqflist { idx = 0, title = true, items = true }
	if #qf.items == 0 then return "" end

	-- prettify title output
	qf.title = qf 
		.title
		:gsub("^Live Grep: .-%((.+)%)", "%1") -- remove telescope prefixes to save space
		:gsub("^Find Files: .-%((.+)%)", "%1")
		:gsub("^Find Word %((.-)%) %b()", "%1")
		:gsub(" %(%)", "") -- empty brackets
		:gsub("%-%-[%w-_]+ ?", "") -- remove flags from `makeprg`
	return (" %s/%s %q"):format(qf.idx, #qf.items, qf.title)
end

return M
