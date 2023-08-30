local fs = require("efmls-configs.fs")

local linter = "shellcheck"
local command = string.format("%s --color=never --shell=bash --format=gcc -", fs.executable(linter))

return {
	prefix = linter,
	lintCommand = command,
	lintIgnoreExitCode = true,
	lintStdin = true,
	lintFormats = { "-:%l:%c: %trror: %m", "-:%l:%c: %tarning: %m", "-:%l:%c: %tote: %m" },
}
