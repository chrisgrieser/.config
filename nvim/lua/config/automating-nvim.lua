require("config.utils")
-- Runs arbitrary lua commands when written to the watchedFile

-- INFO
-- https://neovim.io/doc/user/luvref.html#luv-fs-event-handle
-- https://github.com/rktjmp/fwatch.nvim/blob/main/lua/fwatch.lua#L16
-- https://neovim.io/doc/user/lua.html#lua-loop
--------------------------------------------------------------------------------

local watchedFile = "/tmp/nvim-automation"
local w = vim.loop.new_fs_event()

local function readFile(path)
	local file = io.open(path, "r")
	if not file then return nil end
	local content = file:read("*all") 
	file:close()
	return content:gsub("\n$", "")
end

local function executeExtCommand()
	local command = readFile(watchedFile)
	fn.luaeval(command)
	if w then
		w:stop() -- prevent multiple execution
		startWatching()
	end
end

function startWatching()
	if w then
		w:start(watchedFile, {}, vim.schedule_wrap(executeExtCommand))
	end
end

startWatching()
