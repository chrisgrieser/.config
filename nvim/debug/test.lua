local function commitNotification(title, stagedAllChanges, commitMsg, extra)
	local titlePrefix = "tinygit"
	local lines = { commitMsg }
	if stagedAllChanges then table.insert(lines, 1, "Staged all changes.") end
	if extra then table.insert(lines, extra) end
	local text = table.concat(lines, "\n")

	vim.notify(text, vim.log.levels.INFO, {
		title = titlePrefix .. ": " .. title,
		on_open = function(win)
			-- HACK manually determining git commit stuff, since fn.matchadd does
			-- not work in a non-focussed window and since setting the filetype to
			-- "gitcommit" does not work well with nvim-notify
			local buf, ns = vim.api.nvim_win_get_buf(win), 2
			vim.api.nvim_win_set_hl_ns(win, ns)
			local lastLine = vim.api.nvim_buf_line_count(buf) - 1

			local commitMsgLine = extra and lastLine - 1 or lastLine
			local ccKeywordStart, _, ccKeywordEnd, ccScopeEnd = commitMsg:find("^%a+()%b()():")



			if not ccKeywordStart then
				-- has cc keyword, but not scope
				ccKeywordStart, _, ccKeywordEnd = commitMsg:find("^%a+():")
			end
			if ccKeywordStart then
				-- stylua: ignore
				vim.api.nvim_buf_add_highlight(buf, ns, "Keyword", commitMsgLine, ccKeywordStart, ccKeywordEnd)
			end
			if ccScopeEnd then
				local ccScopeStart = ccKeywordEnd
				-- stylua: ignore
				vim.api.nvim_buf_add_highlight(buf, ns, "@parameter", commitMsgLine, ccScopeStart + 1, ccScopeEnd - 1)
			end

			local issueNumberStart, issueNumberEnd = commitMsg:find("#%d+")
			if issueNumberStart then
				-- stylua: ignore
				vim.api.nvim_buf_add_highlight(buf, ns, "Number", commitMsgLine, issueNumberStart, issueNumberEnd + 1)
			end

			if stagedAllChanges then vim.api.nvim_buf_add_highlight(buf, ns, "Comment", 1, 0, -1) end
			if extra then vim.api.nvim_buf_add_highlight(buf, ns, "Comment", lastLine, 0, -1) end
		end,
	})
end

commitNotification("Smart-Commit", true, "refactor(scope): yes #1", "Pushing…")

-- ("refactor(scope): blaa"):find("refactor()%b()()")
