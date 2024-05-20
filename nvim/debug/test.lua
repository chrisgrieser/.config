-- vim.deprecate
local t = vim.iter(require("lazy").plugins())
	:find(function(plugin) return plugin[1]:find("dressing") end)
vim.notify("⭕ t: " .. vim.inspect(t._.super._.module))
