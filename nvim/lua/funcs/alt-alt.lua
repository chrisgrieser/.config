local M = {}

local fn = vim.fn
local api = vim.api
local cmd = vim.cmd

--------------------------------------------------------------------------------

---count number of windows, excluding various special windows (scrollbars,
---notification windows, etc)
---@nodiscard
---@return number
local function numberOfWins()
	local count = 0

	for i = 1, fn.winnr("$"), 1 do
		local win = fn.bufname(fn.winbufnr(i))
		local winId = fn.win_getid(i)
		local winConf = api.nvim_win_get_config(winId)

		if
			win
			and win ~= ""
			and not winConf.external
			and winConf.focusable
			and api.nvim_win_is_valid(winId)
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
		local fileExists = fn.filereadable(oldfile) == 1
		local isCurrentFile = oldfile == fn.expand("%:p")
		local commitMsg = oldfile:find("COMMIT_EDITMSG$")
		local harpoonMenu = oldfile:find("harpoon%-menu$")
	until fileExists and not commitMsg and not isCurrentFile and not harpoonMenu
	return oldfile
end

---shows info on alternate window/buffer/oldfile in that priority
---@nodiscard
function M.altFileStatusline()
	local maxLen = 25
	local altFile = fn.expand("#:t")
	local curFile = fn.expand("%:t")
	local altPath = fn.expand("#:p")
	local curPath = fn.expand("%:p")
	local altOld = altOldfile()
	local name, icon
	local specialFile = altPath:find("://") -- e.g. octo
	local fileExists = fn.filereadable(altPath) ~= 0
	local hasAltFile = altFile ~= "" and altPath ~= curPath and (fileExists or specialFile)

	if hasAltFile then
		local ext = fn.expand("#:e")
		local altBufFt = vim.api.nvim_buf_get_option(fn.bufnr("#"), "filetype") ---@diagnostic disable-line: param-type-mismatch
		local ftOrExt = ext ~= "" and ext or altBufFt
		if ftOrExt == "javascript" then ftOrExt = "js" end
		if ftOrExt == "typescript" then ftOrExt = "ts" end
		if ftOrExt == "markdown" then ftOrExt = "md" end
		if ftOrExt == "vimrc" then ftOrExt = "vim" end
		local deviconsInstalled, devicons = pcall(require, "nvim-web-devicons")
		icon = deviconsInstalled and devicons.get_icon(altFile, ftOrExt) or "#"

		-- prefix `#` for octo buffers
		if altBufFt == "octo" and name:find("^%d$") then name = "#" .. name end

		-- same name, different file: append parent of altfile
		if curFile == altFile then
			local altParent = fn.expand("#:p:h:t")
			name = altParent .. "/" .. altFile
		else
			name = altFile
		end
	elseif altOld then
		icon = "󰋚"
		name = vim.fs.basename(altOld)
	else
		return ""
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
function M.altBufferWindow()
	local altFile = fn.expand("#:t")
	local hasAltFile = altFile ~= "" and fn.filereadable(altFile) ~= 0
	local altPath = fn.expand("#:p")
	local curPath = fn.expand("%:p")

	if hasAltFile and (altPath ~= curPath) then
		cmd.buffer("#")
	elseif altOldfile() then
		cmd.edit(altOldfile())
	else
		vim.notify("Nothing to switch to.", vim.log.levels.WARN)
	end
end

---Close window/buffer, preserving alt-file
function M.betterClose()
	if vim.bo.buftype ~= "" then
		local success = pcall(cmd.bwipeout, { bang = true })
		if not success then vim.notify("Could not delete buffer.", vim.log.levels.WARN) end
		return
	end

	local absPath = fn.expand("%:p")
	local fileExists = vim.fn.filereadable(absPath) ~= 0
	if vim.bo.modifiable and absPath and fileExists then cmd("silent update " .. absPath) end

	-- close window
	if numberOfWins() > 1 then
		cmd.close()
		return
	end

	-- close buffers
	local openBuffers = vim.fn.getbufinfo { buflisted = 1 }
	if #openBuffers == 1 then
		vim.notify("Only one buffer open.", vim.log.levels.TRACE)
		return
	end

	local bufToDel = fn.expand("%:p")
	local couldDelete
	vim.g.last_deleted_buffer = bufToDel -- save for undoing
	if #openBuffers == 2 then
		couldDelete = pcall(cmd.bwipeout) -- cannot clear altfile otherwise :/
		return
	end

	couldDelete = pcall(cmd.bdelete)
	if not couldDelete then
		vim.notify("Could not delete buffer.", vim.log.levels.WARN)
		return
	end

	-- ensure new alt file points towards open, non-active buffer, or altoldfile
	local curFile = fn.expand("%:p")
	local i = 0
	local newAltBuf = ""
	repeat
		i = i + 1
		if i > #openBuffers then
			newAltBuf = altOldfile() or ""
			break
		end
		newAltBuf = openBuffers[i].name
	until newAltBuf ~= curFile and newAltBuf ~= bufToDel
	fn.setreg("#", newAltBuf) -- empty string would set the altfile to the current buffer
end

---repons last closed buffer, similar to ctrl-shift-t in the browser. If no
---buffer has been closed this session, opens last oldfile
function M.reopenBuffer()
	-- cannot use purely oldfiles, since they are sometimes not updated
	-- in time after buffer closing
	local lastClosedBuf = vim.g.last_deleted_buffer or altOldfile()
	cmd.edit(lastClosedBuf)
end

--------------------------------------------------------------------------------
return M
