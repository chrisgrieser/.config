local fs = require("efmls-configs.fs")

local linter = "proselint"
local command = string.format("%s -", fs.executable(linter))

return {
	prefix = linter,
	lintCommand = command,
	lintStdin = true,
	lintFormats = { "<stdin>:%l:%c: %m" },
	lintSeverity = vim.diagnostic.severity.INFO,
}
