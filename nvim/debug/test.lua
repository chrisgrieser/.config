-- DOCS https://github.com/nvim-treesitter/nvim-treesitter#adding-queries
-- https://stackoverflow.com/questions/78714013/flutter-web-shows-a-gray-screen-in-hosting-only-without-any-error-in-debug-or-re

local str =
	"https://stackoverflow.com/questions/78714013/flutter-web-shows-a-gray-screen-in-hosting-only-without-any-error-in-debug-or-re"
local host = str:match("^https?://w?w?w?%.?(%w+)")
vim.notify("👾 host: " .. vim.inspect(host))
