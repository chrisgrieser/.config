local linterConfig = require("config.utils").linterConfigFolder .. "/yamllint.yaml"

--------------------------------------------------------------------------------

local fs = require("efmls-configs.fs")

-- TODO https://github.com/mfussenegger/nvim-lint/blob/master/lua/lint/linters/yamllint.lua

local linter = "yamllint"
local command =
	string.format("%s --config-file %q --format=parsable -", fs.executable(linter), linterConfig)

return {
	prefix = linter,
	lintSource = linter,
	lintCommand = command,
	lintIgnoreExitCode = true,
	lintStdin = true,
	lintFormats = {
		"stdin:%l:%c: [%trror] %m",
		"stdin:%l:%c: [%tarning] %m",
	},
}
