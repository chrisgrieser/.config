local projectFolder = os.getenv("HOME") .. "/repos" -- CONFIG
local handler = vim.loop.fs_scandir(projectFolder)
if not handler then return end

local mytable = {
	one = 1,
	two = 2,
	three = 3,
}
local it = next(mytable)

local k, v = it()
vim.notify("🪚 v: " .. tostring(v))
vim.notify("🪚 k: " .. tostring(k))

k, v = it()
vim.notify("🪚 v: " .. tostring(v))
vim.notify("🪚 k: " .. tostring(k))

k, v = it()
vim.notify("🪚 v: " .. tostring(v))
vim.notify("🪚 k: " .. tostring(k))

