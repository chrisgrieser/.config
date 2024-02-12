local ahead
local behind
local text = table.concat({ ahead, behind }, " ")
vim.notify("👽 text: a" .. tostring(text) .. "a")
