local M = {}
--------------------------------------------------------------------------------

local config = {
	sign = "󰋚",
	numberHighlight = "DiagnosticSignHint",
	signHighlight = "DiagnosticSignHint",
	lineHighlight = "DiagnosticVirtualTextHint",
	moveToFirstOnShowingSigns = true,
}

local ns = vim.api.nvim_create_namespace("after-image-signs")
--------------------------------------------------------------------------------

---@param msg string
---@param level? "info"|"trace"|"debug"|"warn"|"error"
local function notify(msg, level)
	if not level then level = "info" end
	vim.notify(msg, vim.log.levels[level:upper()], { title = "Git" })
end

--------------------------------------------------------------------------------
---@return {start: number, length: number}[]?
local function getLinesChangedInLastCommit()
	local file = vim.api.nvim_buf_get_name(0)
	-- stylua: ignore
	local cmd = { "git", "--no-pager", "log", "--max-count=1", "--patch", "--unified=0", "--format=", "--", file }
	local result = vim.system(cmd):wait()
	if result.code ~= 0 then
		notify(result.stderr or "", "error")
		return
	elseif result.stdout == "" then
		notify("File has not last committed change.", "warn")
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

function M.toggleSigns()
	-- disable
	if vim.b.afterImage_showSigns then
		vim.api.nvim_buf_clear_namespace(0, ns, 0, -1)
		vim.b.afterImage_showSigns = false
		return
	end

	-- enable
	local changes = getLinesChangedInLastCommit()
	if not changes then return end
	vim.b.afterImage_showSigns = true

	if config.moveToFirstOnShowingSigns then
		vim.api.nvim_win_set_cursor(0, { changes[1].start, 0 })
	end

	for _, change in ipairs(changes) do
		local hunk = vim.api.nvim_buf_set_extmark(0, ns, change.start - 1, 0, {
			end_row = change.start + change.length - 1,
			sign_text = config.sign,
			sign_hl_group = config.signHighlight,
			number_hl_group = config.numberHighlight,
			line_hl_group = config.lineHighlight,
			hl_mode = "combine",
		})
	end
end

function M.gotoNext()
	local hunksInNs = vim.api.nvim_buf_get_extmarks(0, ns, 0, -1, { details = true })
	vim.notify("⭕ hunks: " .. vim.inspect(hunksInNs))
end

--------------------------------------------------------------------------------
return M
