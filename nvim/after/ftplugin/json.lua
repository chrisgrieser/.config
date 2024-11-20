local bkeymap = require("config.utils").bufKeymap
--------------------------------------------------------------------------------

bkeymap(
	"n",
	"<leader>fp",
	"<cmd>%! yq --output-format=json --prettyPrint<CR>",
	{ desc = " Prettify Buffer" }
)

bkeymap(
	"n",
	"<leader>fm",
	"<cmd>%! yq --output-format=json --indent=0<CR>",
	{ desc = " Minify Buffer" }
)

bkeymap("n", "o", function()
	local line = vim.api.nvim_get_current_line()
	if line:find("[^,{[]$") then return "A,<cr>" end
	return "o"
end, { expr = true, desc = " Auto-add comma on `o`" })
