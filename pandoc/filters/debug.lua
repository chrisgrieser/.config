
-- run in the terminal:
-- touch t.md && pandoc -L debug.lua t.md && rm t.md

function Pandoc(aaa)
	local info = pandoc.cli.default_options.standalone
	print(aaa[1])
	os.exit(0)
end
