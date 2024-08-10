local keymap = require("config.utils").bufKeymap

keymap(
	"n",
	"<leader>fp",
	"<cmd>%! yq --prettyPrint --output-format=json .<CR>",
	{ desc = " Prettify Buffer" }
)
