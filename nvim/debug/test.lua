local diff = vim.system({ "git", "diff", "--color=always" }):wait().stdout or "??"
local lines = vim.split(diff, "\n", { trimempty = true })
local buf = vim.api.nvim_create_buf(false, true)


require("snacks").win {
	relative = "editor",
	position = "float",
	title = " test ",
	buf = buf,
	width = 80,
	height = 20,
}

vim.api.nvim_chan_send(vim.api.nvim_open_term(buf, {}), table.concat(lines, "\r\n"))
