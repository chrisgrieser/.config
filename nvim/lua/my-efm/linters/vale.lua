local linterConfig = require("config.utils").linterConfigFolder .. "/vale/vale.ini"

--------------------------------------------------------------------------------

local fs = require("efmls-configs.fs")

local linter = "vale"
local command =
	string.format("%s --config %q --output=line ${INPUT}", fs.executable(linter), linterConfig)

return {
	prefix = linter,
	lintCommand = command,
	lintStdin = false,
	lintFormats = { "%f:%l:%c:%m" },
}
