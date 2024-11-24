local Account = {
	balance = 0,
	withdraw = function(self, v) self.balance = self.balance - v end,
	deposit = function(self, v) self.balance = self.balance + v end,
	new = function(self, o)
		o = o or {}
		setmetatable(o, self)
		self.__index = self
		return o
	end,
}

local a = Account:new()
a:withdraw(10)
a:deposit(212)
local b = Account:new()
b:withdraw(10)
b:deposit(1)
vim.notify(vim.inspect(b.balance), nil, { title = "🖨️ b.balance", ft = "lua" })
vim.notify(vim.inspect(a.balance), nil, { title = "🖨️ a.balance", ft = "lua" })
