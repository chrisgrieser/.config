
---toggle wrap, colorcolumn, and hjkl visual/logical maps in one go
function M.toggleWrap()
	local opts = { buffer = true }
	local wrapOn = vim.opt_local.wrap:get()
	if wrapOn then
		vim.opt_local.wrap = false
		vim.opt_local.colorcolumn = vim.opt.colorcolumn:get()
		vim.keymap.del({ "n", "x" }, "H", opts)
		vim.keymap.del({ "n", "x" }, "L", opts)
		vim.keymap.del({ "n", "x" }, "J", opts)
		vim.keymap.del({ "n", "x" }, "K", opts)
		vim.keymap.del({ "n", "x" }, "k", opts)
		vim.keymap.del({ "n", "x" }, "j", opts)
	else
		vim.opt_local.wrap = true
		vim.opt_local.colorcolumn = ""
		vim.keymap.set({ "n", "x" }, "H", "g^", opts)
		vim.keymap.set({ "n", "x" }, "L", "g$", opts)
		vim.keymap.set({ "n", "x" }, "J", function() M.overscroll("6gj") end, opts)
		vim.keymap.set({ "n", "x" }, "K", "6gk", opts)
		vim.keymap.set({ "n", "x" }, "k", "gk", opts)
		vim.keymap.set({ "n", "x" }, "j", function() M.overscroll("gj") end, opts)
	end
end

