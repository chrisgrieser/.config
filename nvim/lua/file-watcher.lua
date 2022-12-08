require("utils")
-- https://neovim.io/doc/user/luvref.html#luv-fs-event-handle
-- https://github.com/rktjmp/fwatch.nvim/blob/main/lua/fwatch.lua#L16
-- https://neovim.io/doc/user/lua.html#lua-loop
--------------------------------------------------------------------------------

local function readFile(path)
	local file = io.open(path, "r")
	if not file then return nil end
	local content = file:read ("*all") -- *all reads the whole file
	file:close()
	return content:gsub("\n$", "")
end

local watchedFile = "/tmp/nvim-automation"
local w = vim.loop.new_fs_event()
local function executeExtCommand(err)
	if err then
		print(err)
		return
	end

	local command = readFile(watchedFile)
	print(command)
end

if w then
	w:start(watchedFile, {}, executeExtCommand)
end
