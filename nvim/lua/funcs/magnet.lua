local M = {}
--------------------------------------------------------------------------------

local config = {
	currentFileIcon = "",
	bufferByLastUsed = {
		timeoutSecs = 3,
		maxBufAgeMins = 10,
	},
	gotoChangedFiles = {
		maxFiles = 4,
	},
	altFile = {
		statusbarMaxDisplayLen = 25,
	},
}

--------------------------------------------------------------------------------

---@param msg string
---@param level? "info"|"trace"|"debug"|"warn"|"error"
---@param extraOpts? table
---@return { id: number }? -- nvim-notify notification record
local function notify(msg, level, extraOpts)
	if not level then level = "info" end
	local opts = vim.tbl_extend("force", { title = "Magnet" }, extraOpts or {})
	return vim.notify(msg, vim.log.levels[level:upper()], opts)
end

---@nodiscard
---@param path string
local function fileExists(path) return vim.uv.fs_stat(path) ~= nil end

--------------------------------------------------------------------------------

---@param altBufnr integer
---@return boolean
local function hasAltFile(altBufnr)
	if altBufnr < 0 then return false end
	local valid = vim.api.nvim_buf_is_valid(altBufnr)
	local nonSpecial = vim.api.nvim_get_option_value("buftype", { buf = altBufnr }) == ""
	local moreThanOneBuffer = #(vim.fn.getbufinfo { buflisted = 1 }) > 1
	local currentBufNotAlt = vim.api.nvim_get_current_buf() ~= altBufnr -- fixes weird vim bug
	local altFileExists = fileExists(vim.api.nvim_buf_get_name(altBufnr))

	return valid and nonSpecial and moreThanOneBuffer and currentBufNotAlt and altFileExists
end

---get the alternate oldfile, accounting for non-existing files
---@nodiscard
---@return string|nil path of oldfile, nil if none exists in all oldfiles
local function altOldfile()
	local curPath = vim.api.nvim_buf_get_name(0)
	for _, path in ipairs(vim.v.oldfiles) do
		if fileExists(path) and not path:find("/COMMIT_EDITMSG$") and path ~= curPath then
			return path
		end
	end
	return nil
end

---shows name & icon of alt buffer. If there is none, show first alt-oldfile.
---@return string
function M.altFileStatus()
	local altBufNr = vim.fn.bufnr("#")
	local altOld = altOldfile()
	local icon = "#"
	local name

	if hasAltFile(altBufNr) then
		local altPath = vim.api.nvim_buf_get_name(altBufNr)
		local altFile = vim.fs.basename(altPath)
		name = altFile ~= "" and altFile or "[No Name]"
		-- icon
		local ext = altFile:match("%w+$")
		local altBufFt = vim.api.nvim_get_option_value("filetype", { buf = altBufNr })
		local ok, devicons = pcall(require, "nvim-web-devicons")
		if ok then icon = devicons.get_icon(altFile, ext) or devicons.get_icon(altFile, altBufFt) end

		-- name: consider if alt and current file have same basename
		local curFile = vim.fs.basename(vim.api.nvim_buf_get_name(0))
		local currentAndAltWithSameBasename = curFile == altFile
		if currentAndAltWithSameBasename then
			local altParent = vim.fs.basename(vim.fs.dirname(altPath))
			name = altParent .. "/" .. altFile
		end
	elseif altOld then
		icon = "󰋚"
		name = vim.fs.basename(altOld)
	else
		return "???"
	end

	-- truncate
	local nameNoExt = name:gsub("%.%w+$", "")
	local max = config.altFile.statusbarMaxDisplayLen
	if #nameNoExt > max then
		local ext = name:match("%.%w+$")
		name = nameNoExt:sub(1, max) .. "…" .. ext
	end
	return icon .. " " .. name
end

---switch to alternate buffer/oldfile (in that priority)
function M.gotoAltBuffer()
	if vim.bo.buftype ~= "" then return end -- deactivate if in a special buffer

	if hasAltFile(vim.fn.bufnr("#")) then
		vim.cmd.buffer("#")
		return
	end
	local altOld = altOldfile()
	if altOld then
		vim.cmd.edit(altOld)
		return
	end
	notify("No Alt-File or Oldfile available.", "warn")
end

--------------------------------------------------------------------------------

---@class (exact) bufNavState
---@field bufsByLastAccess table[]
---@field bufNavNotify { id: number }
---@field timeoutTimer table
local state = {}

---@param dir "next"|"prev"
function M.bufferByLastUsed(dir)
	local opts = config.bufferByLastUsed

	-- GET BUFFERS SORTED BY LAST ACCESS
	-- timeout required, as switching to buffer always makes it the last accessed one
	if state.timeoutTimer then state.timeoutTimer:stop() end
	local timeoutMs = opts.timeoutSecs * 1000
	state.timeoutTimer = vim.defer_fn(function() state.bufsByLastAccess = nil end, timeoutMs)

	if not state.bufsByLastAccess then
		---@type {name: string, lastused: number}[]
		state.bufsByLastAccess = vim.iter(vim.fn.getbufinfo { buflisted = 1 })
			:filter(function(buf) return (os.time() - buf.lastused) < opts.maxBufAgeMins * 60 end)
			:totable()
		table.sort(state.bufsByLastAccess, function(a, b) return a.lastused > b.lastused end)
		state.bufsByLastAccess = vim.list_slice(state.bufsByLastAccess, 1, opts.maxBufs)
	end
	if #state.bufsByLastAccess < 2 then
		state.bufsByLastAccess = nil
		notify("Only one buffer open.", "warn")
		return
	end

	-- DETERMINE NEXT BUFFER
	local currentBuf = vim.api.nvim_buf_get_name(0)
	local currentBufIdx
	for i = 1, #state.bufsByLastAccess do
		if state.bufsByLastAccess[i].name == currentBuf then
			currentBufIdx = i
			break
		end
	end
	local nextBufIdx
	if dir == "prev" then
		nextBufIdx = currentBufIdx - 1
		if nextBufIdx < 1 then nextBufIdx = #state.bufsByLastAccess end
	else
		nextBufIdx = currentBufIdx + 1
		if nextBufIdx > #state.bufsByLastAccess then nextBufIdx = 1 end
	end
	local nextBufName = state.bufsByLastAccess[nextBufIdx].name
	vim.cmd.edit(nextBufName)

	-----------------------------------------------------------------------------
	-- NOTIFICATION: DISPLAY BUFFER-LIST

	if not package.loaded["notify"] then return end

	local bufsDisplay = vim.iter(state.bufsByLastAccess)
		:map(function(buf)
			local prefix = nextBufName == buf.name and config.currentFileIcon or "•"
			local minsAgo = math.ceil((os.time() - buf.lastused) / 60)
			local name = vim.fs.basename(buf.name)
			if minsAgo < 2 then return prefix .. " " .. name end
			return ("%s %s (%s mins)"):format(prefix, name, minsAgo)
		end)
		:rev()
		:totable()
	table.insert(bufsDisplay, 1, table.remove(bufsDisplay)) -- move current buffer to top

	---@diagnostic disable-next-line: assign-type-mismatch
	state.bufNavNotify = notify(table.concat(bufsDisplay, "\n"), "info", {
		title = "Magnet: Last Used Buffers",
		timeout = timeoutMs,
		animate = false,
		stages = "no_animation",
		hide_from_history = true,
		replace = state.bufNavNotify and state.bufNavNotify.id,
		on_open = function(win)
			local bufnr = vim.api.nvim_win_get_buf(win)
			vim.api.nvim_buf_call(bufnr, function()
				vim.fn.matchadd("Title", config.currentFileIcon .. ".*")
				vim.fn.matchadd("Comment", [[ (\d+ mins)]])
			end)
		end,
	})
end

--------------------------------------------------------------------------------

local changedFileNotif
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
	table.sort(changedFiles, function(a, b) return a.changes > b.changes end)
	changedFiles = vim.list_slice(changedFiles, 1, config.gotoChangedFiles.maxFiles)

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
		title = "Magnet: Changed Files",
		replace = changedFileNotif and changedFileNotif.id,
		animate = false,
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
