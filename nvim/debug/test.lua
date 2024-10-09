local str = "## main...origin/main"
local one, two = str:match("## (.-)%.%.%.")
vim.notify("🖨️ one: " .. tostring(one))
vim.notify("🖨️ two: " .. tostring(two))

