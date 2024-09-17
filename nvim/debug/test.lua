local out = vim.system({"printf", "\\a"}):wait()
vim.notify("🖨️ out: " .. vim.inspect(out))
