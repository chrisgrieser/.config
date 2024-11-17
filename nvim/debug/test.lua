



local function ffff() ---@diagnostic disable-line: unused-local

end

local curLine= "local function ffff()---@diagnostic disable-line: unused-local"
local existingRulePattern= "%-%-%-@diagnostic disable%-line: ([w,-_]+)"

local changed = curLine:match(existingRulePattern)
vim.notify("🖨️ changed: " .. tostring(changed))
