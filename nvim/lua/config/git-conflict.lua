-- GIT CONFLICT MARKERS
-- if there are conflicts, jump to first conflict, highlight conflict markers,
-- and disable diagnostics (simplified version of `git-conflict.nvim`)
--------------------------------------------------------------------------------

local config = {
	sign = "",
	hlgroups = {
		borders = "ColorColumn",
		upstream = "DiagnosticVirtualTextHint",
		base = "DiagnosticVirtualTextInfo",
		stashed = "DiagnosticVirtualTextWarn",
	},
	keys = {
		leader = "<leader>m",
		gotoMarker = "m",
		upstream = "u",
		base = "b",
		stashed = "s",
	},
	icon = "",
}

--------------------------------------------------------------------------------

---@param bufnr number
---@param key string
---@param rhs string
---@param desc string
---@return string info
---@nodiscard
local function map(bufnr, key, rhs, desc)
	local keys = config.keys
	local lhs = (keys.leader .. key):gsub("<leader>", vim.g.mapleader)
	vim.keymap.set("n", lhs, function()
		if key == keys.gotoMarker or vim.api.nvim_get_current_line():find("<<<<*") then
			vim.opt.lazyredraw = true
			vim.defer_fn(function() vim.opt.lazyredraw = false end, 1)
			return rhs
		else
			local gotoMarker = keys.leader .. keys.gotoMarker
			local msg = "Needs to be on the first merge marker (the `<<<` line).\n"
				.. ("Use `%s` to go to the first merge marker."):format(gotoMarker)

			vim.notify(msg, vim.log.levels.WARN, { title = "Merge conflict", icon = config.icon })
		end
	end, { buffer = bufnr, desc = desc, silent = true, expr = true })
	return ("[%s] %s"):format(lhs, desc)
end

--------------------------------------------------------------------------------

---@param out vim.SystemCompleted
---@param bufnr number
local function setupConflictMarkers(out, bufnr)
	local ns = vim.api.nvim_create_namespace("conflictMarkers")
	vim.api.nvim_buf_clear_namespace(bufnr, ns, 0, -1)

	-- GUARD
	local noConflicts = out.code == 0
	local notGitRepo = vim.startswith(out.stdout, "warning: Not a git repository")
	if noConflicts or notGitRepo then return end

	-- get conflict line numbers
	local conflictLnums = {}
	for conflictLnum in out.stdout:gmatch("(%d+): leftover conflict marker") do
		table.insert(conflictLnums, tonumber(conflictLnum))
	end
	if #conflictLnums == 0 then return end
	if #conflictLnums % 4 ~= 0 then
		local msg = "Conflicts found but conflict style is not `diff3`. Aborting."
		vim.notify(msg, vim.log.levels.WARN, config.notifyOpts)
		return
	end

	-- signs & highlights
	for i = 1, #conflictLnums do
		local type = ({ "upstream", "base", "stashed" })[i % 4]
		local lnum = conflictLnums[i] - 1
		local nextLnum = type and conflictLnums[i + 1] - 1

		-- borders
		local gitMarkerLength = 7
		vim.api.nvim_buf_add_highlight(bufnr, ns, config.hlgroups.borders, lnum, 0, gitMarkerLength)
		local typeHl = config.hlgroups[type] or config.hlgroups.stashed -- stashed on 4th border
		vim.api.nvim_buf_add_highlight(bufnr, ns, typeHl, lnum, gitMarkerLength + 1, -1)

		-- signs
		if type then
			vim.api.nvim_buf_set_extmark(0, ns, lnum + 1, 0, {
				sign_hl_group = typeHl,
				sign_text = config.sign .. config.keys[type],
				invalidate = true, -- deletes the extmark if the line is deleted
				undo_restore = true, -- makes undo restore those
			})
			vim.api.nvim_buf_set_extmark(0, ns, lnum + 2, 0, {
				end_row = nextLnum - 1,
				sign_hl_group = typeHl,
				sign_text = config.sign,
				invalidate = true,
				undo_restore = true,
			})
		end
	end

	-- move to conflict & disable diagnostics
	vim.api.nvim_win_set_cursor(0, { conflictLnums[1], 0 })
	vim.diagnostic.enable(false, { bufnr = bufnr })

	-- mappings
	local installed, whichKey = pcall(require, "which-key")
	if installed then
		local group = vim.trim(config.icon .. " Merge conflict")
		whichKey.add { "<leader>m", group = group }
	end

	-- SOURCE https://www.reddit.com/r/neovim/comments/1h7f0bz/comment/m0ldka9/
	local info = {
		map(bufnr, config.keys.gotoMarker, "/<<<<*<CR>", "Goto merge marker"),
		map(bufnr, config.keys.upstream, "dd/|||<CR>0v/>>><CR>$x", "Choose upstream (top)"),
		map(bufnr, config.keys.base, "0v/|||<CR>$x/====<CR>0v/>>><CR>$x", "Choose base (middle)"),
		map(bufnr, config.keys.stashed, "0v/====<CR>$x/>>><CR>dd", "Choose stashed (bottom)"),
	}

	-- notify
	local conflicts = #conflictLnums / 4
	local header = ("%d conflict%s found."):format(conflicts, conflicts > 1 and "s" or "")
	table.insert(info, 1, header)
	vim.notify(table.concat(info, "\n"), nil, { title = "Merge conflict", icon = config.icon })
end

--------------------------------------------------------------------------------

vim.api.nvim_create_autocmd({ "BufEnter", "FocusGained" }, {
	desc = "User: Git conflict markers",
	callback = function(ctx)
		local bufnr = ctx.buf
		if not vim.api.nvim_buf_is_valid(bufnr) or vim.bo[bufnr].buftype ~= "" then return end

		-- make it idempotent, since `BufEnter` can be triggered multiple times
		if vim.b[bufnr].gitConflictRan then return end
		vim.b[bufnr].gitConflictRan = true
		vim.defer_fn(function() vim.b[bufnr].gitConflictRan = false end, 2000)

		vim.system(
			{ "git", "diff", "--check", "--", vim.api.nvim_buf_get_name(bufnr) },
			{},
			vim.schedule_wrap(function(out) setupConflictMarkers(out, bufnr) end)
		)
	end,
})
