local function commitNotification(title, stagedAllChanges, commitMsg, extra)
	local titlePrefix = "tinygit"
	local lines = { '"' .. commitMsg .. '"' }
	if stagedAllChanges then table.insert(lines, 1, "Staged all changes.") end
	if extra then table.insert(lines, extra) end
	local text = table.concat(lines, "\n")

	vim.notify(text, vim.log.levels.INFO, {
		title = titlePrefix .. ": " .. title,
		on_open = function(win)
			local buf = vim.api.nvim_win_get_buf(win)
			local winNs = 2
			vim.api.nvim_win_set_hl_ns(win, winNs)
			local lastLine = vim.api.nvim_buf_line_count(buf) - 1

			-- determine highlights when user uses nvim-notify
			local commitMsgLine = extra and lastLine - 1 or lastLine
			local ccKeywordStart, _, ccKeywordEnd, ccScopeEnd = commitMsg:find("^()%a+()%b()():")
			if not ccKeywordStart then 
				-- has cc keyword, but not scope
				ccKeywordStart, _, ccScopeEnd  = commitMsg:find("^%a+():")
			end

			if ccKeywordStart then
				vim.api.nvim_buf_add_highlight(
					buf,
					winNs,
					"Title",
					commitMsgLine,
					ccKeywordStart + 1, -- offset for quotation marks
					ccKeywordEnd + 1
				)
			end
			if ccScopeEnd then
				vim.api.nvim_buf_add_highlight(
					buf,
					winNs,
					"Parameter",
					commitMsgLine,
					ccKeywordStart + 1, -- offset for quotation marks
					ccScopeEnd + 1
				)
			end

			if stagedAllChanges then vim.api.nvim_buf_add_highlight(buf, winNs, "Keyword", 1, 0, -1) end
			if extra then vim.api.nvim_buf_add_highlight(buf, winNs, "Comment", lastLine, 0, -1) end
		end,
	})
end

commitNotification("Smart-Commit", true, "refactor(scope): yes", "Pushing…")

("foobarbaz"):find("f()oo")
