local fs = require("efmls-configs.fs")

local linter = "stylelint"
local args = "--quiet --no-color --formatter compact --stdin --stdin-filename ${INPUT}"
local command = string.format("%s %s", fs.executable(linter, fs.Scope.NODE), args)

return {
	prefix = linter,
	lintCommand = command,
	lintStdin = true,
	lintFormats = { "%.%#: line %l, col %c, %trror - %m", "%.%#: line %l, col %c, %tarning - %m" },
	rootMarkers = { ".stylelintrc.yml", "stylelintrc.yaml", ".stylelintrc", "stylelintrc.json" },

	-- INFO turn all into warnings, since they are not critical and the actual
	-- warnings are not displayed due to `--quiet` (see above). The config sets
	-- auto-fixable items to warnings all others to warnings
	lintSeverity = vim.diagnostic.severity.WARN, 
}
