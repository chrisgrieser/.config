local keymap = require("config.utils").uniqueKeymap
--------------------------------------------------------------------------------
-- KEYMAPS in regular window

keymap("n", "gq", function()
	local opts = { title = "Quickfix", icon = "" }
	local qf = vim.fn.getqflist { idx = 0, items = true }
	local atEnd = qf.idx == #qf.items
	if atEnd then vim.notify("Wrapped.", vim.log.levels.TRACE, opts) end

	local msg = vim.fn.execute(atEnd and "cfirst" or "cnext")
	vim.notify(vim.inspect(msg), nil, { title = "🖨️ msg", ft = "lua" })
	-- local deletedIdx = msg:match("%(line deleted%)")
	-- if msg:find("%(line deleted%)") then
	-- 	vim.notify(("Item %s deleted."):format(idx), vim.log.levels.TRACE, opts)
	-- end
end, { desc = " Next quickfix" })

keymap("n", "gQ", function() vim.cmd("silent! cprev") end, { desc = " Prev quickfix" })

keymap("n", "<leader>qc", function() vim.cmd.cexpr("[]") end, { desc = " Clear quickfix list" })

keymap("n", "<leader>qq", function()
	local windows = vim.fn.getwininfo()
	local hasQuickfix = vim.iter(windows):any(function(win) return win.quickfix == 1 end)
	vim.cmd[hasQuickfix and "cclose" or "copen"]()
end, { desc = " Toggle quickfix window" })

--------------------------------------------------------------------------------
-- KEYMAPS in quickfix window

vim.api.nvim_create_autocmd("FileType", {
	desc = "User: Set keymaps in quickfix window",
	pattern = "qf",
	callback = function(ctx)
		vim.keymap.set("n", "q", vim.cmd.close, { desc = " Close", buffer = ctx.buf })
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

local quickfixSign = "" -- CONFIG
vim.api.nvim_create_autocmd("QuickFixCmdPost", {
	desc = "User: Add signs to quickfix (1/2)",
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
-- STATUSBAR: COUNT OF ITEMS

local M = {}

function M.quickfixCounterStatusbar()
	local qf = vim.fn.getqflist { idx = 0, title = true, items = true }
	if #qf.items == 0 then return "" end

	-- prettify title output
	local title = qf
		.title
		:gsub("^Live Grep: .-%((.+)%)", "%1") -- remove telescope prefixes to save space
		:gsub("^Find Files: .-%((.+)%)", "%1")
		:gsub("^Find Word %((.-)%) %b()", "%1")
		:gsub(" %(%)", "") -- empty brackets
		:gsub("%-%-[%w-_]+ ?", "") -- remove flags from `makeprg`
	return (" %s/%s %q"):format(qf.idx, #qf.items, title)
end

return M
