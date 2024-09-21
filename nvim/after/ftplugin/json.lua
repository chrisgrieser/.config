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
