local linterConfig = require("config.utils").linterConfigFolder .. "/cspell.yaml"
local fs = require("efmls-configs.fs")

local linter = "cspell"

local command = string.format(
	"%s --config %q --no-color --no-progress --no-summary ${INPUT}",
	fs.executable(linter), 
	linterConfig
)

return {
	prefix = linter,
	lintSource = linter,
	lintCommand = command,
	lintIgnoreExitCode = true,
	lintStdin = false,
	lintFormats = { "%f:%l:%c - %m", "%f:%l:%c %m" },
	lintSeverity = vim.diagnostic.severity.INFO,
}
