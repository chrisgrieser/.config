return {
	{ -- lightweight git client
		"chrisgrieser/nvim-tinygit",
		event = "VeryLazy", -- load for status line component
		keys = {
			-- stylua: ignore start
			{ "gc", function() require("tinygit").smartCommit { pushIfClean = true } end, desc = "󰊢 Smart-commit & push", nowait = true },
			{ "gC", function() require("tinygit").smartCommit { pushIfClean = false } end, desc = "󰊢 Smart-commit" },
			{ "gi", function() require("tinygit").openIssueUnderCursor() end, desc = " Open issue under cursor" },
			{ "<leader>ga", function() require("tinygit").interactiveStaging() end, desc = "󰊢 Interactive staging" },
			{ "<leader>gp", function() require("tinygit").push { pullBefore = true } end, desc = "󰊢 Pull & push" },
			{ "<leader>gP", function() require("tinygit").createGitHubPr() end, desc = " Create PR" },
			{ "<leader>gf", function() require("tinygit").fixupCommit { autoRebase = true } end, desc = "󰊢 Fixup & rebase" },
			{ "<leader>gm", function() require("tinygit").amendNoEdit { forcePushIfDiverged = true } end, desc = "󰊢 Amend-no-edit & f-push" },
			{ "<leader>gM", function() require("tinygit").amendOnlyMsg { forcePushIfDiverged = true } end, desc = "󰊢 Amend only msg & f-push" },
			{ "<leader>gi", function() require("tinygit").issuesAndPrs { state = "open" } end, desc = " Open issues" },
			{ "<leader>gI", function() require("tinygit").issuesAndPrs { state = "closed" } end, desc = " Closed issues" },
			{ "<leader>gh", function() require("tinygit").fileHistory() end, mode = { "n", "x" }, desc = "󰋚 History" },
			{ "<leader>gu", function() require("tinygit").githubUrl() end, mode = { "n", "x" }, desc = " GitHub URL" },
			{ "<leader>gU", function() require("tinygit").githubUrl("repo") end, mode = { "n", "x" }, desc = " GitHub repo URL" },
			{ "<leader>gt", function() require("tinygit").stashPush() end, desc = "󰜦 Stash push" },
			{ "<leader>gT", function() require("tinygit").stashPop() end, desc = "󰜦 Stash pop" },
			{ "<leader>uc", function() require("tinygit").undoLastCommitOrAmend() end, desc = "󰊢 Undo last commit/amend" },
			-- stylua: ignore end
		},
		opts = {
			stage = {
				contextSize = 1,
				moveToNextHunkOnStagingToggle = true,
			},
			commit = {
				preview = true,
				conventionalCommits = { enforce = true },
				spellcheck = true,
				keepAbortedMsgSecs = 60 * 10, -- 10 mins
				insertIssuesOnHashSign = { enabled = true, next = "#" },
			},
			push = {
				openReferencedIssues = true,
			},
			history = {
				autoUnshallowIfNeeded = true,
				diffPopup = { width = 0.9, height = 0.9, border = vim.g.borderStyle },
			},
			statusline = {
				blame = {
					hideAuthorNames = { "Chris Grieser", "chrisgrieser" },
					ignoreAuthors = { "🤖 automated" },
					maxMsgLen = 55,
				},
			},
		},
		config = function(_, opts)
			require("tinygit").setup(opts)

			vim.g.lualineAdd("tabline", "lualine_x", require("tinygit.statusline").blame)
			-- stylua: ignore
			vim.g.lualineAdd("sections", "lualine_y", require("tinygit.statusline").branchState, "before")
		end,
	},
	{ -- git sign gutter & hunk actions
		"lewis6991/gitsigns.nvim",
		event = "VeryLazy",
		opts = {
			signs_staged_enable = true,
			attach_to_untracked = true,
			max_file_length = 3000,
			-- stylua: ignore
			count_chars = { "", "󰬻", "󰬼", "󰬽", "󰬾", "󰬿", "󰭀", "󰭁", "󰭂", ["+"] = "󰿮" },
			signs = {
				delete = { show_count = true },
				topdelete = { show_count = true },
				changedelete = { show_count = true },
			},

			current_line_blame_formatter = "<author> (<author_time:%R>): <summary>",
			current_line_blame_formatter_nc = "+++ uncommitted",
			current_line_blame_opts = {
				virt_text = true, -- can be disabled, and the blame shown via "vim.b.gitsigns_blame_line"
				delay = 500,
			},
		},
		keys = {
			-- stylua: ignore start
			{ "gh", function() require("gitsigns").nav_hunk("next", { foldopen = true, navigation_message = true }) end, desc = "󰊢 Next hunk" },
			{ "gH", function() require("gitsigns").nav_hunk("prev", { foldopen = true, navigation_message = true }) end, desc = "󰊢 Previous hunk" },
			{ "ga", "<cmd>Gitsigns stage_hunk<CR>", desc = "󰊢 Stage hunk" },
			{ "ga", ":Gitsigns stage_hunk<CR>", mode = "x", silent = true, desc = "󰊢 Stage selection" },
			{ "gA", "<cmd>Gitsigns stage_buffer<CR>", desc = "󰊢 Stage buffer" },
			{ "gh", "<cmd>Gitsigns select_hunk<CR>", mode = { "o", "x" }, desc = "󰊢 Hunk textobj" },
			{ "<leader>g!", function() require("gitsigns").blame() end, desc = "󰊢 Blame file" },
			{ "q", vim.cmd.close, ft = "gitsigns-blame", desc = "Close", nowait = true },

			-- UNDO
			{ "<leader>ua", "<cmd>Gitsigns undo_stage_hunk<CR>", desc = "󰊢 Unstage last stage" },
			{ "<leader>uA", "<cmd>Gitsigns reset_buffer_index<CR>", desc = "󰊢 Unstage buffer" },
			{ "<leader>ub", "<cmd>Gitsigns reset_buffer<CR>", desc = "󰊢 Reset buffer" },
			{ "<leader>uh", "<cmd>Gitsigns reset_hunk<CR>", mode = { "n", "x" }, desc = "󰊢 Reset hunk" },
			-- stylua: ignore end
			{
				"<leader>o?",
				function() require("gitsigns").toggle_current_line_blame() end,
				desc = "󰊢 Line blame",
			},
			{
				"<leader>oi",
				function()
					require("gitsigns").toggle_deleted()
					require("gitsigns").toggle_word_diff()
					require("gitsigns").toggle_linehl()
				end,
				desc = "󰊢 Inline diff",
			},
			{
				"<leader>op",
				function()
					local notifyOpts = { title = "Gitsigns", icon = "󰊢" }
					if vim.b.gitsignsPrevChanges then
						require("gitsigns").reset_base()
						vim.notify("Base was reset.", nil, notifyOpts)
						vim.b.gitsignsPrevChanges = false
						return
					end

					local filepath = vim.api.nvim_buf_get_name(0)
					local gitArgs = { "git", "log", "--max-count=1", "--format=%h", "--", filepath }
					local out = vim.system(gitArgs):wait()
					local lastCommitToFile = vim.trim(out.stdout) .. "^"
					require("gitsigns").change_base(lastCommitToFile)
					vim.b.gitsignsPrevChanges = true
					vim.notify("Changed base to " .. lastCommitToFile, nil, notifyOpts)
				end,
				desc = "󰊢 Prev/present hunks",
			},
		},
		config = function(_, opts)
			require("gitsigns").setup(opts)

			-- STATUSLINE CHANGE COUNT
			-- INFO Using gitsigns.nvim's data since lualine's builtin component
			-- is updated much less frequently and is thus often out of sync
			-- with the gitsigns in the signcolumn.
			vim.g.lualineAdd("sections", "lualine_y", {
				"diff",
				source = function()
					local gs = vim.b.gitsigns_status_dict
					if not gs then return end
					return { added = gs.added, modified = gs.changed, removed = gs.removed }
				end,
			}, "before")

			-- STATUSLINE SIGN BASE
			vim.g.lualineAdd("sections", "lualine_y", {
				function() return "" end,
				cond = function() return vim.b.gitsignsPrevChanges end,
			}, "before")
		end,
	},
}
