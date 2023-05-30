local bo = vim.bo
local fn = vim.fn
--------------------------------------------------------------------------------

-- do not autowrap
bo.formatoptions = bo.formatoptions:gsub("t", "")

-- for some reason, bib files have no comment string defined, even though they
-- do have comments?
bo.commentstring = "% %s"
