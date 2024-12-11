local M = {}
--------------------------------------------------------------------------------

---@param msg string
---@param level? "info"|"trace"|"debug"|"warn"|"error"
local function notify(msg, level)
	if not level then level = "info" end
	vim.notify(msg, vim.log.levels[level:upper()], { title = "Alt-alt", icon = "󰬈" })
end

--------------------------------------------------------------------------------

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
		local exists = vim.uv.fs_stat(path)
		local ignored = path:find("/COMMIT_EDITMSG$")
		local sameFile = path == curPath
		if exists and not ignored and not sameFile then return path end
	end
	return nil
end

--------------------------------------------------------------------------------

function M.closeBuffer()
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

---shows name & icon of alt buffer. If there is none, show first alt-oldfile.
---@return string
---@nodiscard
function M.altFileStatusbar()
	local maxLength = 30 -- CONFIG
	local icon, name = "#", "[unknown]"
	local altOld = altOldfile()

	if hasAltBuffer() then
		local altBufNr = vim.fn.bufnr("#")
		local altPath = vim.api.nvim_buf_get_name(altBufNr)
		local altFile = vim.fs.basename(altPath)
		name = altFile ~= "" and altFile or "[no name]"
		-- icon
		local ok, devicons = pcall(require, "nvim-web-devicons")
		if ok and devicons then
			local ext = altFile:match("%w+$")
			local ft = vim.bo[altBufNr].filetype -- for extensionless files
			icon = devicons.get_icon(altFile, ext)
				or devicons.get_icon(altFile, ft, { default = true })
		end

		-- name: consider if alt and current file have same basename
		local curBasename = vim.fs.basename(vim.api.nvim_buf_get_name(0))
		if curBasename == altFile then
			local altParent = vim.fs.basename(vim.fs.dirname(altPath))
			name = altParent .. "/" .. altFile
		end
	elseif altOld then
		icon = "󰋚"
		name = vim.fs.basename(altOld)
	end

	-- truncate
	if #name > maxLength then name = vim.trim(name:sub(1, maxLength)) .. "…" end
	return icon .. " " .. name
end

---switch to alternate buffer/oldfile (in that priority)
function M.gotoAltFile()
	if vim.bo.buftype ~= "" then
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

--------------------------------------------------------------------------------
return M
