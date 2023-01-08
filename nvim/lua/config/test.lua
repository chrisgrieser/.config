local counter = 0

function __dot_repeat(motion)
	if motion == nil then
		vim.o.operatorfunc = "v:lua.__dot_repeat"
		return "g@"
	end

	print("counter:", counter, "motion:", motion)
	counter = counter + 1
end

vim.keymap.set("n", "gt", __dot_repeat, { expr = true })
