local fs = require("efmls-configs.fs")

local linter = "codespell"
local command = string.format("%s ${INPUT}", fs.executable(linter))

-- defiend

return {
	prefix = linter,
	lintSource = linter,
	lintCommand = command,
	lintIgnoreExitCode = true,
	lintStdin = false,
	lintFormats = { "%f:%l: %trror%m" },
}
