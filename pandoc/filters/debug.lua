-- run in the terminal:
-- touch t.md && pandoc -L debug.lua t.md && rm t.md

function Pandoc()
	local opts = pandoc.cli.parse_options(arg)

	print(opts)
	os.exit(0)
end
