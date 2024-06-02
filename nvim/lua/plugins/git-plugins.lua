local u = require("config.utils")
--------------------------------------------------------------------------------

return {
	{ -- lightweight git client
		"chrisgrieser/nvim-tinygit",
		event = "VeryLazy", -- load for status line component
		ft = "gitrebase", -- so ftplugin is loaded
		keys = {
			-- stylua: ignore start
			{ "gc", function() require("tinygit").smartCommit({ pushIfClean = false}) end, desc = "󰊢 Smart-Commit & Push", nowait = true },
			{ "gC", function() require("tinygit").smartCommit { pushIfClean = false } end, desc = "󰊢 Smart-Commit" },
			{ "<leader>gp", function() require("tinygit").push { pullBefore = true } end, desc = "󰊢 Pull & Push" },
			{ "<leader>gP", function() require("tinygit").push { createGitHubPr = true } end, desc = " Push & PR" },
			{ "<leader>gf", function() require("tinygit").fixupCommit({ autoRebase = true }) end, desc = "󰊢 Fixup & Rebase" },
			{ "<leader>gm", function() require("tinygit").amendNoEdit { forcePushIfDiverged = true } end, desc = "󰊢 Amend-No-Edit & F-Push" },
			{ "<leader>gM", function() require("tinygit").amendOnlyMsg { forcePushIfDiverged = true } end, desc = "󰊢 Amend Only Msg & F-Push" },
			{ "<leader>gi", function() require("tinygit").issuesAndPrs { state = "open" } end, desc = " Open Issues" },
			{ "<leader>gI", function() require("tinygit").issuesAndPrs { state = "closed" } end, desc = " Closed Issues" },
			{ "<leader>gd", function() require("tinygit").searchFileHistory() end, desc = "󰢷 File History" },
			{ "<leader>gD", function() require("tinygit").functionHistory() end, desc = "󰢷 Function History" },
			{ "<leader>gu", function() require("tinygit").githubUrl() end, mode = { "n", "x" }, desc = " GitHub URL" },
			{ "<leader>g#", function() require("tinygit").openIssueUnderCursor() end, desc = " Open Issue under Cursor" },
			{ "<leader>uc", function() require("tinygit").undoLastCommitOrAmend() end, desc = "󰊢 Undo Last Commit/Amend" },
			-- stylua: ignore end
		},
		opts = {
			commitMsg = {
				conventionalCommits = { enforce = true },
				spellcheck = true,
				keepAbortedMsgSecs = 60 * 10,
			},
			historySearch = {
				autoUnshallowIfNeeded = true,
				diffPopup = {
					width = 0.9,
					height = 0.9,
					border = vim.g.borderStyle,
				},
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

			u.addToLuaLine("tabline", "lualine_x", require("tinygit.statusline").blame)
			u.addToLuaLine(
				"sections",
				"lualine_y",
				require("tinygit.statusline").branchState,
				"before"
			)
		end,
	},
	{ -- git sign gutter & hunk actions
		"lewis6991/gitsigns.nvim",
		event = "VeryLazy",
		keys = {
			{ "ga", "<cmd>Gitsigns stage_hunk<CR>", desc = "󰊢 Stage Hunk" },
			-- stylua: ignore start
			{ "ga", ":Gitsigns stage_hunk<CR>", mode = "x", silent = true, desc = "󰊢 Stage Selection" },
			{ "gA", function() require("gitsigns").stage_buffer() end, desc = "󰊢 Add Buffer" },
			{ "<leader>og", function() require("gitsigns").toggle_deleted() end, desc = "󰊢 Deletions Inline" },
			{ "<leader>ua", function() require("gitsigns").undo_stage_hunk() end, desc = "󰊢 Unstage Last Stage" },
			{ "<leader>uh", function() require("gitsigns").reset_hunk() end, desc = "󰊢 Reset Hunk" },
			{ "<leader>ub", function() require("gitsigns").reset_buffer() end, desc = "󰊢 Reset Buffer" },
			{ "<leader>ob", function() require("gitsigns").toggle_current_line_blame() end, desc = "󰊢 Git Blame"},
			{ "gh", function() require("gitsigns").next_hunk { foldopen = true } end, desc = "󰊢 Next Hunk" },
			{ "gH", function() require("gitsigns").prev_hunk { foldopen = true } end, desc = "󰊢 Previous Hunk" },
			{ "gh", function() require("gitsigns").select_hunk() end, mode = { "o", "x" }, desc = "󱡔 󰊢 Hunk textobj" }, -- stylua: ignore end
			-- stylua: ignore end
		},
		opts = {
			attach_to_untracked = true,
			max_file_length = 12000, -- lines
			-- deletions greater than one line will show a count to assess the size
			-- (digits are actually nerdfont numbers to achieve smaller size)
			-- stylua: ignore
			count_chars = { "", "󰬻", "󰬼", "󰬽", "󰬾", "󰬿", "󰭀", "󰭁", "󰭂", ["+"] = "󰿮" },
			signs = {
				delete = { show_count = true },
				topdelete = { show_count = true },
				changedelete = { show_count = true },
			},
		},
	},
}
