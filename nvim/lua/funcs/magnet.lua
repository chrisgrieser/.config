local M = {}
--------------------------------------------------------------------------------

local config = {
	currentFileIcon = "",
	maxFiles = 4,
	notificationDurationSecs = 3,
}

--------------------------------------------------------------------------------

local changedFileNotif

---@param msg string
---@param level? "info"|"trace"|"debug"|"warn"|"error"
---@param opts? table
---@return { id: number }? -- nvim-notify notification record
local function notify(msg, level, opts)
	local pluginName = " Magnet"
	if not level then level = "info" end
	opts.title = (opts and opts.title) and pluginName .. ": " .. opts.title or pluginName
	return vim.notify(msg, vim.log.levels[level:upper()], opts)
end

--------------------------------------------------------------------------------

function M.gotoChangedFiles()
	-- include new files in diff stats
	local gitLsResponse = vim.system({ "git", "ls-files", "--others", "--exclude-standard" }):wait()
	if gitLsResponse.code ~= 0 then
		notify("Not in git repo", "warn")
		return
	end
	local stdout = vim.trim(gitLsResponse.stdout)
	local newFiles = stdout ~= "" and vim.split(stdout, "\n") or {}
	for _, file in ipairs(newFiles) do
		vim.system({ "git", "add", "--intent-to-add", "--", file }):wait()
	end

	-- get numstat
	local gitResponse = vim.system({ "git", "diff", "--numstat" }):wait()
	local numstat = vim.trim(gitResponse.stdout)
	local numstatLines = vim.split(numstat, "\n")

	-- GUARD
	if numstat == "" then
		notify("No changes found.", "info")
		return
	end

	-- parameters
	local gitroot = vim.trim(vim.system({ "git", "rev-parse", "--show-toplevel" }):wait().stdout)
	local pwd = vim.uv.cwd() or ""
	local currentFile = vim.api.nvim_buf_get_name(0)

	-- Changed Files, sorted by most changes
	---@type {relPath: string, absPath: string, changes: number}[]
	local changedFiles = {}
	for _, line in pairs(numstatLines) do
		local added, deleted, file = line:match("(%d+)%s+(%d+)%s+(.+)")
		if added and deleted and file then -- exclude changed binaries
			local changes = tonumber(added) + tonumber(deleted)
			local absPath = vim.fs.normalize(gitroot .. "/" .. file)
			local relPath = absPath:sub(#pwd + 2)

			-- only add if in pwd, useful for monorepos
			if vim.startswith(absPath, pwd) then
				table.insert(changedFiles, { relPath = relPath, absPath = absPath, changes = changes })
			end
		end
	end

	-- GUARD in case of a monorepo, there can be changes outside the repo
	if #changedFiles == 0 then
		notify("No changes found in pwd.", "info")
		return
	end

	table.sort(changedFiles, function(a, b) return a.changes > b.changes end)
	changedFiles = vim.list_slice(changedFiles, 1, config.maxFiles)

	-- GUARD
	if #changedFiles == 1 and changedFiles[1].absPath == currentFile then
		notify("Already at only changed file.", "info")
		return
	end

	-- Select next file
	local nextFileIndex
	for i = 1, #changedFiles do
		if changedFiles[i].absPath == currentFile then
			nextFileIndex = math.fmod(i, #changedFiles) + 1 -- `fmod` = lua's modulo
			break
		end
	end
	if not nextFileIndex then nextFileIndex = 1 end

	local nextFile = changedFiles[nextFileIndex]
	vim.cmd.edit(nextFile.absPath)

	-----------------------------------------------------------------------------
	-- NOTIFICATION

	-- GUARD
	local notifyInstalled, notifyNvim = pcall(require, "notify")
	if not notifyInstalled then return end

	-- get width defined by user for nvim-notify to avoid overflow/wrapped lines
	-- INFO max_width can be number, nil, or function, see https://github.com/chrisgrieser/nvim-tinygit/issues/6#issuecomment-1999537606
	local _, notifyConfig = notifyNvim.instance() ---@diagnostic disable-line: missing-parameter
	local width = 50
	if notifyConfig and notifyConfig.max_width then
		local max_width = type(notifyConfig.max_width) == "number" and notifyConfig.max_width
			or notifyConfig.max_width()
		width = max_width - 9 -- padding, border, prefix & space, ellipsis
	end

	local listOfChangedFiles = {}
	for i = 1, #changedFiles do
		local prefix = (i == nextFileIndex and config.currentFileIcon or "·")
		local path = changedFiles[i].relPath
		-- +2 for prefix + space
		local displayPath = #path + 2 > width and "…" .. path:sub(-1 - width) or path
		table.insert(listOfChangedFiles, prefix .. " " .. displayPath)
	end
	local msg = table.concat(listOfChangedFiles, "\n")

	changedFileNotif = notify(msg, "info", {
		title = "Changed files",
		replace = changedFileNotif and changedFileNotif.id,
		animate = false,
		timeout = config.notificationDurationSecs * 1000,
		hide_from_history = true,
		on_open = function(win)
			local bufnr = vim.api.nvim_win_get_buf(win)
			vim.api.nvim_buf_call(
				bufnr,
				function() vim.fn.matchadd("Title", config.currentFileIcon .. ".*") end
			)
		end,
	})
end

--------------------------------------------------------------------------------
return M
