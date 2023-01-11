require("config.utils")
--------------------------------------------------------------------------------
bo.path = ".,,../" -- also search parent directory (useful for Alfred)

keymap({ "o", "x" }, "aR", function() require("various-textobjs").jsRegex(false) end, { desc = "outer regex textobj" })
keymap({ "o", "x" }, "iR", function() require("various-textobjs").jsRegex(true) end, { desc = "inner regex textobj" })

-- Open regex in regex101 and regexper (railroad diagram)
keymap("n", "gR", function()
	require("various-textobjs").jsRegex(false) -- set visual selection to outer regex
	normal('"zy')
	require("various-textobjs").jsRegex(true) -- select inner regex for easy replacement

	local regex = fn.getreg("z")
	local pattern = regex:match("/(.*)/")
	local flags = regex:match("/.*/(%l*)")
	---@diagnostic disable-next-line: param-type-mismatch, undefined-field
	local replacement = fn.getline("."):match('replace ?%(/.*/.*, ?"(.-)"')

	-- https://github.com/firasdib/Regex101/wiki/FAQ#how-to-prefill-the-fields-on-the-interface-via-url
	local url1 = "https://regex101.com/?regex=" .. pattern .. "&flags=" .. flags
	if replacement then url1 = url1 .. "&subst=" .. replacement end
	local url2 = "https://regexper.com/#" .. pattern

	os.execute("open '" .. url1 .. "'") -- opening method on macOS
	os.execute("open '" .. url2 .. "'") 
end, { desc = "Open next js regex in regex101" })
