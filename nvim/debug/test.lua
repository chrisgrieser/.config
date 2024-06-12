local out = ""
local s = vim.split(out, "\n")
vim.notify("👾 s: " .. vim.inspect(s))

for _, file in ipairs(vim.split(out, "\n")) do
	vim.notify(file)
end
