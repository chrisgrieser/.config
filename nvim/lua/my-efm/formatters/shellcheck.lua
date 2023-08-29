local fs = require("efmls-configs.fs")

local formatter = "shellcheck"

-- Using `git apply` is the officially recommended to use shellcheck for auto-fixing
-- https://github.com/koalaman/shellcheck/issues/1220#issuecomment-594811243
local args = "--shell=bash --format=diff - | sed 's/-$/${INPUT}/' | git apply"

local command = string.format("%s %s", fs.executable(formatter), args)

return {
	formatCommand = command,
	formatStdin = true,
}
