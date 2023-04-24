-- run in the terminal:
-- touch t.md && pandoc -L debug.lua t.md && rm t.md

-- can also use a pandoc repl for simple things: `pandoc lua`
--------------------------------------------------------------------------------

function Pandoc()
	local opts = pandoc.cli.parse_options(arg)

	print(opts)
	os.exit(0)
end
