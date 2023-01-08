local operator

function restOfParagraph()
	operator = vim.v.operator
	vim.o.operatorfunc = "v:lua.restOfParagraph"
	vim.cmd.normal { operator .. "V}k", bang = true }
	print("operator:", operator)
	return "g@"
end

vim.keymap.set("o", "ä", restOfParagraph, { expr = true })
