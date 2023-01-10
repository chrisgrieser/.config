function linewiseRestOfParagraph()
	vim.cmd([[normal! V}k]])
end

vim.keymap.set({ "o", "x" }, "r", linewiseRestOfParagraph)

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
