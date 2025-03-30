local keymap = require("config.utils").uniqueKeymap
--------------------------------------------------------------------------------
-- KEYMAPS in regular window

-- `:cnext`, but wrapping, not throwing errors, and notifying if an item was deleted
keymap("n", "gq", "]q", { desc = "󰒭 Next quickfix" })

keymap("n", "gQ", "[q", { desc = "󰒮 Prev quickfix", remap = true })

keymap("n", "<leader>qd", function() vim.cmd.cexpr("[]") end, { desc = "󰚃 Delete list" })

keymap("n", "<leader>qq", function()
	local windows = vim.fn.getwininfo()
	local hasQuickfix = vim.iter(windows):any(function(win) return win.quickfix == 1 end)
	vim.cmd[hasQuickfix and "cclose" or "copen"]()
end, { desc = " Toggle window" })

--------------------------------------------------------------------------------
-- KEYMAPS in quickfix window

vim.api.nvim_create_autocmd("FileType", {
	desc = "User: Set keymaps for quickfix window",
	pattern = "qf",
	callback = function(ctx)
		vim.keymap.set(
			"n",
			"q",
			vim.cmd.close,
			{ desc = " Close", buffer = ctx.buf, nowait = true }
		)
		vim.keymap.set("n", "dd", function()
			local qfItems = vim.fn.getqflist()
			local lnum = vim.api.nvim_win_get_cursor(0)[1]
			table.remove(qfItems, lnum)
			vim.fn.setqflist(qfItems, "r") -- "r" = replace = overwrite
			vim.api.nvim_win_set_cursor(0, { lnum, 0 })
		end, { desc = " Remove quickfix entry", buffer = ctx.buf })
	end,
})

--------------------------------------------------------------------------------
-- ADD SIGNS

vim.api.nvim_create_autocmd("QuickFixCmdPost", {
	desc = "User: Add signs to quickfix (1/2)",
	callback = function()
		local ns = vim.api.nvim_create_namespace("quickfix-signs")

		local function setSigns(qf)
			vim.api.nvim_buf_set_extmark(qf.bufnr, ns, qf.lnum - 1, 0, {
				sign_text = "󱘹▶",
				sign_hl_group = "DiagnosticSignInfo",
				priority = 200, -- above most signs
				invalidate = true, -- deletes the extmark if the line is deleted
				undo_restore = true, -- makes undo restore those
			})
		end

		-- clear existing signs/autocmds
		local group = vim.api.nvim_create_augroup("quickfix-signs", { clear = true })
		vim.iter(vim.api.nvim_list_bufs())
			:each(function(bufnr) vim.api.nvim_buf_clear_namespace(bufnr, ns, 0, -1) end)

		-- set signs
		for _, qf in pairs(vim.fn.getqflist()) do
			if vim.api.nvim_buf_is_loaded(qf.bufnr) then
				setSigns(qf)
			else
				vim.api.nvim_create_autocmd("BufReadPost", {
					desc = "User(once): Add signs to quickfix (2/2)",
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
-- AUTOMATICALLY GOTO 1ST ITEM

vim.api.nvim_create_autocmd("QuickFixCmdPost", {
	desc = "User: Automatically goto 1st quickfix item",
	callback = function()
		-- `pcall` as event also triggered on empty quickfix, where `:cfirst` fails
		vim.defer_fn(function() pcall(vim.cmd.cfirst) end, 100)
	end,
})

--------------------------------------------------------------------------------
-- STATUSBAR (COUNT OF ITEMS)
local M = {}

function M.quickfixCounterStatusbar()
	local qf = vim.fn.getqflist { idx = 0, title = true, items = true }
	if #qf.items == 0 then return "" end

	-- remove empty brackets and/or flags from `makeprg`
	local title = qf.title:gsub(" %(%)", ""):gsub("%-%-[%w-_]+ ?", "")

	return (" %d/%d %q"):format(qf.idx, #qf.items, title)
end

return M
