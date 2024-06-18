function _G.myFunc(motion, b)
	if motion == nil then
		vim.o.operatorfunc = "v:lua.myFunc"
		return "g@"
	end

	print("motion:", motion, "b:", b)
end

vim.keymap.set("n", "gt", _G.myFunc, { expr = true }) -- 1.
