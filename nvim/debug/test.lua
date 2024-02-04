local foo = {}
setmetatable(foo, { __index = function ()
	vim.notify("👽 beep 🟩")
end })

vim.notify("👽 foo: " .. tostring(foo.bar))
