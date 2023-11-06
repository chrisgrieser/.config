vim.v.oldfiles = vim.tbl_filter(function(path)
	local ignore = path:find("%.log$") or vim.fs.basename(path) == "COMMIT_EDITMSG"
	return not ignore
end, vim.v.oldfiles)
