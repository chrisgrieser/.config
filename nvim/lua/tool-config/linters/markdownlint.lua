local linterConfig = require("config.utils").linterConfigFolder .. "/markdownlintrc"

--------------------------------------------------------------------------------

local fs = require("efmls-configs.fs")

local linter = "markdownlint"
local command = string.format("%s --config %q --stdin", fs.executable(linter), linterConfig)

return {
	prefix = linter,
	lintSource = linter,
	lintCommand = command,
	lintIgnoreExitCode = true,
	lintStdin = true,
	lintFormats = { "%f:%l:%c %m", "%f:%l %m", "%f: %l: %m" },
}
