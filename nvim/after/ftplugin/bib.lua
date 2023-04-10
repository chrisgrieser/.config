local bo = vim.bo
local fn = vim.fn
--------------------------------------------------------------------------------

-- do not autowrap
bo.formatoptions = bo.formatoptions:gsub("t", "")

-- when opening large files, start with some folds closed
if fn.line("$") > 100 then
	vim.defer_fn(function ()
		require("ufo").closeFoldsWith(0) -- = fold level zero
	end, 1)
end
