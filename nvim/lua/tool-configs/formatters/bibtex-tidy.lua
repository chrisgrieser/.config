local fs = require("efmls-configs.fs")

local formatter = "bibtex-tidy"
local args = ""
local command = string.format('%s %s', fs.executable(formatter, fs.Scope.NODE), args)
local rangeFilter = "${--range-start:charStart} ${--range-end:charEnd}"


return {
	formatCommand = rangeFilter .. command,
	formatStdin = true,
	formatCanRange = true,
}
