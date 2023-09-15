local toolsToKeep = {"stylua"}
local tools = require("mason-registry").get_installed_packages()
tools = vim.tbl_filter(function(t) return not vim.tbl_contains(t.spec.categories, "LSP") end, tools)
tools = vim.tbl_map(function(t) return t.name end, tools)
local toUninstall = vim.tbl_filter(function(t) return not vim.tbl_contains(toolsToKeep, t) end, tools)
