local teststr = "foobar"
local hello = { teststr:match("(foo)(bar)") }
local one, two = unpack(hello)
print("🖨️ one: ", one)
print("🖨️ two: ", two)
