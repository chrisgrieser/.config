local x = ("<C-d>"):gsub("<[Cc]%-(.)>", function(s) return s end)
vim.notify("🖨️ x: " .. vim.inspect(x))
