require("config.utils")
--------------------------------------------------------------------------------

-- do not autowrap
Bo.formatoptions = vim.bo.formatoptions:gsub("t", "")

-- when opening large files, start with some folds closed
if Fn.line("$") > 100 then
	---@diagnostic disable-next-line: param-type-mismatch
	vim.defer_fn(function() vim.opt_local.foldlevel = 0 end, 1)
end
