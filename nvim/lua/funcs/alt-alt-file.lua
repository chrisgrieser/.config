local fn = vim.fn
local api = vim.api
local cmd = vim.cmd

local M = {}

--------------------------------------------------------------------------------

---get the alternate window, accounting for special windows (scrollbars, notify)
---@return string|nil path of buffer in altwindow, nil if none exists (= only one window)
local function altWindow()
	local i = 0
	local altWin
	repeat
		if i > fn.winnr("$") then return nil end
		-- two checks for regular window to catch all edge cases
		altWin = fn.bufname(fn.winbufnr(i))
		local winId = fn.win_getid(i)
		local isRegularWin1 = altWin and altWin ~= fn.bufname() and altWin ~= ""
		local win = api.nvim_win_get_config(winId) -- https://github.com/dstein64/nvim-scrollview/issues/83
		local isRegularWin2 = not win.external and win.focusable and api.nvim_win_is_valid(winId)
		i = i + 1
	until isRegularWin1 and isRegularWin2
	return altWin
end

---get the alternate oldfile, accounting for non-existing files etc.
---@return string|nil path of oldfile, nil if none exists in all oldfiles
local function altOldfile()
	local oldfile
	local i = 0
	repeat
		i = i + 1
		if i > #vim.v.oldfiles then return nil end
		oldfile = vim.v.oldfiles[i]
		local fileExists = fn.filereadable(oldfile) == 1
		local isCurrentFile = oldfile == expand("%:p")
		local commitMsg = oldfile:find("COMMIT_EDITMSG$")
	until fileExists and not commitMsg and not isCurrentFile
	return oldfile
end

---shows info on alternate window/buffer/oldfile in that priority
function M.altFileStatusline()
	local maxLen = 15
	local altFile = expand("#:t")
	local curFile = expand("%:t")

	if altFile == "" and not altOldfile() then -- no oldfile and after start
		return ""
	elseif altFile:find("^diffview") then
		return " File Diffview" -- diffview is ugly string otherwise
	elseif altWindow() then
		return "  " .. altWindow()
	elseif altFile == "" and altOldfile() then
		return " " .. vim.fs.basename(altOldfile()) ---@diagnostic disable-line: param-type-mismatch
	elseif curFile == altFile then -- same name, different file
		local altParent = expand("#:p:h:t")
		if #altParent > maxLen then altParent = altParent:sub(1, maxLen) .. "…" end
		return "# " .. altParent .. "/" .. altFile
	end
	return "# " .. altFile
end

---switch to alternate window/buffer/oldfile in that priority
function M.altBufferWindow()
	cmd.nohlsearch()
	if altWindow() then
		cmd.wincmd("p")
	elseif expand("#") ~= "" then
		cmd.buffer("#")
	elseif altOldfile() then
		cmd.edit(altOldfile())
	else
		vim.notify("Nothing to switch to.", logWarn)
	end
end

---Close window/buffer in that priority
function M.betterClose()
	local openBuffers = fn.getbufinfo { buflisted = 1 }
	local bufToDel = expand("%:p")

	if bo.modifiable then cmd.update() end
	cmd.nohlsearch()

	if #openBuffers == 1 then
		vim.notify("Only one buffer open.", logWarn)
		return
	elseif #openBuffers == 2 then
		cmd.bwipeout() -- cannot clear altfile otherwise :/
		return
	end

	cmd.bdelete()

	-- ensure new alt file points towards open, non-active buffer, or altoldfile
	local curFile = expand("%:p")
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

	fn.setreg("#", newAltBuf) -- empty string will set the altfile to the current buffer
end

--------------------------------------------------------------------------------
return M
