local linterConfig = require("config.utils").linterConfigFolder
local ignore = linterConfig .. "/codespell-ignore.txt"

--------------------------------------------------------------------------------
local fs = require("efmls-configs.fs")

local formatter = "codespell"
local args = "--check-hidden --write-changes" -- .. "--ignore-words '" .. ignore .. "'"
local command = string.format("%s %s", fs.executable(formatter), args)

-- defined the

return {
	formatCommand = command,
	formatStdin = false, -- BUG apparently, this does not work?
}
