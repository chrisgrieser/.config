local hunk = "@@ -123,1 +999,3 @@"
local _, lnum, size1, size2 = hunk:match("@@ %-(%d+),?(%d*) %+(%d+),?(%d*) @@")
vim.notify("👾 size2: " .. tostring(size2))
vim.notify("👾 size1: " .. tostring(size1))
vim.notify("👾 lnum: " .. tostring(lnum))

