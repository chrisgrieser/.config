local fs = require("efmls-configs.fs")

local formatter = "shellharden"
local args = "--transform ''"

local command = string.format("%s %s", fs.executable(formatter), args)

return {
	formatCommand = command,
	formatStdin = true,
}
