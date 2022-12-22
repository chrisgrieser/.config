require("config/utils")
--------------------------------------------------------------------------------
bo.path = ".,,../" -- also search parent directory (useful for Alfred)

keymap({ "o", "x" }, "aR", function() varTextObj.jsRegex(false) end, { desc = "outer regex textobj" })
keymap({ "o", "x" }, "iR", function() varTextObj.jsRegex(true) end, { desc = "inner regex textobj" })

-- regex opener
keymap("n", "gR", function()
	varTextObj.jsRegex(false) -- set visual selection to outer regex
	normal('"zy')
	varTextObj.jsRegex(true) -- select inner regex for easy replacement

	local regex = fn.getreg("z")
	local pattern = regex:match("/(.*)/")
	local flags = regex:match("/.*/(.*)")

	-- https://github.com/firasdib/Regex101/wiki/FAQ#how-to-prefill-the-fields-on-the-interface-via-url
	local url = "https://regex101.com/?regex=" .. pattern .. "&flags=" .. flags
	os.execute("open '" .. url .. "'") -- opening method on macOS
end, { desc = "Open next js regex in regex101" })
