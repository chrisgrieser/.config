--[[ INFO NVIM-MAGNET
1.`.gotoAltFile()` as an improved version of `:buffer #` that avoids special
  buffers, deleted buffers, non-existent files etc. and falls back
  to the first oldfile, if there is currently only one buffer.
2.`.gotoMostChangedFile` to go to the file in the cwd with the most git changes.
3.`.altFileStatusbar()` and `.mostChangedFileStatusbar()` to display the
  respective file in the statusbar. If there is no alt-file, the first oldfile
  is shown. If there is no changed file, nothing is shown.]]

local config = {
	statusbar = {
		maxLength = 30,
		hideMostChangedIfSameAsAltFile = true,
	},
	icons = {
		notification = "",
		oldFile = "󰋚",
		altBuf = "󰐤",
		mostChangedFile = "󰓏",
	},
	ignore = { -- literal match in whole path
		oldfiles = {
			"/COMMIT_EDITMSG",
			vim.fn.stdpath("data"),
		},
		mostChangedFiles = {
			"/info.plist", -- Alfred
			"/prefs.plist", -- Alfred
			"lazy-lock.json", -- lazy.nvim
		},
	},
}

---HELPERS----------------------------------------------------------------------
local M = {}

---@param path string
---@param oneOf string[]
---@return boolean
local function literalMatchesOneOf(path, oneOf)
	return vim.iter(oneOf):any(function(p) return path:find(p, nil, true) ~= nil end)
end

---@param msg string
---@param level? "info"|"trace"|"debug"|"warn"|"error"
local function notify(msg, level)
	if not level then level = "info" end
	local lvl = vim.log.levels[level:upper()]
	vim.notify(msg, lvl, { title = "Magnet", icon = config.icons.notification })
end

---@param path string
---@return string
local function fmtPathForStatusbar(path)
	local displayName = vim.fs.basename(path)

	-- add parent if displayname is same as basename of current file
	local currentBasename = vim.fs.basename(vim.api.nvim_buf_get_name(0))
	if currentBasename == displayName then
		local parent = vim.fs.basename(vim.fs.dirname(path))
		displayName = parent .. "/" .. displayName
	end

	-- truncate
	local maxLength = config.statusbar.maxLength
	if #displayName > maxLength then
		displayName = displayName:sub(1, maxLength)
		displayName = vim.trim(displayName) .. "…"
	end

	return displayName
end

---GET FILES--------------------------------------------------------------------
---@return string? altBufferName ; nil if no alt buffer
---@nodiscard
local function getAltBuffer()
	local listedBufs = vim.fn.getbufinfo { buflisted = 1 }
	if listedBufs == 1 then return end

	-- manually retrieving altbuf instead of `bufnr("#")` to avoid various
	-- issues like: special buffer, altbuf being the current one, altbuf being
	-- recently closed(= not listed), etc.
	table.sort(listedBufs, function(a, b) return a.lastused > b.lastused end)
	local altBuf = vim.iter(listedBufs):find(function(buf)
		local valid = vim.api.nvim_buf_is_valid(buf.bufnr)
		local nonSpecial = vim.bo[buf.bufnr].buftype == ""
			and vim.bo[buf.bufnr].buftype ~= "help"
			and buf.name ~= ""
		local notCurrent = vim.api.nvim_get_current_buf() ~= buf.bufnr
		return valid and nonSpecial and notCurrent
	end)
	if not altBuf then return end

	return altBuf.name
end

---get the alternate oldfile, accounting for non-existing files
---@return string|nil oldfile; nil if none exists in all oldfiles
---@nodiscard
local function getAltOldfile()
	local curPath = vim.api.nvim_buf_get_name(0)
	for _, path in ipairs(vim.v.oldfiles) do
		local exists = vim.uv.fs_stat(path) ~= nil
		local sameFile = path == curPath
		local ignoredInConfig = literalMatchesOneOf(path, config.ignore.oldfiles)
		if exists and not ignoredInConfig and not sameFile then return path end
	end
end

---@return string? filepath
---@return string? errmsg
local function getMostChangedFile()
	local gitRoot = vim.system({ "git", "rev-parse", "--show-toplevel" }):wait()
	if gitRoot.code ~= 0 or not gitRoot.stdout then return nil, "Not in git repo." end
	local gitRootPath = vim.trim(gitRoot.stdout)

	-- ensure untracked files are included in the diff stat
	local gitLsResponse = vim.system({ "git", "ls-files", "--others", "--exclude-standard" }):wait()
	local newFiles = gitLsResponse ~= "" and vim.split(gitLsResponse.stdout, "\n") or {}
	for _, file in ipairs(newFiles) do
		vim.system({ "git", "add", "--intent-to-add", "--", file }):wait()
	end

	-- get list of changed files
	local gitResponse = vim.system({ "git", "-C", gitRootPath, "diff", "--numstat" }):wait()
	local changedFiles = vim.split(gitResponse.stdout, "\n", { trimempty = true })
	if #changedFiles == 0 then return nil, "No files with changes found." end

	-- identify file with most changes
	local mostChangedFile = vim.iter(changedFiles):fold({}, function(mostChanges, line)
		local linesAdded, linesDeleted, relPath = line:match("(%d+)%s+(%d+)%s+(.+)")
		local isBinary = not (linesAdded and linesDeleted and relPath)
		if isBinary then return mostChanges end

		relPath = relPath:gsub("{.+ => (.+)}", "%1") -- handle renames
		local absPath = vim.fs.joinpath(gitRootPath, relPath)
		local ignoredInConfig = literalMatchesOneOf(absPath, config.ignore.mostChangedFiles)
		local fileDeleted = vim.uv.fs_stat(absPath) == nil
		if ignoredInConfig or fileDeleted then return mostChanges end

		local linesChanged = tonumber(linesAdded) + tonumber(linesDeleted)
		if linesChanged > (mostChanges.lines or 0) then
			mostChanges.lines = linesChanged
			mostChanges.path = absPath
		end
		return mostChanges
	end)

	if mostChangedFile.path then
		return mostChangedFile.path, nil
	else
		return nil, "No changed file that is not ignored, deleted, or binary."
	end
end

---GOTO COMMANDS----------------------------------------------------------------
function M.gotoAltFile()
	if vim.bo.buftype ~= "" then return notify("Cannot do that in special buffer.", "warn") end

	local altFile = getAltBuffer() or getAltOldfile()
	if altFile then
		vim.cmd.edit(altFile)
	else
		notify("No alt-buffer or oldfile available.", "warn")
	end
end

function M.gotoMostChangedFile()
	local targetFile, errmsg = getMostChangedFile()
	if errmsg then return notify(errmsg, "warn") end

	local currentFile = vim.api.nvim_buf_get_name(0)
	if targetFile == currentFile then
		notify("Already at the most changed file.", "trace")
	else
		vim.cmd.edit(targetFile)
	end
end

---STATUSBAR--------------------------------------------------------------------
vim.api.nvim_create_autocmd({ "BufEnter", "FocusGained" }, {
	desc = "Magnet: cache most changed file for statusbar",
	group = vim.api.nvim_create_augroup("MagnetStatusbar", { clear = true }),
	callback = function()
		-- defer to prevent race conditions with auto-rooting plugins
		vim.defer_fn(function() vim.b.magnet_mostChangedFile = getMostChangedFile() end, 10)
	end,
})

---@return string
---@nodiscard
function M.mostChangedFileStatusbar()
	local targetFile = vim.b.magnet_mostChangedFile
	if not targetFile then return "" end

	-- do not show if most changed file is same as current file or alt file
	local currentFile = vim.api.nvim_buf_get_name(0)
	if targetFile == currentFile then return "" end
	local altFile = getAltBuffer() or getAltOldfile()
	if targetFile == altFile and config.statusbar.hideMostChangedIfSameAsAltFile then return "" end

	local icon = config.icons.mostChangedFile
	return vim.trim(icon .. " " .. fmtPathForStatusbar(targetFile))
end

---@return string
---@nodiscard
function M.altFileStatusbar()
	local altBuf = getAltBuffer()
	local altFile = altBuf or getAltOldfile()
	if not altFile then return "" end -- e.g., when shada was deleted

	-- add most changed file icon if it's the same file
	local icon = altBuf and config.icons.altBuf or config.icons.oldFile
	if altFile == vim.b.magnet_mostChangedFile then
		icon = config.icons.mostChangedFile .. " " .. icon
	end
	return vim.trim(icon .. " " .. fmtPathForStatusbar(altFile))
end

--------------------------------------------------------------------------------
return M
