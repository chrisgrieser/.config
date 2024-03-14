local found = vim.fs.find(".obsidian", { upward = true, type = "directory" })
vim.notify("❗ found: " .. vim.inspect(found))
