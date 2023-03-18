require("config.utils")
--------------------------------------------------------------------------------

bo.path = ".,,../" -- also search parent directory (useful for Alfred)

--------------------------------------------------------------------------------

-- Open regex in regex101 and regexper (railroad diagram)
keymap("n", "g/", function()
	-- keymaps assume a/ and i/ mapped as regex textobj via treesitter textobj
	Normal('"zyya/') -- yank outer regex
	Normal('vi/') -- select inner regex for easy replacement

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
end, { desc = "Open next js regex in regex101", buffer = true })
