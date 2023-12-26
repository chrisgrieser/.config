local M = {}

local fn = vim.fn
local api = vim.api
local cmd = vim.cmd

--------------------------------------------------------------------------------

---get the alternate oldfile, accounting for non-existing files etc.
---@nodiscard
---@return string|nil path of oldfile, nil if none exists in all oldfiles
local function altOldfile()
	local oldfile
	local i = 0
	repeat
		i = i + 1
		if i > #vim.v.oldfiles then return nil end
		oldfile = vim.v.oldfiles[i]
		local fileExists = vim.loop.fs_stat(oldfile) ~= nil
		local isCurrentFile = oldfile == api.nvim_buf_get_name(0)
		local commitMsg = oldfile:find("COMMIT_EDITMSG$")
	until fileExists and not commitMsg and not isCurrentFile
	return oldfile
end

---shows info on alternate window/buffer/oldfile in that priority
---@return string
function M.altFileStatusline()
	local maxLen = 25 -- CONFIG

	local altPath = fn.expand("#:p")
	local curPath = vim.api.nvim_buf_get_name(0)
	local curFile = vim.fs.basename(curPath)
	local altFile = vim.fs.basename(altPath)

	local altBufNr = fn.bufnr("#") ---@diagnostic disable-line: param-type-mismatch
	local specialFile = vim.api.nvim_buf_is_valid(altBufNr)
		and vim.api.nvim_buf_get_option(altBufNr, "buftype") ~= ""
	local fileExists = vim.loop.fs_stat(altPath) ~= nil
	local hasAltFile = altFile ~= "" and altPath ~= curPath and (fileExists or specialFile)

	local name, icon
	if hasAltFile then
		-- icon
		local ext = fn.expand("#:e")
		local altBufFt = vim.api.nvim_buf_get_option(altBufNr, "filetype") ---@diagnostic disable-line: param-type-mismatch
		local ftOrExt = ext ~= "" and ext or altBufFt
		local ok, devicons = pcall(require, "nvim-web-devicons")
		icon = ok and devicons.get_icon(altFile, ftOrExt) or "#"

		-- name
		name = altFile
		if curFile == altFile then
			local altParent = vim.fs.basename(vim.fs.dirname(altPath))
			name = altParent .. "/" .. altFile
		end
	elseif altOldfile() then
		local altOld = altOldfile() ---@cast altOld string
		icon = "󰋚"
		name = vim.fs.basename(altOld)
	end

	-- truncate
	local nameNoExt = name:gsub("%.%w+$", "")
	if #nameNoExt > maxLen then
		local ext = name:match("%.%w+$")
		name = nameNoExt:sub(1, maxLen) .. "…" .. ext
	end
	return icon .. " " .. name
end

---switch to alternate buffer/oldfile (in that priority)
function M.gotoAltBuffer()
	local altFile = fn.expand("#:t")
	local altPath = fn.expand("#:p")
	local curPath = vim.api.nvim_buf_get_name(0)
	local altBufNr = fn.bufnr("#") ---@diagnostic disable-line: param-type-mismatch
	local specialFile = vim.api.nvim_buf_is_valid(altBufNr)
		and vim.api.nvim_buf_get_option(altBufNr, "buftype") ~= ""
	local fileExists = vim.loop.fs_stat(altPath) ~= nil
	local hasAltFile = altFile ~= "" and altPath ~= curPath and (fileExists or specialFile)

	if hasAltFile and (altPath ~= curPath) then
		cmd.buffer("#")
	elseif altOldfile() then
		cmd.edit(altOldfile())
	else
		vim.notify("Nothing to switch to.", vim.log.levels.WARN, { title = "AltAlt" })
	end
end

--------------------------------------------------------------------------------
return M
