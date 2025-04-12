-- GIT CONFLICT MARKERS
-- if there are conflicts, jump to first conflict, highlight conflict markers,
-- and disable diagnostics (simplified version of `git-conflict.nvim`)
--------------------------------------------------------------------------------

local config = {
	whenConflict = {
		disableDiagnostics = true,
		moveToFirst = true,
		detachGitsigns = true,
	},
	keys = {
		leader = "<leader>m",
		gotoMarker = "m", --> `<leader>mm`
		upstream = "u", --> `<leader>mu`, …
		base = "b",
		stashed = "s",
	},
	hlgroups = {
		borders = "Folded",
		upstream = "DiagnosticVirtualTextHint",
		base = "DiagnosticVirtualTextInfo",
		stashed = "DiagnosticVirtualTextWarn",
	},
	icons = {
		sign = "",
		main = "",
	},
}

--------------------------------------------------------------------------------

---@param msg string
---@param level? "info"|"trace"|"debug"|"warn"|"error"
local function notify(msg, level)
	if not level then level = "info" end
	local icon = config.icons.main
	vim.notify(msg, vim.log.levels[level:upper()], { title = "Merge conflict", icon = icon })
end

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
		if key == keys.gotoMarker or vim.api.nvim_get_current_line():find("<<<<*") then return rhs end

		local msg = "Needs to be on the 1st merge marker.\n"
			.. ("Use `%s` to go to the next marker."):format(keys.leader .. keys.gotoMarker)
		notify(msg, "warn")
	end, { buffer = bufnr, desc = desc, silent = true, expr = true })

	return ("[%s] %s"):format(lhs, desc)
end

--------------------------------------------------------------------------------

---@param out vim.SystemCompleted
---@param bufnr number
local function setupConflictMarkers(out, bufnr)
	if not vim.api.nvim_buf_is_valid(bufnr) then return end

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
		notify("Conflicts found but conflict style is not `diff3` or `zdiff3`. Aborting.", "warn")
		return
	end

	-- signs & highlights
	for i = 1, #conflictLnums do
		local type = ({ "upstream", "base", "stashed" })[i % 4]
		local lnum = conflictLnums[i] - 1
		local nextLnum = type and conflictLnums[i + 1] - 1

		-- borders
		local gitMarkerLength = 7
		vim.hl.range(bufnr, ns, config.hlgroups.borders, { lnum, 0 }, { lnum, gitMarkerLength })
		local typeHl = config.hlgroups[type] or config.hlgroups.stashed -- stashed on 4th border
		vim.hl.range(bufnr, ns, config.hlgroups.borders, { lnum, gitMarkerLength + 1 }, { lnum, -1 })

		-- sign column
		if type then
			-- signtext can be 2 chars wide max
			local key = config.keys[type]:sub(1)
			local sign = config.icons.sign
			if vim.api.nvim_strwidth(sign) > 1 then sign = "|" end

			vim.api.nvim_buf_set_extmark(0, ns, lnum + 1, 0, {
				sign_hl_group = typeHl,
				sign_text = sign .. key,
				invalidate = true, -- deletes the extmark if the line is deleted
				undo_restore = true, -- makes undo restore those
			})
			if nextLnum ~= lnum + 2 then
				vim.api.nvim_buf_set_extmark(0, ns, lnum + 2, 0, {
					end_row = nextLnum - 1,
					sign_hl_group = typeHl,
					sign_text = config.icons.sign,
					invalidate = true,
					undo_restore = true,
				})
			end
		end
	end

	-- toggle options
	local toggles, info = {}, {}
	if config.whenConflict.moveToFirst then
		vim.api.nvim_win_set_cursor(0, { conflictLnums[1], 0 })
	end
	if config.whenConflict.disableDiagnostics then
		vim.diagnostic.enable(false, { bufnr = bufnr })
		table.insert(toggles, "Diagnostics")
	end
	if config.whenConflict.detachGitsigns then
		-- defer, to ensure gitsigns is attached before we detach it
		vim.defer_fn(function()
			local ok, gitsigns = pcall(require, "gitsigns")
			if not ok then return end
			gitsigns.detach(bufnr)
		end, 200)
		table.insert(toggles, "Gitsigns")
	end
	if #toggles > 0 then
		local msg = "*" .. table.concat(toggles, " and ") .. " disabled in buffer.*"
		table.insert(info, msg)
	end

	-- mappings
	local mapInfo = {
		-- SOURCE https://www.reddit.com/r/neovim/comments/1h7f0bz/comment/m0ldka9/
		map(bufnr, config.keys.gotoMarker, "/<<<<*<CR>", "Goto next merge marker"),
		map(bufnr, config.keys.upstream, "dd/|||<CR>0v/>>><CR>$x", "Choose upstream (top)"),
		map(bufnr, config.keys.base, "0v/|||<CR>$x/====<CR>0v/>>><CR>$x", "Choose base (middle)"),
		map(bufnr, config.keys.stashed, "0v/====<CR>$x/>>><CR>dd", "Choose stashed (bottom)"),
	}
	vim.list_extend(info, mapInfo)

	-- notify
	local conflicts = #conflictLnums / 4
	local header = ("**%d conflict%s found.**\n"):format(conflicts, conflicts > 1 and "s" or "")
	table.insert(info, 1, header)
	notify(table.concat(info, "\n"))
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
		vim.defer_fn(function()
			if not vim.api.nvim_buf_is_valid(bufnr) then return end
			vim.b[bufnr].gitConflictRan = false
		end, 2000)

		vim.system(
			{ "git", "diff", "--check", "--", vim.api.nvim_buf_get_name(bufnr) },
			{},
			vim.schedule_wrap(function(out) setupConflictMarkers(out, bufnr) end)
		)
	end,
})
