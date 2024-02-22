

local str = "`ObjC.fsfsf`"
local match = str:match("`.*%.?.*`")
vim.notify("👽 match: " .. tostring(match))
