local bo = vim.bo
local fn = vim.fn
--------------------------------------------------------------------------------

-- do not autowrap
bo.formatoptions = bo.formatoptions:gsub("t", "")

-- when opening large files, start with some folds closed
if fn.line("$") > 100 then
	vim.defer_fn(function() vim.opt_local.foldlevel = 0 end, 1)
end
