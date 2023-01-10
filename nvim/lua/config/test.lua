-- vim.keymap.set({ "o", "x" }, "r", ":<C-U>normal! V}k<CR>")

function linewiseRestOfParagraph()
	vim.api.nvim_feedkeys(":", "nx", false)
	local key = vim.api.nvim_replace_termcodes("<C-u>", false, true, true)
	vim.api.nvim_feedkeys(key, "nx", false)

	vim.cmd.normal { "V}k", bang = true }
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


