local M = {}
--------------------------------------------------------------------------------

---@nodiscard
---@param path string
---@return boolean
local function fileExists(path) return vim.uv.fs_stat(path) ~= nil end

---@nodiscard
---@return boolean
local function hasAltBuffer()
	local altBufnr = vim.fn.bufnr("#")
	if altBufnr < 0 then return false end
	local valid = vim.api.nvim_buf_is_valid(altBufnr)
	local nonSpecial = vim.api.nvim_get_option_value("buftype", { buf = altBufnr }) == ""
	local moreThanOneBuffer = #(vim.fn.getbufinfo { buflisted = 1 }) > 1
	local currentBufNotAlt = vim.api.nvim_get_current_buf() ~= altBufnr -- fixes weird vim bug
	local altBufExists = fileExists(vim.api.nvim_buf_get_name(altBufnr))

	return valid and nonSpecial and moreThanOneBuffer and currentBufNotAlt and altBufExists
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

function M.closeBuffer()
	local openBuffers = vim.fn.getbufinfo { buflisted = 1 }

	-- close buffer
	if #openBuffers < 2 then
		vim.notify("Only one open buffer.")
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
---@param maxLength? number
function M.altFileStatusbar(maxLength)
	maxLength = maxLength or 30 -- defaults to 30
	local icon = "#" -- default icon

	local altOld = altOldfile()
	local name

	if hasAltBuffer() then
		local altBufNr = vim.fn.bufnr("#")
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
		return "[unknown alt file]"
	end

	-- truncate
	local display = #name < maxLength and name or vim.trim(name:sub(1, maxLength)) .. "…"
	if not icon then return display end
	return icon .. " " .. display
end

---switch to alternate buffer/oldfile (in that priority)
function M.gotoAltFile()
	if vim.bo.buftype ~= "" then
		vim.notify("Cannot use since in special buffer", vim.log.levels.WARN, { title = "Alt-alt" })
		return
	end
	local altOld = altOldfile()

	if hasAltBuffer() then
		vim.cmd.buffer("#")
	elseif altOld then
		vim.cmd.edit(altOld)
	else
		vim.notify("No Alt buffer or Oldfile available.", vim.log.levels.WARN, { title = "Alt-alt" })
	end
end

--------------------------------------------------------------------------------
return M
