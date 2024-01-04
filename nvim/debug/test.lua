-- %%
local undos = vim.fn.undotree().entries
local ifOfLastUndo = undos[#undos].seq

local undoFile = vim.fn.undofile(vim.api.nvim_buf_get_name(0))

local undoContent = vim.cmd.rundo(undoFile)
vim.notify("🪚 undoContent: " .. tostring(undoContent))
