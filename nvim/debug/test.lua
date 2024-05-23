local tz = tostring(os.date("%z"))
local tz_with_colon = tz:sub(1, 3) .. ':' .. tz:sub(4)
vim.notify("⭕ tz_with_colon: " .. tostring(tz_with_colon))
