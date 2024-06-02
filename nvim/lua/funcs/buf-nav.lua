local M = {}
local api = vim.api

---@nodiscard
---@param path string
local function fileExists(path) return vim.uv.fs_stat(path) ~= nil end

--------------------------------------------------------------------------------

---@param altBufnr integer
---@return boolean
local function hasAltFile(altBufnr)
	if altBufnr < 0 then return false end
	local valid = api.nvim_buf_is_valid(altBufnr)
	local nonSpecial = api.nvim_get_option_value("buftype", { buf = altBufnr }) == ""
	local moreThanOneBuffer = #(vim.fn.getbufinfo { buflisted = 1 }) > 1
	local currentBufNotAlt = vim.api.nvim_get_current_buf() ~= altBufnr -- fixes weird rare vim bug
	local altFileExists = fileExists(api.nvim_buf_get_name(altBufnr))

	return valid and nonSpecial and moreThanOneBuffer and currentBufNotAlt and altFileExists
end

---get the alternate oldfile, accounting for non-existing files
---@nodiscard
---@return string|nil path of oldfile, nil if none exists in all oldfiles
local function altOldfile()
	local curPath = api.nvim_buf_get_name(0)
	for _, path in ipairs(vim.v.oldfiles) do
		if fileExists(path) and not path:find("/COMMIT_EDITMSG$") and path ~= curPath then
			return path
		end
	end
	return nil
end

---shows name & icon of alt buffer. If there is none, show first alt-oldfile.
---@param maxDisplayLen? number
---@return string
function M.altFileStatus(maxDisplayLen)
	-- some statusline plugins convert their input into strings
	if type(maxDisplayLen) ~= "number" then maxDisplayLen = 25 end

	local altBufNr = vim.fn.bufnr("#")
	local altOld = altOldfile()
	local name, icon

	if hasAltFile(altBufNr) then
		local altPath = api.nvim_buf_get_name(altBufNr)
		local altFile = vim.fs.basename(altPath)
		name = altFile ~= "" and altFile or "[No Name]"
		-- icon
		local ext = altFile:match("%w+$")
		local altBufFt = api.nvim_get_option_value("filetype", { buf = altBufNr })
		local ok, devicons = pcall(require, "nvim-web-devicons")
		icon = ok and devicons.get_icon(altFile, ext or altBufFt) or "#"

		-- name: consider if alt and current file have same basename
		local curFile = vim.fs.basename(api.nvim_buf_get_name(0))
		local currentAndAltWithSameBasename = curFile == altFile
		if currentAndAltWithSameBasename then
			local altParent = vim.fs.basename(vim.fs.dirname(altPath))
			name = altParent .. "/" .. altFile
		end
	elseif altOld then
		icon = "󰋚"
		name = vim.fs.basename(altOld)
	else
		return "–––"
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
	if vim.bo.buftype ~= "" then return end -- deactivate if in a special buffer

	local altBufNr = vim.fn.bufnr("#")
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

---@param dir "next"|"prev"
function M.bufferByLastUsed(dir)
	local bufs = vim.fn.getbufinfo { buflisted = 1 }
	table.sort(bufs, function(a, b) return a.lastused > b.lastused end)

	local currentBuf = vim.api.nvim_buf_get_name(0)
	local currentBufIdx = vim.iter(bufs):find(function(buf) return buf.name == currentBuf end).bufnr
	vim.notify("⭕ currentBufIdx: " .. vim.inspect(currentBufIdx))

	local bufNames = vim.iter(bufs):map(function(buf) return buf.name end):totable()
	vim.notify("⭕ bufNames: " .. vim.inspect(bufNames))
end

--------------------------------------------------------------------------------
return M
