local linterConfig = require("config.utils").linterConfigFolder
local ignore = linterConfig .. "/codespell-ignore.txt"

--------------------------------------------------------------------------------
local fs = require("efmls-configs.fs")

local formatter = "codespell"
local args = "--disable-colors --check-hidden --write-changes ${INPUT}" -- .. "--ignore-words '" .. ignore .. "'"
local command = string.format("%s %s", fs.executable(formatter), args)

-- defined the

return {
	formatCommand = command,
	formatStdin = false, -- BUG pending: https://github.com/mattn/efm-langserver/issues/258
}
