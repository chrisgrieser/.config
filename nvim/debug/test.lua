-- https://www.lua.org/pil/16.html
local Account = {
	balance = 0,
	withdraw = function(self, v) self.balance = self.balance - v end,
	deposit = function(self, v) self.balance = self.balance + v end,
	new = function(self)
		local o = {}
		setmetatable(o, { __index = self })
      return o
	end,
}

local a = Account:new()
vim.notify(vim.inspect(a), nil, { title = "🖨️ a", ft = "lua" })
a:withdraw(10)
a:deposit(212)
vim.notify(vim.inspect(a.balance), nil, { title = "🖨️ a.balance", ft = "lua" })

local b = Account:new()
b:withdraw(10)
b:deposit(1)
vim.notify(vim.inspect(b.balance), nil, { title = "🖨️ b.balance", ft = "lua" })
