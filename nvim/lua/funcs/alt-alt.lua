local M = {}
--------------------------------------------------------------------------------

local config = {
	statuslineMaxLen = 30,
}

--------------------------------------------------------------------------------

---@nodiscard
---@param path string
local function fileExists(path) return vim.uv.fs_stat(path) ~= nil end

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

--------------------------------------------------------------------------------

function M.closeWindowOrBuffer()
	vim.cmd("silent! update")
	local winClosed = pcall(vim.cmd.close)
	if winClosed then return end

	local moreThanOneBuffer = #(vim.fn.getbufinfo { buflisted = 1 }) > 1
	if moreThanOneBuffer then
		-- force deleting (= `:bwipeout`) results in correctly set alt-file, but
		-- also removes from the oldfiles, thus manually adding them there
		local bufPath = vim.api.nvim_buf_get_name(0)
		pcall(vim.api.nvim_buf_delete, 0, { force = true })
		table.insert(vim.v.oldfiles, 1, bufPath)
	end
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
	local maxLength = config.statuslineMaxLen
	local display = #name < maxLength and name or vim.trim(name:sub(1, maxLength)) .. "…"
	if not icon then return display end
	return icon .. " " .. display
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
	vim.notify("No Altfile or Oldfile available.", vim.log.levels.WARN, { title = "Alt-alt" })
end

--------------------------------------------------------------------------------
return M
