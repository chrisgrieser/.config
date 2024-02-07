local match = vim.filetype.match { buf = 0 }
vim.notify("👽 match: " .. tostring(match))
