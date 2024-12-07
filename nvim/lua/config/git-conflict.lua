-- GIT CONFLICT MARKERS
-- if there are conflicts, jump to first conflict, highlight conflict markers,
-- and disable diagnostics (simplified version of `git-conflict.nvim`)
--------------------------------------------------------------------------------

-- CONFIG
local notifyOpts = { title = "Merge conflicts", icon = "" }
local hlgroup = "DiagnosticVirtualTextInfo"

--------------------------------------------------------------------------------

---@param out vim.SystemCompleted
---@param bufnr number
local function setupConflictMarkers(out, bufnr)
	local ns = vim.api.nvim_create_namespace("conflictMarkers")
	vim.api.nvim_buf_clear_namespace(bufnr, ns, 0, -1) -- make it idempotent

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
		local msg = "Conflicts found, but not using `diff3` as conflict style. Aborting."
		vim.notify(msg, vim.log.levels.WARN, notifyOpts)
		return
	end

	-- signs & highlights
	for i = 1, #conflictLnums do
		local lnum = conflictLnums[i] - 1
		vim.api.nvim_buf_add_highlight(bufnr, ns, hlgroup, lnum, 0, -1)

		local lastMarkerOfConflict = i % 4 == 0
		if not lastMarkerOfConflict then
			local char = i % 4 == 1 and "u" or i % 4 == 2 and "b" or i % 4 == 3 and "s"
			vim.api.nvim_buf_set_extmark(0, ns, lnum, 0, {
				sign_hl_group = hlgroup,
				sign_text = "┃" .. char,
			})
			local nextLnum = conflictLnums[i + 1] - 1
			vim.api.nvim_buf_set_extmark(0, ns, lnum + 1, 0, {
				end_row = nextLnum - 1,
				sign_hl_group = hlgroup,
				sign_text = "┃",
			})
		end
	end

	-- move to conflict & disable diagnostics
	vim.api.nvim_win_set_cursor(0, { conflictLnums[1], 0 })
	vim.diagnostic.enable(false, { bufnr = bufnr })

	-- mappings
	local mapInfo = {}
	local function map(lhs, rhs, desc)
		vim.keymap.set("n", lhs, rhs, { buffer = bufnr, desc = desc })
		table.insert(mapInfo, ("%s: %s"):format(lhs, desc))
	end
	-- SOURCE https://www.reddit.com/r/neovim/comments/1h7f0bz/comment/m0ldka9/
	map("<leader>mm", "/<<<<CR>", "Goto [m]erge [m]arker")
	map("<leader>mu", "dd/|||<CR>0v/>>><CR>$x", "[m]erge [u]pstream (top)")
	map("<leader>mb", "0v/|||<CR>$x/====<CR>0v/>>><CR>$x", "[m]erge [b]ase (middle)")
	map("<leader>ms", "0v/====<CR>$x/>>><CR>dd", "[m]erge [s]tashed (bottom)")

	-- notify
	local header = ("%d conflicts found."):format(#conflictLnums / 4)
	local mapInfoStr = table.concat(mapInfo, "\n")
	vim.notify(header .. mapInfoStr, nil, notifyOpts)
end

--------------------------------------------------------------------------------

vim.api.nvim_create_autocmd({ "BufEnter", "FocusGained" }, {
	desc = "User: Git conflict markers",
	callback = function(ctx)
		local bufnr = ctx.buf
		if not vim.api.nvim_buf_is_valid(bufnr) or vim.bo[bufnr].buftype ~= "" then return end

		vim.system(
			{ "git", "diff", "--check", "--", vim.api.nvim_buf_get_name(bufnr) },
			{},
			vim.schedule_wrap(function(out) setupConflictMarkers(out, bufnr) end)
		)
	end,
})
