--[[ INFO: ALT-ALT
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
	icons = {
		notification = "󰬈",
		oldfile = "󰋚",
	},
	statusbar = {
		maxLength = 30,
		showFiletypeIcon = true, -- requires `mini-icons`
	},
	ignoreOldfiles = { -- patterns for `string.find`
		"/COMMIT_EDITMSG",
		"/snacks_scratch/",
	},
}

--------------------------------------------------------------------------------
local M = {}

---@param msg string
---@param level? "info"|"trace"|"debug"|"warn"|"error"
local function notify(msg, level)
	if not level then level = "info" end
	local lvl = vim.log.levels[level:upper()]
	vim.notify(msg, lvl, { title = "Alt-alt", icon = config.icons.notification })
end

---@nodiscard
---@return boolean
local function hasAltBuffer()
	local altBufnr = vim.fn.bufnr("#")
	if altBufnr < 0 then return false end
	local valid = vim.api.nvim_buf_is_valid(altBufnr)
	local nonSpecial = vim.api.nvim_get_option_value("buftype", { buf = altBufnr }) == ""
	local moreThanOneBuffer = #(vim.fn.getbufinfo { buflisted = 1 }) > 1
	local currentBufNotAlt = vim.api.nvim_get_current_buf() ~= altBufnr -- fixes weird vim bug
	local altBufExists = vim.uv.fs_stat(vim.api.nvim_buf_get_name(altBufnr)) ~= nil

	return valid and nonSpecial and moreThanOneBuffer and currentBufNotAlt and altBufExists
end

---get the alternate oldfile, accounting for non-existing files
---@nodiscard
---@return string|nil path of oldfile, nil if none exists in all oldfiles
local function altOldfile()
	local curPath = vim.api.nvim_buf_get_name(0)
	for _, path in ipairs(vim.v.oldfiles) do
		local exists = vim.uv.fs_stat(path) ~= nil
		local sameFile = path == curPath
		local ignored = vim.iter(config.ignoreOldfiles)
			:any(function(p) return path:find(p) ~= nil end)
		if exists and not ignored and not sameFile then return path end
	end
	return nil
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
		if not vim.uv.fs_stat(absPath) then return end

		local changes = tonumber(added) + tonumber(deleted)
		if changes > mostChanges then
			mostChanges = changes
			targetFile = absPath
		end
	end)
	return targetFile, nil
end

---@param filepath string
---@param bufnr? number
---@return string? icon
local function getIcon(filepath, bufnr)
	local icon
	local ok, miniIcons = pcall(require, "mini.icons")
	if not (ok and miniIcons) then return end

	local isDefault = false
	icon, _, isDefault = miniIcons.get("file", filepath)
	if not (isDefault and bufnr) then return icon end

	icon = miniIcons.get("filetype", vim.bo[bufnr].ft)
	return icon
end

---@param path string
---@return string
local function getNameForStatusbar(path)
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

---As opposed to the regular `:bdelete`, this function closes the buffer
---without it being the alt-file.
function M.deleteBuffer()
	local openBuffers = vim.fn.getbufinfo { buflisted = 1 }

	-- close buffer
	if #openBuffers < 2 then
		notify("Only one buffer open.", "trace")
		return
	end
	vim.cmd("silent! update")
	vim.cmd.bdelete()

	-- prevent alt-buffer pointing to deleted buffer
	-- (Using `:bwipeout` prevents this, but would also removes the file from the
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

---switch to alternate buffer/oldfile (in that priority)
function M.gotoAltFile()
	if vim.bo.buftype ~= "" and vim.bo.buftype ~= "help" then
		notify("Cannot do that in special buffer.", "warn")
		return
	end
	local altOld = altOldfile()

	if hasAltBuffer() then
		vim.cmd.buffer("#")
	elseif altOld then
		vim.cmd.edit(altOld)
	else
		notify("No alt buffer or oldfile available.", "error")
	end
end

function M.gotoMostChangedFile()
	local targetFile, errmsg = getMostChangedFile()
	if errmsg then
		notify(errmsg, "warn")
		return
	end

	local currentFile = vim.api.nvim_buf_get_name(0)
	if targetFile == currentFile then
		notify("Already at the most changed file.")
	else
		vim.cmd.edit(targetFile)
	end
end

--------------------------------------------------------------------------------
-- STATUSBAR

local mostChangedFile
vim.api.nvim_create_autocmd({ "BufEnter", "FocusGained" }, {
	desc = "Alt-alt: update most changed file statusbar",
	callback = function() mostChangedFile = getMostChangedFile() end,
})

function M.mostChangedFileStatusbar()
	local targetFile = mostChangedFile
	if not targetFile then return "" end

	local currentFile = vim.api.nvim_buf_get_name(0)
	local altFile = vim.api.nvim_buf_get_name(vim.fn.bufnr("#"))
	if targetFile == currentFile or targetFile == altFile then return "" end

	local name = getNameForStatusbar(targetFile)
	if not config.statusbar.showFiletypeIcon then return name end

	local ftIcon = getIcon(targetFile) or ""
	return vim.trim(ftIcon .. " " .. name)
end

---shows name & icon of alt buffer. If there is none, show first alt-oldfile.
---@return string
---@nodiscard
function M.altFileStatusbar()
	local icon, path
	local altOld = altOldfile()

	if hasAltBuffer() then
		local altBufNr = vim.fn.bufnr("#")
		path = vim.api.nvim_buf_get_name(altBufNr)
		icon = getIcon(path, altBufNr) or "#"
	elseif altOld then
		icon = config.icons.oldfile or ""
		path = altOld
	end

	local name = getNameForStatusbar(path)
	if not config.statusbar.showFiletypeIcon then return name end

	return vim.trim(icon .. " " .. name)
end

--------------------------------------------------------------------------------
return M
