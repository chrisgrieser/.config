local a = { "one", "two", "three" }
local b = { unpack(a), "four" }
local c = { "four", unpack(a) }
print(#b)
print(#c)
