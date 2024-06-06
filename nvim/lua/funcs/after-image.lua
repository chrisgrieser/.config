local M = {}
--------------------------------------------------------------------------------

local config = {
	highlightDurationMs = 2000,
	highlightGroup = "DiffText",
}

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

function M.addSigns()
	local changes = getLinesChangedInLastCommit()
	if not changes then return end
	for _, change in ipairs(changes) do
		vim.sign_place(0, "GitSigns", "GitSignsChange", 0, { lnum = change.start, priority = 10 })
	end
end

function M.gotoLastCommittedChangeInFile()
	local changes = getLinesChangedInLastCommit()
	if not changes then return end
	local firstChange = changes[1]

	-- goto beginning of first last change
	vim.api.nvim_win_set_cursor(0, { firstChange.start, 0 })

	-- highlight changed lines
	local ns = vim.api.nvim_create_namespace("lastCommittedChange")
	local changeEnd = firstChange.start + firstChange.length
	vim.highlight.range(0, ns, config.highlightGroup, { firstChange.start - 1, 0 }, { changeEnd, 0 })
	vim.defer_fn(
		function() vim.api.nvim_buf_clear_namespace(0, ns, 0, -1) end,
		config.highlightDurationMs
	)
end

--------------------------------------------------------------------------------
return M
