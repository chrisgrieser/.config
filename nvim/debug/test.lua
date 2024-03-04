local function myFunc()
	local info = debug.getinfo(1, "n").name
	print(info)
end
myFunc()
