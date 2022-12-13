require("utils")
--------------------------------------------------------------------------------

jjjjj = 1
a = jjjjj + 2

-- for i = 1, 10 do
-- 	print(i)
-- 	j = j + 2
-- 	print(j)
-- end

-- clipboard & yanking
opt.clipboard = "unnamedplus"
augroup("highlightedYank", {})
autocmd("TextYankPost", {
	group = "highlightedYank",
	callback = function() vim.highlight.on_yank {timeout = 2000} end
})


keymap("n", "x", '"_x')
i = 6
i = 7
i = 8
i = 9
i = 7
i = 8
i = 9
i = 7
i = 8
i = 9
i = 8
i = 9
i = 1
i = 1
i = 1
i = 3
i = 4
i = 5
i = 6
i = 7
i = 8
i = 9
i = 10
i = 11
