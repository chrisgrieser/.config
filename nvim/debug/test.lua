

local foo = {
	bar = 1
}
vim.notify(vim.inspect(foo), nil, { title = "🪚 foo", ft = "lua" })
local function foobar()
	return foo
end

foobar()
