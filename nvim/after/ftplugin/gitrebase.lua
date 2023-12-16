vim.opt_local.listchars:remove("multispace")

-- reminder about order
vim.defer_fn(
	function()
		vim.notify_once("top: past\nbottom: future", vim.log.levels.INFO, { title = "rebase" })
	end,
	1
)

-- Cycle Rebase Action
vim.keymap.set("n", "<Tab>", "<C-a>", { desc = "Cycle Action", buffer = true, remap = true })
vim.keymap.set("n", "<S-Tab>", "<C-x>", { desc = "Cycle Action", buffer = true, remap = true })
