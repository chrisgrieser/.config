vim.keymap.set("n", "W", function()
	local pattern = "[%w_]+"
	require("spider").motion("w", {
		customPatterns = { pattern },
	})
end, { desc = "spider-W-motion" })

--------------------------------------------------------------------------------

local another_var_name = 42
local my_var_name = another_var_name
vim.notify("⭕ my_var_name: " .. tostring(my_var_name))
