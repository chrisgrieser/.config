local M = {}

local fn = vim.fn
local api = vim.api
local cmd = vim.cmd

---send notification
---@param msg string
---@param level? "info"|"trace"|"debug"|"warn"|"error"
local function notify(msg, level)
	if not level then level = "info" end
	local pluginName = "alt-alt"
	vim.notify(msg, vim.log.levels[level:upper()], { title = pluginName })
end

--------------------------------------------------------------------------------

---count number of windows, excluding various special windows (scrollbars,
---notification windows, etc)
---@nodiscard
---@return number
local function numberOfWins()
	local count = 0
	local wins = api.nvim_list_wins()
	for _, win in pairs(wins) do
		local winConf = api.nvim_win_get_config(win)
		local bufname = api.nvim_buf_get_name(api.nvim_win_get_buf(win))

		if
			bufname
			and bufname ~= ""
			and not winConf.external
			and winConf.focusable
			and api.nvim_win_is_valid(win)
		then
			count = count + 1
		end
	end
	return count
end

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
		local isCurrentFile = oldfile == fn.expand("%:p")
		local commitMsg = oldfile:find("COMMIT_EDITMSG$")
	until fileExists and not commitMsg and not isCurrentFile
	return oldfile
end

---shows info on alternate window/buffer/oldfile in that priority
---@nodiscard
---@return string
function M.altFileStatusline()
	local maxLen = 25
	local name, icon = "", ""
	local altFile = fn.expand("#:t")
	local curFile = fn.expand("%:t")
	local altPath = fn.expand("#:p")
	local curPath = fn.expand("%:p")
	local altBufNr = fn.bufnr("#") ---@diagnostic disable-line: param-type-mismatch

	local altOld = altOldfile()
	local specialFile = vim.api.nvim_buf_get_option(altBufNr, "buftype") ~= ""
	local fileExists = vim.loop.fs_stat(altPath) ~= nil
	local hasAltFile = altPath ~= curPath and (fileExists or specialFile)

	if hasAltFile then
		local ext = fn.expand("#:e")
		local altBufFt = vim.api.nvim_buf_get_option(altBufNr, "filetype") ---@diagnostic disable-line: param-type-mismatch
		local ftOrExt = ext ~= "" and ext or altBufFt
		local ok, devicons = pcall(require, "nvim-web-devicons")
		icon = ok and devicons.get_icon(altFile, ftOrExt) or "#"
		name = altFile

		if curFile == altFile then
			local altParent = vim.fs.basename(vim.fs.dirname(altPath))
			name = altParent .. "/" .. altFile
		end
	elseif altOld then
		icon = "󰋚"
		name = vim.fs.basename(altOld)
	else
		return "??"
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
function M.altBuffer()
	local altFile = fn.expand("#:t")
	local altPath = fn.expand("#:p")
	local curPath = fn.expand("%:p")
	local altBufNr = vim.fn.bufnr("#") ---@diagnostic disable-line: param-type-mismatch
	local specialFile = altBufNr > -1 and vim.api.nvim_buf_get_option(altBufNr, "buftype") or false
	local fileExists = vim.loop.fs_stat(altPath) ~= nil
	local hasAltFile = altFile ~= "" and altPath ~= curPath and (fileExists or specialFile)

	if hasAltFile and (altPath ~= curPath) then
		cmd.buffer("#")
	elseif altOldfile() then
		cmd.edit(altOldfile())
	else
		notify("Nothing to switch to.", "warn")
	end
end

---Close window/buffer, preserving alt-file
local lastClosedBuffer
function M.betterClose()
	if vim.bo.buftype ~= "" then
		pcall(cmd.bwipeout, { bang = true })
		return
	end

	local absPath = fn.expand("%:p")
	local fileExists = vim.loop.fs_stat(absPath) ~= nil
	if fileExists then cmd("silent update " .. absPath) end

	-- close window
	if numberOfWins() > 1 then
		cmd.close()
		return
	end

	-- close buffers
	local openBuffers = vim.fn.getbufinfo { buflisted = 1 }
	if #openBuffers == 1 then
		notify("Only one buffer open.", "trace")
		return
	end

	lastClosedBuffer = absPath -- save for undoing
	if #openBuffers == 2 then
		pcall(cmd.bwipeout) -- cannot clear altfile otherwise :/
		return
	end

	local couldDelete = pcall(cmd.bdelete)
	if not couldDelete then
		notify("Could not delete buffer.", "warn")
		return
	end

	-- ensure new alt file points towards open, non-active buffer, or altoldfile
	local i = 0
	local newAltBuf = ""
	while true do
		i = i + 1
		if i > #openBuffers then
			newAltBuf = altOldfile() or ""
			break
		end
		newAltBuf = openBuffers[i].name
		if newAltBuf ~= absPath and newAltBuf ~= absPath then break end
	end
	fn.setreg("#", newAltBuf) -- empty string would set the altfile to the current buffer
end

---repons last closed buffer, similar to ctrl-shift-t in the browser. If no
---buffer has been closed this session, opens last oldfile
function M.reopenBuffer()
	-- cannot use purely oldfiles, since they are not updated after buffer closing
	cmd.edit(lastClosedBuffer or altOldfile())
end

--------------------------------------------------------------------------------
return M
