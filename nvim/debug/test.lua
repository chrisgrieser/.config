-- https://www.lua.org/pil/16.html
local Account = {
	balance = 0,
	withdraw = function(self, v) self.balance = self.balance - v end,
	deposit = function(self, v) self.balance = self.balance + v end,
	new = function(self)
		local o = {}
		setmetatable(o, self)
      -- self.__index = self
		vim.notify(vim.inspect(o), nil, { title = "🖨️ o", ft = "lua" })
      return o
	end,
}

local a = Account:new()
a:withdraw(10)
a:deposit(212)
vim.notify(vim.inspect(a.balance), nil, { title = "🖨️ a.balance", ft = "lua" })

-- local b = Account:new()
-- b:withdraw(10)
-- b:deposit(1)
-- vim.notify(vim.inspect(b.balance), nil, { title = "🖨️ b.balance", ft = "lua" })
