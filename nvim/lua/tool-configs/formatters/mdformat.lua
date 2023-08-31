-- Metadata
-- url: https://mdformat.readthedocs.io/
-- languages: markdown

local fs = require("efmls-configs.fs")

local formatter = "mdformat"
local args = "--fix --stdin"
local command = string.format('%s %s', fs.executable(formatter), args)

return {
	formatCommand = command,
	formatStdin = true,
	rootMarkers = { ".mdformat.toml" },
}
