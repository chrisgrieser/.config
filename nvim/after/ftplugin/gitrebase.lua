vim.opt_local.list = false

-- add highlighting for commit messages
vim.fn.matchadd("issueNumber", [[#\d\+]])
vim.api.nvim_set_hl(0, "issueNumber", { link = "Number" })

vim.fn.matchadd("mdInlineCode", [[`.\{-}`]]) -- .\{-} = non-greedy quantifier
vim.api.nvim_set_hl(0, "mdInlineCode", { link = "@text.literal" })

--------------------------------------------------------------------------------

-- reminder about order
vim.defer_fn(
	function() vim.notify("top: past\nbottom: future", vim.log.levels.INFO, { title = "rebase" }) end,
	1
)
