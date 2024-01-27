
local fixed = vim.fn.spellsuggest("teh", 1)[1]
vim.notify("👽 fixed: " .. tostring(fixed))
