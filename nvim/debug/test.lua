local plugins = require("lazy").plugins()
local extra_dependencies = vim.tbl_map(function(plugin) return plugin.extra_dependencies end, plugins)
extra_dependencies = vim.tbl_flatten(vim.tbl_values(extra_dependencies))
vim.notify("🪚 extra_dependencies: " .. vim.inspect(extra_dependencies))
