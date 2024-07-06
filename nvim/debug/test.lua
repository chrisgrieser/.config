-- DOCS https://github.com/nvim-treesitter/nvim-treesitter#adding-queries
-- https://stackoverflow.com/questions/78714013/flutter-web-shows-a-gray-screen-in-hosting-only-without-any-error-in-debug-or-re

local function hello()
	m.bo
	local ft = vim.bo.filetype
	local other_ft = vim.vim.bo.filetype
end
