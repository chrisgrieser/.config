local M = {}

local fn = vim.fn
local api = vim.api
local cmd = vim.cmd

--------------------------------------------------------------------------------

---get the alternate window, accounting for special windows (scrollbars, notify)
---@nodiscard
---@return string|nil path of buffer in altwindow, nil if none exists (= only one window)
local function altWindow()
	local i = 0
	local altWin
	repeat
		-- two checks for regular window to catch all edge cases
		altWin = fn.bufname(fn.winbufnr(i))
		local winId = fn.win_getid(i)
		local isRegularWin1 = altWin and altWin ~= fn.bufname() and altWin ~= ""
		local winConf = api.nvim_win_get_config(winId) -- https://github.com/dstein64/nvim-scrollview/issues/83
		local isRegularWin2 = not winConf.external and winConf.focusable and api.nvim_win_is_valid(winId)

		i = i + 1
		if i > fn.winnr("$") then return nil end
	until isRegularWin1 and isRegularWin2
	return altWin
end

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
	local altWin = altWindow()
	local altOld = altOldfile()
	local name, icon
	local hasAltFile = altFile ~= "" and fn.filereadable(altFile)

	-- no oldfile and after start
	if altWin then
		if altWin:find("^diffview://") then
			icon = ""
			name = "File History"
		elseif altWin:find("^term://") then
			icon = ""
			name = "Terminal"
		else
			icon = " "
			name = vim.fs.basename(altWin)
		end
	elseif hasAltFile and (altPath ~= curPath) then
		icon = "#"
		name = altFile
		-- same name, different file: append parent of altfile
		if curFile == altFile then
			local altParent = fn.expand("#:p:h:t")
			name = altParent .. "/" .. altFile
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

---switch to alternate window/buffer/oldfile in that priority
function M.altBufferWindow()
	local altFile = fn.expand("#:t")
	local hasAltFile = altFile ~= "" and fn.filereadable(altFile)
	local altPath = fn.expand("#:p")
	local curPath = fn.expand("%:p")

	if numberOfWins() > 1 then
		cmd.wincmd("p")
	elseif hasAltFile and (altPath ~= curPath) then
		cmd.buffer("#")
	elseif altOldfile() then
		cmd.edit(altOldfile())
	else
		vim.notify("Nothing to switch to.", vim.log.levels.WARN)
	end
	if require("satellite") then cmd.SatelliteRefresh() end
end

---Close window/buffer, preserving alt-file
function M.betterClose()
	local absPath = fn.expand("%:p")
	local fileExists = vim.fn.filereadable(absPath) ~= 0
	if vim.bo.modifiable and absPath and fileExists then cmd.update(absPath) end

	-- close window
	if numberOfWins() > 1 then
		cmd.close()
		return
	end

	-- close buffers
	local openBuffers = vim.fn.getbufinfo { buflisted = 1 }
	if #openBuffers == 1 then
		vim.notify("Only one buffer open.", vim.log.levels.WARN)
		return
	end

	local bufToDel = fn.expand("%:p")
	vim.g.last_deleted_buffer = bufToDel
	if #openBuffers == 2 then
		cmd.bwipeout() -- cannot clear altfile otherwise :/
		return
	end

	cmd.bdelete()

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
