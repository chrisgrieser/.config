local linterConfig = require("config.utils").linterConfigFolder .. "/codespell-ignore.txt"

--------------------------------------------------------------------------------

local fs = require("efmls-configs.fs")

local linter = "codespell"

local command =
	string.format("%s --disable-colors --ignore-words %q ${INPUT}", fs.executable(linter), linterConfig)

return {
	prefix = linter,
	lintSource = linter,
	lintCommand = command,
	lintIgnoreExitCode = true,
	lintStdin = false,
	lintFormats = { "%f:%l:%m" },
	lintSeverity = vim.diagnostic.severity.INFO,
}

