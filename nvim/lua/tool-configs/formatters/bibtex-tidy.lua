local fs = require("efmls-configs.fs")

local formatter = "bibtex-tidy"
local args = {
	"--tab",
	"--curly",
	"--strip-enclosing-braces",
	"--enclosing-braces=title,journal,booktitle",
	"--numeric",
	"--months",
	"--no-align",
	"--encode-urls",
	"--duplicates",
	"--drop-all-caps",
	"--sort-fields",
	"--remove-empty-fields",
	"--no-wrap",
}
local command =
	string.format("%s --quiet %s", fs.executable(formatter, fs.Scope.NODE), table.concat(args, " "))

return {
	formatCommand = command,
	formatStdin = true,
}
