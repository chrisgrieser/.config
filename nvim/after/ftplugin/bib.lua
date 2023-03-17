require("config.utils")
-- do not autowrap
bo.formatoptions = vim.bo.formatoptions:gsub("t", "") 

-- start with folds closed
if fn.line("$") > 100 then
	---@diagnostic disable-next-line: param-type-mismatch
	vim.defer_fn(function () require("ufo").closeFoldsWith(0) end, 1)
end
