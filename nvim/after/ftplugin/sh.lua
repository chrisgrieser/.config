require("config.utils")
--------------------------------------------------------------------------------

-- pipe textobj
keymap( { "o", "x" }, "iP", function() require("various-textobjs").shellPipe(true) end, { desc = "inner shellPipe textobj", buffer = true })
keymap( { "o", "x" }, "aP", function() require("various-textobjs").shellPipe(false) end, { desc = "outer shellPipe textobj", buffer = true })
