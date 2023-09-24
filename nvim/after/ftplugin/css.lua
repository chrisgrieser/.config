-- extra trailing char
vim.keymap.set("n", "<leader>{", "mzA {<Esc>`z", { desc = "which_key_ignore", buffer = true })

-- toggle !important
vim.keymap.set("n", "<leader>i", function()
	local lineContent = vim.api.nvim_get_current_line()
	if lineContent:find("!important") then
		lineContent = lineContent:gsub(" !important", "")
	else
		lineContent = lineContent:gsub(";?$", " !important;", 1)
	end
	vim.api.nvim_set_current_line(lineContent)
end, { buffer = true, desc = " Toggle !important", nowait = true })

-- SHIMMERING FOCUS SPECIFIC
if vim.fn.expand("%:t") == "source.css" then require("funcs.shimmering-focus") end
