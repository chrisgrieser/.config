
local timelogStart1 = os.clock() -- 🖨️
print("hi")
print("hi")
print("hi")

vim.notify(("#1 🖨️: %.3fs"):format(os.clock() - timelogStart1))

print("hi")
print("hi")

local timelogStart2 = os.clock() -- 🖨️

print("hi")
print("hi")
print("hi")
print("hi")


vim.notify(("#2 🖨️: %.3fs"):format(os.clock() - timelogStart2))
