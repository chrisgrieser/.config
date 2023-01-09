function dotrepeat()
	g.my_operator = vim.v.operator
	vim.o.operatorfunc = "v:lua.linewiseRestOfParagraph"
	return "g@"
end

function linewiseRestOfParagraph()
	vim.cmd.normal { g.my_operator .. "V}k", bang = true }
end

vim.keymap.set({ "o", "x" }, "r", dotrepeat, { expr = true })

-- Morbi vitae ligula est. Fusce eleifend blandit convallis.
-- Etiam leo massa, fringilla nec imperdiet sit amet, accumsan nec nisi.
-- Suspendisse accumsan id diam et tincidunt.
-- Praesent elementum metus non porttitor dapibus.
-- Curabitur pretium malesuada dolor, tempor mollis lacus hendrerit at.

-- Morbi vitae ligula est. Fusce eleifend blandit convallis.
-- Etiam leo massa, fringilla nec imperdiet sit amet, accumsan nec nisi.
-- Suspendisse accumsan id diam et tincidunt.
-- Praesent elementum metus non porttitor dapibus.
-- Curabitur pretium malesuada dolor, tempor mollis lacus hendrerit at.


