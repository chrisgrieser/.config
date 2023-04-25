local bo = vim.bo
local fn = vim.fn
--------------------------------------------------------------------------------

-- do not autowrap
bo.formatoptions = bo.formatoptions:gsub("t", "")

-- for some reason, bib files have no comment string defined, even though they
-- do have comments?
bo.commentstring = "% %s"

-- when opening large files, start toplevel folds closed
if fn.line("$") > 100 then vim.defer_fn(function() vim.cmd("%foldclose") end, 1) end
