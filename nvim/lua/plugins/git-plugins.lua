return {
	{ -- lightweight git client
		"chrisgrieser/nvim-tinygit",
		event = "VeryLazy", -- load for status line component
		keys = {
			-- stylua: ignore start
			{ "gc", function() require("tinygit").smartCommit { pushIfClean = true } end, desc = "󰊢 Smart-Commit & Push", nowait = true },
			{ "gC", function() require("tinygit").smartCommit { pushIfClean = false } end, desc = "󰊢 Smart-Commit" },
			{ "gi", function() require("tinygit").openIssueUnderCursor() end, desc = " Open Issue under Cursor" },
			{ "<leader>ga", function() require("tinygit").interactiveStaging() end, desc = "󰊢 Interactive Staging" },
			{ "<leader>gp", function() require("tinygit").push { pullBefore = true } end, desc = "󰊢 Pull & Push" },
			{ "<leader>gP", function() require("tinygit").push { createGitHubPr = true } end, desc = " Push & PR" },
			{ "<leader>gf", function() require("tinygit").fixupCommit { autoRebase = true } end, desc = "󰊢 Fixup & Rebase" },
			{ "<leader>gm", function() require("tinygit").amendNoEdit { forcePushIfDiverged = true } end, desc = "󰊢 Amend-No-Edit & F-Push" },
			{ "<leader>gM", function() require("tinygit").amendOnlyMsg { forcePushIfDiverged = true } end, desc = "󰊢 Amend Only Msg & F-Push" },
			{ "<leader>gi", function() require("tinygit").issuesAndPrs { state = "open" } end, desc = " Open Issues" },
			{ "<leader>gI", function() require("tinygit").issuesAndPrs { state = "closed" } end, desc = " Closed Issues" },
			{ "<leader>gd", function() require("tinygit").searchFileHistory() end, desc = "󰢷 File History" },
			{ "<leader>gh", function() require("tinygit").lineHistory() end, mode = { "n", "x" }, desc = "󰢷 Line History" },
			{ "<leader>gH", function() require("tinygit").functionHistory() end, desc = "󰢷 Function History" },
			{ "<leader>gu", function() require("tinygit").githubUrl() end, mode = { "n", "x" }, desc = " GitHub URL" },
			{ "<leader>gU", function() require("tinygit").githubUrl("repo") end, mode = { "n", "x" }, desc = " GitHub Repo URL" },
			{ "<leader>uc", function() require("tinygit").undoLastCommitOrAmend() end, desc = "󰊢 Undo Last Commit/Amend" },
			{ "<leader>gt", function() require("tinygit").stashPush() end, desc = "󰜦 Stash Push" },
			{ "<leader>gT", function() require("tinygit").stashPop() end, desc = "󰜦 Stash Pop" },
			-- stylua: ignore end
		},
		opts = {
			staging = {
				contextSize = 2,
				moveToNextHunkOnStagingToggle = true,
			},
			commitMsg = {
				commitPreview = true,
				conventionalCommits = { enforce = true },
				spellcheck = true,
				keepAbortedMsgSecs = 60 * 10, -- 10 mins
				insertIssuesOnHash = { enabled = true, next = "#" },
			},
			push = {
				openReferencedIssues = true,
			},
			historySearch = {
				autoUnshallowIfNeeded = true,
				diffPopup = { width = 0.9, height = 0.9, border = vim.g.borderStyle },
			},
			statusline = {
				blame = {
					hideAuthorNames = { "Chris Grieser", "chrisgrieser" },
					ignoreAuthors = { "🤖 automated" },
					maxMsgLen = 50,
				},
				branchState = {
					icons = { diverge = "󰞇 " },
				},
			},
		},
		config = function(_, opts)
			require("tinygit").setup(opts)

			vim.g.lualine_add("tabline", "lualine_x", require("tinygit.statusline").blame)
			vim.g.lualine_add(
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
		},
		keys = {
			-- stylua: ignore start
			{ "ga", "<cmd>Gitsigns stage_hunk<CR>", desc = "󰊢 Stage Hunk" },
			{ "ga", ":Gitsigns stage_hunk<CR>", mode = "x", silent = true, desc = "󰊢 Stage Selection" },
			{ "gA", "<cmd>Gitsigns stage_buffer<CR>", desc = "󰊢 Add Buffer" },
			{ "gh", "<cmd>Gitsigns nav_hunk next<CR>", desc = "󰊢 Next Hunk" },
			{ "gH", "<cmd>Gitsigns nav_hunk prev<CR>", desc = "󰊢 Previous Hunk" },
			{ "gh", "<cmd>Gitsigns select_hunk<CR>", mode = { "o", "x" }, desc = "󱡔 󰊢 Hunk textobj" },
			{ "<leader>g?", function() require("gitsigns").blame_line() end, desc = " Blame Line" },
			{ "<leader>g!", function() require("gitsigns").blame() end, desc = " Blame File" },
			{ "q", vim.cmd.close, ft = "gitsigns.blame", desc = "Close", nowait = true },

			-- UNDO
			{ "<leader>ua", "<cmd>Gitsigns undo_stage_hunk<CR>", desc = "󰊢 Unstage Last Stage" },
			{ "<leader>uA", "<cmd>Gitsigns reset_buffer_index<CR>", desc = "󰊢 Unstage Buffer" },
			{ "<leader>ub", "<cmd>Gitsigns reset_buffer<CR>", desc = "󰊢 Reset Buffer" },
			{ "<leader>uh", "<cmd>Gitsigns reset_hunk<CR>", mode = { "n", "x" }, desc = "󰊢 Reset Hunk" },

			-- OPTIONS
			{ "<leader>oi", "<cmd>Gitsigns toggle_deleted<CR>", desc = "󰊢 Inline Deletions" },
			-- stylua: ignore end
			{
				"<leader>op",
				function()
					if vim.b.gitsigns_previous_changes then
						require("gitsigns").reset_base()
						vim.notify("Gitsigns: Reset Base")
						vim.b.gitsigns_previous_changes = false
						return
					end

					local file = vim.api.nvim_buf_get_name(0)
					local gitArgs = { "git", "log", "-1", "--format=%h", "--", file }
					local out = vim.system(gitArgs):wait()
					assert(out.code == 0, "git log failed")
					local lastCommitToFile = vim.trim(out.stdout) .. "^"
					require("gitsigns").change_base(lastCommitToFile)
					vim.b.gitsigns_previous_changes = true
					vim.notify("Gitsigns: Changed base to " .. lastCommitToFile)
				end,
				desc = "󰊢 Previous/Present Changes",
			},
		},
		config = function(_, opts)
			require("gitsigns").setup(opts)

			vim.g.lualine_add(
				"sections",
				"lualine_y", -- same section as diff count
				{
					function() return "" end,
					cond = function() return vim.b.gitsigns_previous_changes end,
				},
				"before"
			)
		end,
	},
}
