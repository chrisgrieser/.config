vim.opt_local.listchars:remove("multispace")

if not vim.g.tinygit_no_rebase_ftplugin then
	-- add highlighting for commit messages
	vim.fn.matchadd("rebase_issueNumber", [[#\d\+]])
	vim.api.nvim_set_hl(0, "rebase_issueNumber", { link = "Number" })

	vim.fn.matchadd("rebase_mdInlineCode", [[`.\{-}`]]) -- .\{-} = non-greedy quantifier
	vim.api.nvim_set_hl(0, "rebase_mdInlineCode", { link = "@text.literal" })

	vim.fn.matchadd(
		"rebase_conventionalCommit",
		[[\v (feat|fix|test|perf|build|ci|revert|refactor|chore|docs|break|improv)(!|(.{-}))?\ze:]]
	)
	vim.api.nvim_set_hl(0, "rebase_conventionalCommit", { link = "Title" })

	vim.fn.matchadd("rebase_fixupSquash", [[ fixup\!]])
	vim.api.nvim_set_hl(0, "rebase_fixupSquash", { link = "Warning" })

	-- quit rebasing
	vim.keymap.set("n", "q", vim.cmd.cquit, { buffer = true, desc = "Quit Rebase", nowait = true })

	-- rebase action toggle
	vim.keymap.set("n", "<Tab>", function()
		local modes = {
			"squash",
			"fixup",
			"pick",
			"reword",
			"drop",
		}
		local curLine = vim.api.nvim_get_current_line()
		local firstWord = curLine:match("^%s*(%a+)")

		for i = 1, #modes do
			if firstWord == modes[i] then
				local nextMode = modes[(i % #modes) + 1]
				local changedLine = curLine:gsub(firstWord, nextMode, 1)
				vim.api.nvim_set_current_line(changedLine)
				return
			elseif firstWord == modes[i]:sub(1, 1) then
				local nextMode = modes[(i % #modes) + 1]:sub(1, 1)
				local changedLine = curLine:gsub(firstWord, nextMode, 1)
				vim.api.nvim_set_current_line(changedLine)
				return
			end
		end
	end, { buffer = true, desc = "Toggle Rebase Action" })
end

--------------------------------------------------------------------------------

-- reminder about order
vim.defer_fn(
	function() vim.notify("top: past\nbottom: future", vim.log.levels.INFO, { title = "rebase" }) end,
	1
)
