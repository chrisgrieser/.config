local linterConfig = require("config.utils").linterConfigFolder .. "/codespell-ignore.txt"

--------------------------------------------------------------------------------

local fs = require("efmls-configs.fs")

local linter = "codespell"

-- HACK to change severity
local command = string.format("%s --ignore-words %q ${INPUT} | sed 's/$/ w/'", fs.executable(linter), linterConfig)

return {
	prefix = linter,
	lintSource = linter,
	lintCommand = command,
	lintIgnoreExitCode = true,
	lintStdin = false,
	lintFormats = { "%f:%l:%m %t" },
}
