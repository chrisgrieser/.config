local fs = require("efmls-configs.fs")

local formatter = "shellcheck"

-- Using `git apply` is the officially recommended way for auto-fixing
-- https://github.com/koalaman/shellcheck/issues/1220#issuecomment-594811243
local args = '--shell=bash --format=diff ${INPUT} | git apply'

local command = string.format("%s %s", fs.executable(formatter), args)

return {
	formatCommand = command,
	formatStdin = false, -- BUG not working when disabling stdin
}
