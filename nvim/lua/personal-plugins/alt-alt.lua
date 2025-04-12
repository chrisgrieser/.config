--[[ INFO ALT-ALT
Alternative to vim's "alternative file" that improves its functionality.

1.`.gotoAltFile()` as an improved version of `:buffer #` that avoids special
  buffers, deleted buffers, non-existent files etc. and falls back
  to the first oldfile, if there is currently only one buffer.
2.`.gotoMostChangedFile` to go to the file in the cwd with the most git changes
3.`.deleteBuffer()` also removes the buffer as alt-file, but keeps it in the
  list of oldfiles.
4.`.altFileStatusbar()` and `.mostChangedFileStatusbar()` to display the
  respective file in the statusbar. If there is no alt-file, the first oldfile
  is shown. If there is not changed file, nothing is shown.
]]

--------------------------------------------------------------------------------

local config = {
	statusbarMaxLength = 30,
	icons = { -- set to nil to use `mini.icons` filetype icon, set to "" to disable
		oldFile = "󰋚",
		altBuf = "󰯬",
		mostChangedFile = "",
	},
	ignore = { -- patterns for `string.find`; applied to the whole file path
		oldfiles = {
			"/COMMIT_EDITMSG",
			"/snacks_scratch/",
		},
		mostChangedFiles = {
			"/info.plist", -- Alfred
			"/.lazy%-lock.json", -- lazy.nvim
		},
	},
}

--------------------------------------------------------------------------------
local M = {}

---@param msg string
---@param level? "info"|"trace"|"debug"|"warn"|"error"
---@param icon string
local function notify(msg, level, icon)
	if not level then level = "info" end
	local lvl = vim.log.levels[level:upper()]
	vim.notify(msg, lvl, { title = "Alt-alt", icon = icon })
end

---@nodiscard
---@return string|nil altBufferName, nil if no alt buffer
local function getAltBuffer()
	local altBufnr = vim.fn.bufnr("#")
	if altBufnr < 0 then return end
	local valid = vim.api.nvim_buf_is_valid(altBufnr)
	local nonSpecial = vim.api.nvim_get_option_value("buftype", { buf = altBufnr }) == ""
	local moreThanOneBuffer = #(vim.fn.getbufinfo { buflisted = 1 }) > 1
	local currentBufNotAlt = vim.api.nvim_get_current_buf() ~= altBufnr -- fixes weird vim bug
	local altBufExists = vim.uv.fs_stat(vim.api.nvim_buf_get_name(altBufnr)) ~= nil

	if valid and nonSpecial and moreThanOneBuffer and currentBufNotAlt and altBufExists then
		local altBufferName = vim.api.nvim_buf_get_name(vim.fn.bufnr("#"))
		return altBufferName
	end
end

---get the alternate oldfile, accounting for non-existing files
---@nodiscard
---@return string|nil oldfile; nil if none exists in all oldfiles
local function getAltOldfile()
	local curPath = vim.api.nvim_buf_get_name(0)
	for _, path in ipairs(vim.v.oldfiles) do
		local exists = vim.uv.fs_stat(path) ~= nil
		local sameFile = path == curPath
		local ignored = vim.iter(config.ignore.oldfiles)
			:any(function(p) return path:find(p) ~= nil end)
		if exists and not ignored and not sameFile then return path end
	end
end

---@return string? filepath
---@return string? errmsg
local function getMostChangedFile()
	-- get list of changed files
	local gitResponse = vim.system({ "git", "diff", "--numstat", "." }):wait()
	if gitResponse.code ~= 0 then return nil, "Not in git repo." end
	local changedFiles = vim.split(gitResponse.stdout, "\n", { trimempty = true })
	local gitroot = vim.trim(vim.system({ "git", "rev-parse", "--show-toplevel" }):wait().stdout)
	if #changedFiles == 0 then return nil, "No files with changes found." end

	-- identify file with most changes
	local targetFile
	local mostChanges = 0
	vim.iter(changedFiles):each(function(line)
		local added, deleted, relPath = line:match("(%d+)%s+(%d+)%s+(.+)")
		if not (added and deleted and relPath) then return end -- in case of changed binary files

		local absPath = vim.fs.normalize(gitroot .. "/" .. relPath)
		local ignored = vim.iter(config.ignore.mostChangedFiles)
			:any(function(p) return absPath:find(p) ~= nil end)
		local nonExistent = vim.uv.fs_stat(absPath) == nil
		if ignored or nonExistent then return end

		local changes = tonumber(added) + tonumber(deleted)
		if changes > mostChanges then
			mostChanges = changes
			targetFile = absPath
		end
	end)

	-- e.g., when all changed files are binaries, ignored, or non-existent
	if not targetFile then return nil, "No valid changed files found." end

	return targetFile, nil
end

---@param default "oldFile"|"altBuf"|"mostChangedFile"
---@param filepath? string
---@param bufnr? number
---@return string? icon
local function getIcon(default, filepath, bufnr)
	-- if default icon, use it
	if config.icons[default] then return config.icons[default] end
	if not filepath then return end

	local ok, miniIcons = pcall(require, "")
	if not (ok and miniIcons) then return end

	local icon, _, isDefault = miniIcons.get("file", filepath)
	if isDefault and bufnr then icon = miniIcons.get("filetype", vim.bo[bufnr].ft) end

	return icon
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
	local maxLength = config.statusbarMaxLength
	if #displayName > maxLength then
		displayName = displayName:sub(1, maxLength)
		displayName = vim.trim(displayName) .. "…"
	end

	return displayName
end

--------------------------------------------------------------------------------

---As opposed to the regular `:bdelete`, this function closes the buffer
---without it staying as the alt-file.
function M.deleteBuffer()
	local openBuffers = vim.fn.getbufinfo { buflisted = 1 }

	-- close buffer
	if #openBuffers < 2 then
		notify("Only one buffer open.", "trace", config.icons.altBuf)
		return
	end
	vim.cmd("silent! update")
	vim.cmd.bdelete()

	-- prevent alt-buffer pointing to deleted buffer
	-- (Using `:bwipeout` prevents this, but would also remove the file from the
	-- list of oldfiles which we don't want.)
	local altFileOpen = vim.b[vim.fn.bufnr("#")].buflisted
	if not altFileOpen then
		table.sort(openBuffers, function(a, b) return a.lastused > b.lastused end)
		if openBuffers[3] then -- 1st = closed buffer, 2nd = new current buffer
			local newAltFile = openBuffers[3].name
			vim.fn.setreg("#", newAltFile)
		end
	end
end

function M.gotoAltFile()
	if vim.bo.buftype ~= "" then
		notify("Cannot do that in special buffer.", "warn", config.icons.altBuf)
		return
	end
	local altBuf, altOld = getAltBuffer(), getAltOldfile()

	if altBuf then
		vim.cmd.buffer("#")
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

local mostChangedFile
vim.api.nvim_create_autocmd({ "BufEnter", "FocusGained" }, {
	desc = "Alt-alt: update most changed file statusbar",
	group = vim.api.nvim_create_augroup("AltAltStatusbar", { clear = true }),
	callback = function()
		vim.defer_fn(function() mostChangedFile = getMostChangedFile() end, 1)
	end,
})

function M.mostChangedFileStatusbar()
	local targetFile = mostChangedFile
	if not targetFile then return "" end

	local currentFile = vim.api.nvim_buf_get_name(0)
	local altFile = getAltBuffer() or getAltOldfile()
	if targetFile == currentFile or targetFile == altFile then return "" end

	local icon = getIcon("mostChangedFile", targetFile)
	return vim.trim(icon .. " " .. nameForStatusbar(targetFile))
end

---@return string
---@nodiscard
function M.altFileStatusbar()
	local altBuf, altOld = getAltBuffer(), getAltOldfile()

	local path = altBuf or altOld or "[unknown]"
	local icon = altBuf and getIcon("altBuf", altBuf, vim.fn.bufnr("#"))
		or getIcon("oldFile", altOld)

	return vim.trim(icon .. " " .. nameForStatusbar(path))
end

--------------------------------------------------------------------------------
return M
