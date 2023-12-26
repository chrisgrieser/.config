local M = {}
local a = vim.api
--------------------------------------------------------------------------------

---@param altBufnr integer
---@return boolean
local function hasAltFile(altBufnr)
	local altPath = a.nvim_buf_get_name(altBufnr)
	local curPath = a.nvim_buf_get_name(0)
	local valid = a.nvim_buf_is_valid(altBufnr)
	local nonSpecial = a.nvim_buf_get_option(altBufnr, "buftype") == ""
	local exists = vim.loop.fs_stat(altPath) ~= nil
	return valid and nonSpecial and exists and (altPath ~= curPath)
end

---get the alternate oldfile, accounting for non-existing files
---@nodiscard
---@return string|nil path of oldfile, nil if none exists in all oldfiles
local function altOldfile()
	local curPath = a.nvim_buf_get_name(0)
	for _, file in ipairs(vim.v.oldfiles) do
		if vim.loop.fs_stat(file) and not file:find("/COMMIT_EDITMSG$") and file ~= curPath then
			return file
		end
	end
	return nil
end

---shows name & icon of alt buffer. If there is none, show first alt-oldfile.
---@param maxDisplayLen? number
---@return string
function M.altFileStatusline(maxDisplayLen)
	-- some statusline plugins convert their input into strings
	if type(maxDisplayLen) ~= "number" then maxDisplayLen = 25 end

	local altBufNr = vim.fn.bufnr("#") ---@diagnostic disable-line: param-type-mismatch
	local altPath = a.nvim_buf_get_name(altBufNr)
	local curPath = a.nvim_buf_get_name(0)
	local altFile = vim.fs.basename(altPath)
	local altOld = altOldfile()

	local name, icon
	if hasAltFile(altBufNr) then
		-- icon
		local ext = altFile:match("%w+$")
		local altBufFt = a.nvim_buf_get_option(altBufNr, "filetype") ---@diagnostic disable-line: param-type-mismatch
		local ok, devicons = pcall(require, "nvim-web-devicons")
		icon = ok and devicons.get_icon(altFile, ext or altBufFt) or "#"

		-- name
		name = altFile
		if vim.fs.basename(curPath) == altFile then
			local altParent = vim.fs.basename(vim.fs.dirname(altPath))
			name = altParent .. "/" .. altFile
		end
	elseif altOld then
		icon = "󰋚"
		name = vim.fs.basename(altOld)
	end

	-- truncate
	local nameNoExt = name:gsub("%.%w+$", "")
	if #nameNoExt > maxDisplayLen then
		local ext = name:match("%.%w+$")
		name = nameNoExt:sub(1, maxDisplayLen) .. "…" .. ext
	end
	return icon .. " " .. name
end

---switch to alternate buffer/oldfile (in that priority)
function M.gotoAltBuffer()
	local altBufNr = vim.fn.bufnr("#") ---@diagnostic disable-line: param-type-mismatch
	local altOld = altOldfile()

	if hasAltFile(altBufNr) then
		vim.cmd.buffer("#")
	elseif altOld then
		vim.cmd.edit(altOld)
	else
		vim.notify(
			"No Alt File and not Oldfile available.",
			vim.log.levels.WARN,
			{ title = "AltAlt" }
		)
	end
end

--------------------------------------------------------------------------------
return M
