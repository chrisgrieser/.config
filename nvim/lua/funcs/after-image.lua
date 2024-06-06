local M = {}
--------------------------------------------------------------------------------

local defaultConfig = {
	signText = "",
	signHighlight = "DiagnosticSignHint",
	signPriority = 5, -- 6 is the priority of GitSigns, and we want to be lower
	numberHighlight = "DiagnosticSignHint",
}
local config = defaultConfig

local ns = vim.api.nvim_create_namespace("after-image-signs")
--------------------------------------------------------------------------------

---@param msg string
---@param level? "info"|"trace"|"debug"|"warn"|"error"
local function notify(msg, level)
	if not level then level = "info" end
	vim.notify(msg, vim.log.levels[level:upper()], { title = "Git" })
end

--------------------------------------------------------------------------------

---@nodiscard
---@param silent? "silent"
---@return {start: number, length: number}[]?
local function getLinesChangedInLastCommit(silent)
	local file = vim.api.nvim_buf_get_name(0)
	-- stylua: ignore
	local cmd = { "git", "log", "--max-count=1", "--patch", "--unified=0", "--format=", "--", file }
	local result = vim.system(cmd):wait()
	if result.code ~= 0 then
		if not silent then notify(result.stderr or "", "error") end
		return
	elseif result.stdout == "" then
		if not silent then notify("File has not last committed change.", "warn") end
		return
	end
	-- INFO meaning of the `@@` lines: https://stackoverflow.com/a/31615728/22114136
	local linesChanged = vim.iter(vim.split(result.stdout, "\n"))
		:filter(function(line) return vim.startswith(line, "@@ ") end)
		:map(function(line)
			local start, length = line:match("%+(%d+),(%d+)")
			if not start then
				start, length = line:match("%+(%d+)"), 0
			end
			return { start = tonumber(start), length = tonumber(length) }
		end)
		:totable()
	return linesChanged
end

---@param bufnr? number
---@param silent? "silent"
function M.toggleSigns(bufnr, silent)
	bufnr = bufnr or 0

	-- disable
	if vim.b[bufnr].afterImage_showSigns then
		vim.api.nvim_buf_clear_namespace(0, ns, 0, -1)
		vim.b[bufnr].afterImage_showSigns = false
		return
	end

	-- enable
	local changes = getLinesChangedInLastCommit(silent)
	if not changes then return end
	vim.b[bufnr].afterImage_showSigns = true

	for _, change in ipairs(changes) do
		vim.api.nvim_buf_set_extmark(bufnr, ns, change.start - 1, 0, {
			end_row = change.start + change.length - 1,
			sign_text = config.signText,
			sign_hl_group = config.signHighlight,
			number_hl_group = config.numberHighlight,
			priority = config.signPriority,
		})
	end
end

function M.gotoNext()
	local hunkStartLnums
	if vim.b.afterImage_showSigns then
		-- get from signs, as they move with changes in buffer
		hunkStartLnums = vim.tbl_map(
			function(extmark) return extmark[2] + 1 end,
			vim.api.nvim_buf_get_extmarks(0, ns, 0, -1, {})
		)
	else
		-- get from git itself (less accurate)
		hunkStartLnums = vim.tbl_map(
			function(change) return change.start end,
			getLinesChangedInLastCommit() or {}
		)
	end
	if #hunkStartLnums == 0 then
		notify("No hunks found.", "warn")
		return
	end

	local currentLnum = vim.api.nvim_win_get_cursor(0)[1]
	local nextLnum = vim.iter(hunkStartLnums):find(function(lnum) return lnum > currentLnum end)
		or hunkStartLnums[1] -- wrap to first hunk
	vim.api.nvim_win_set_cursor(0, { nextLnum, 0 })
end

--------------------------------------------------------------------------------
return M
