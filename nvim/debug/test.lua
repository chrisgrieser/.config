-- %%
-- local undos = vim.fn.undotree().entries
-- local idOfLastUndo = undos[#undos].seq

local undoFile = vim.fn.undofile(vim.api.nvim_buf_get_name(0))
	:gsub("%%", [[\%%]])
	vim.notify("🪚 undoFile: " .. tostring(undoFile))

local undoContent = vim.cmd.rundo(undoFile)
vim.notify("🪚 undoContent: " .. tostring(undoContent))
