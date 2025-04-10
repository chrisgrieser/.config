--[[ ALT-ALT
Alternative to vim's "alternative file" that improves its functionality.

1.`require("alt-alt").gotoAltFile()` as an improved version of `:buffer #` that
  avoids special buffers, deleted buffers, non-existent files etc. and falls back
  to the first oldfile, if there is currently only one buffer.
2.`require("alt-alt").deleteBuffer()` also removes the buffer as alt-file, but
  keeps it in the list of oldfiles.
3.`require("alt-alt").altFileStatusbar()` to display the alt-file in the
  statusbar, including an icon (if `nvim-devicons` or `mini-icons` is installed).
]]

--------------------------------------------------------------------------------

local config = {
	icons = {
		main = "󰬈",
		oldfile = "󰋚",
		mostChangedFile = "",
	},
	statusbar = {
		maxLength = 30,
		showFiletypeIcon = true, -- requires `nvim-devicons` or `mini-icons`
	},
	ignoreOldfiles = {
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
	vim.notify(msg, vim.log.levels[level:upper()], { title = "Alt-alt", icon = config.icons.main })
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
		-- local ignored = vim.iter(config.ignoreOldfiles)
		-- 	:any(function(p) return path:find(p) ~= nil end)
		local ignored = vim.iter(config.ignoreOldfiles)
			:any(function(p) return path:find(p) ~= nil end)
		if exists and not ignored and not sameFile then return path end
	end
	return nil
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

---@return string?
local function getMostChangedFile()
	-- get list of changed files
	local gitResponse = vim.system({ "git", "diff", "--numstat", "." }):wait()
	if gitResponse.code ~= 0 then
		notify("Not in git repo.", "warn")
		return
	end
	local changedFiles = vim.split(gitResponse.stdout, "\n", { trimempty = true })
	local gitroot = vim.trim(vim.system({ "git", "rev-parse", "--show-toplevel" }):wait().stdout)
	if #changedFiles == 0 then
		notify("No files with changes found.")
		return
	end

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
	return targetFile
end

function M.gotoMostChangedFile()
	local targetFile = getMostChangedFile()
	if not targetFile then return end

	local currentFile = vim.api.nvim_buf_get_name(0)
	if targetFile == currentFile then
		notify("Already at the most changed file.")
	else
		vim.cmd.edit(targetFile)
	end
end

-- TODO only update on bufchange
function M.mostChangedFileStatusbar()
	local currentFile = vim.api.nvim_buf_get_name(0)
	local targetFile = getMostChangedFile()

	if targetFile == currentFile then return "" end
	if not targetFile then return "" end

	local targetBasename = vim.fs.basename(targetFile)
	local icon = config.icons.mostChangedFile or ""
	return vim.trim(icon .. " " .. targetBasename)
end

--------------------------------------------------------------------------------
-- STATUSBAR

---shows name & icon of alt buffer. If there is none, show first alt-oldfile.
---@return string
---@nodiscard
function M.altFileStatusbar()
	local icon, name = config.icons.main, "[unknown]"
	local altOld = altOldfile()

	if hasAltBuffer() then
		local altBufNr = vim.fn.bufnr("#")
		local altPath = vim.api.nvim_buf_get_name(altBufNr)
		local altFile = vim.fs.basename(altPath)
		name = altFile ~= "" and altFile or "[no name]"
		-- icon
		local ok, icons = pcall(require, "mini.icons")
		if ok and icons then
			local isDefault = false
			icon, _, isDefault = icons.get("file", altPath)
			if isDefault then icon = icons.get("filetype", vim.bo[altBufNr].ft) end
		end

		-- name: consider if alt and current file have same basename
		local curBasename = vim.fs.basename(vim.api.nvim_buf_get_name(0))
		if curBasename == altFile then
			local altParent = vim.fs.basename(vim.fs.dirname(altPath))
			name = altParent .. "/" .. altFile
		end
	elseif altOld then
		icon = config.icons.oldfile
		name = vim.fs.basename(altOld)
	end

	-- truncate
	local maxLength = config.statusbar.maxLength
	if #name > maxLength then name = vim.trim(name:sub(1, maxLength)) .. "…" end

	if not config.statusbar.showFiletypeIcon then return name end
	return icon .. " " .. name
end

--------------------------------------------------------------------------------
return M
