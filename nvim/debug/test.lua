local teststr = "foobar"
local hello = { teststr:match("(...)(...)") }
local one, two = unpack(hello)
print("🖨️ one: ", one)
print("🖨️ two: ", two)
