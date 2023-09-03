-- Metadata
-- languages: bash, sh
-- url: https://github.com/openstack/bashate

local fs = require("efmls-configs.fs")

local linter = "bashate"
local command = string.format("%s ${INPUT}", fs.executable(linter))

return {
	prefix = linter,
	lintCommand = command,
	lintStdin = false,
	lintIgnoreExitCode = true,
	lintFormats = { "%f:%l:%c: %t%m", "%f:%l:1: %t%m",  },
}
