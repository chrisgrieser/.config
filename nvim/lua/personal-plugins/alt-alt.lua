--[[ INFO ALT-ALT
Alternative to vim's "alternative file" that improves its functionality.

1.`.gotoAltFile()` as an improved version of `:buffer #` that avoids special
  buffers, deleted buffers, non-existent files etc. and falls back
  to the first oldfile, if there is currently only one buffer.
2.`.gotoMostChangedFile` to go to the file in the cwd with the most git changes
3.`.altFileStatusbar()` and `.mostChangedFileStatusbar()` to display the
  respective file in the statusbar. If there is no alt-file, the first oldfile
  is shown. If there is not changed file, nothing is shown.
]]
--------------------------------------------------------------------------------

local config = {
	statusbar = {
		maxLength = 30,
		-- show most changed file even if it is the same as the current file or the alt file
		showMostChangedIfRedundant = false,
	},
	icons = {
		oldFile = "󰋚",
		altBuf = "󰐤",
		mostChangedFile = "󰓏",
	},
	ignore = { -- literal match in whole path
		oldfiles = {
			"/COMMIT_EDITMSG",
		},
		mostChangedFiles = {
			"/info.plist", -- Alfred
			"/prefs.plist", -- Alfred
			require("lazy.core.config").options.lockfile,
		},
	},
}

local installed, snacksScratch = pcall(require, "plugin-specs.snacks-scratch")
if installed then table.insert(config.ignore.oldfiles, snacksScratch.opts.scratch.root) end ---@diagnostic disable-line: undefined-field

--------------------------------------------------------------------------------
local M = {}

---@param path string
---@param oneOff string[]
local function matchesOneOf(path, oneOff)
	return vim.iter(oneOff):any(function(p) return path:find(p, nil, true) ~= nil end)
end

---@param msg string
---@param level? "info"|"trace"|"debug"|"warn"|"error"
---@param icon string
local function notify(msg, level, icon)
	if not level then level = "info" end
	local lvl = vim.log.levels[level:upper()]

	vim.notify(msg, lvl, { title = "Alt-alt", icon = icon })
end

---@return string|nil altBufferName, nil if no alt buffer
---@nodiscard
local function getAltBuffer()
	local altBufnr = vim.fn.bufnr("#")
	if altBufnr < 0 then return end
	local valid = vim.api.nvim_buf_is_valid(altBufnr)
	local nonSpecial = vim.bo[altBufnr].buftype == "" or vim.bo[altBufnr].buftype == "help"
	local moreThanOneBuffer = #(vim.fn.getbufinfo { buflisted = 1 }) > 1
	local currentBufNotAlt = vim.api.nvim_get_current_buf() ~= altBufnr -- fixes weird vim bug
	local altBufExists = vim.uv.fs_stat(vim.api.nvim_buf_get_name(altBufnr)) ~= nil

	if valid and nonSpecial and moreThanOneBuffer and currentBufNotAlt and altBufExists then
		return vim.api.nvim_buf_get_name(altBufnr)
	end
end

---get the alternate oldfile, accounting for non-existing files
---@return string|nil oldfile; nil if none exists in all oldfiles
---@nodiscard
local function getAltOldfile()
	local curPath = vim.api.nvim_buf_get_name(0)
	for _, path in ipairs(vim.v.oldfiles) do
		local exists = vim.uv.fs_stat(path) ~= nil
		local sameFile = path == curPath
		local ignoredInConfig = matchesOneOf(path, config.ignore.oldfiles)
		if exists and not ignoredInConfig and not sameFile then return path end
	end
end

---@return string? filepath
---@return string? errmsg
local function getMostChangedFile()
	local gitRoot = vim.system({ "git", "rev-parse", "--show-toplevel" }):wait()
	if gitRoot.code ~= 0 or not gitRoot.stdout then return nil, "Not in git repo." end
	local gitRootPath = vim.trim(gitRoot.stdout)

	-- get list of changed files
	local gitResponse = vim.system({ "git", "-C", gitRootPath, "diff", "--numstat" }):wait()
	local changedFiles = vim.split(gitResponse.stdout, "\n", { trimempty = true })
	if #changedFiles == 0 then return nil, "No files with changes found." end

	-- identify file with most changes
	local targetFile
	local mostChanges = 0
	vim.iter(changedFiles):each(function(line)
		local linesAdded, linesDeleted, relPath = line:match("(%d+)%s+(%d+)%s+(.+)")
		local isBinary = not (linesAdded and linesDeleted and relPath)
		if isBinary then return end

		local absPath = vim.fs.normalize(gitRootPath .. "/" .. relPath)
		local ignoredInConfig = matchesOneOf(absPath, config.ignore.mostChangedFiles)
		local deleted = vim.uv.fs_stat(absPath) == nil
		if ignoredInConfig or deleted then return end

		local linesChanged = tonumber(linesAdded) + tonumber(linesDeleted)
		if linesChanged > mostChanges then
			mostChanges = linesChanged
			targetFile = absPath
		end
	end)
	if not targetFile then return nil, "All changed files either ignored, deleted, or binaries." end

	return targetFile, nil
end

---@param path string
---@return string
local function nameForStatusbar(path)
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

--------------------------------------------------------------------------------

function M.gotoAltFile()
	if vim.bo.buftype ~= "" then
		notify("Cannot do that in special buffer.", "warn", config.icons.altBuf)
		return
	end
	local altBuf, altOld = getAltBuffer(), getAltOldfile()

	if altBuf then
		vim.api.nvim_set_current_buf(vim.fn.bufnr("#"))
	elseif altOld then
		vim.cmd.edit(altOld)
	else
		notify("No alt file or oldfile available.", "error", config.icons.altFile)
	end
end

function M.gotoMostChangedFile()
	local targetFile, errmsg = getMostChangedFile()
	if errmsg then
		notify(errmsg, "warn", config.icons.mostChangedFile)
		return
	end

	local currentFile = vim.api.nvim_buf_get_name(0)
	if targetFile == currentFile then
		notify("Already at the most changed file.", "trace", config.icons.mostChangedFile)
	else
		vim.cmd.edit(targetFile)
	end
end

--------------------------------------------------------------------------------
-- STATUSBAR

vim.api.nvim_create_autocmd({ "BufEnter", "FocusGained" }, {
	desc = "Alt-alt: cache most changed file for statusbar",
	group = vim.api.nvim_create_augroup("AltAltStatusbar", { clear = true }),
	callback = vim.schedule_wrap(function() vim.b.altalt_mostChangedFile = getMostChangedFile() end),
})

---@return string
---@nodiscard
function M.mostChangedFileStatusbar()
	local targetFile = vim.b.altalt_mostChangedFile
	if not targetFile then return "" end

	if config.statusbar.showMostChangedIfRedundant then
		local currentFile = vim.api.nvim_buf_get_name(0)
		local altFile = getAltBuffer() or getAltOldfile()
		if targetFile == currentFile or targetFile == altFile then return "" end
	end

	local icon = config.icons.mostChangedFile
	return vim.trim(icon .. " " .. nameForStatusbar(targetFile))
end

---@return string
---@nodiscard
function M.altFileStatusbar()
	local altBuf, altOld = getAltBuffer(), getAltOldfile()
	local path = altBuf or altOld or "[unknown]"
	local icon = altBuf and config.icons.altBuf or config.icons.oldFile
	return vim.trim(icon .. " " .. nameForStatusbar(path))
end

--------------------------------------------------------------------------------
return M
