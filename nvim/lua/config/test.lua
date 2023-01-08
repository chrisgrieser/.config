
local operator
function dotrepeat()
	operator = vim.v.operator
	vim.o.operatorfunc = "v:lua.restOfParagraph"
	return "g@"
end

function restOfParagraph()
	print("operator:", operator)
	-- vim.cmd.normal { operator .. "V}k", bang = true }
end

vim.keymap.set("o", "ä", dotrepeat, { expr = true })

-- Morbi vitae ligula est. Fusce eleifend blandit convallis.
-- Etiam leo massa, fringilla nec imperdiet sit amet, accumsan nec nisi. 
-- Suspendisse accumsan id diam et tincidunt. 
-- Praesent elementum metus non porttitor dapibus. 
-- Curabitur pretium malesuada dolor, tempor mollis lacus hendrerit at. 

