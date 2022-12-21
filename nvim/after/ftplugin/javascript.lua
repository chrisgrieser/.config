require("config/utils")
--------------------------------------------------------------------------------
bo.path = ".,,../" -- also search parent directory (useful for Alfred)

keymap({ "o", "x" }, "aR", function() varTextObj.jsRegex(false) end, { desc = "outer regex textobj" })
keymap({ "o", "x" }, "iR", function() varTextObj.jsRegex(true) end, { desc = "inner regex textobj" })
