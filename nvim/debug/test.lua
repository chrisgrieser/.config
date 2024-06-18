function _G.myFunc(motionType)
	if motionType == nil then
		vim.o.operatorfunc = "v:lua.myFunc"
		return "g@"
	end

	print(motionType)
end

print("lllllbllbblll")
