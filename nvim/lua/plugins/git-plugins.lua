local u = require("config.utils")
--------------------------------------------------------------------------------
-- some comment here
return {
	{ -- lightweight git client
		"chrisgrieser/nvim-tinygit",
		event = "VeryLazy", -- load for status line component
		ft = "gitrebase", -- so ftplugin is loaded
		keys = {
			-- stylua: ignore start
			{ "gc", function() require("tinygit").smartCommit { pushIfClean = true } end, desc = "󰊢 Smart-Commit & Push" },
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
			{ "<leader>gU", function() require("tinygit").githubUrl("repo") end, desc = " Repo URL" },
			{ "<leader>g#", function() require("tinygit").openIssueUnderCursor() end, desc = " Open Issue under Cursor" },
			{ "<leader>uc", function() require("tinygit").undoLastCommit() end, desc = "󰊢 Undo Last Commit" },
			-- stylua: ignore end
		},
		opts = {
			commitMsg = {
				conventionalCommits = { enforce = true },
				spellcheck = true,
				keepAbortedMsgSecs = 300,
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
					maxMsgLen = 72,
				},
			},
		},
		config = function(_, opts)
			require("tinygit").setup(opts)
			u.addToLuaLine("winbar", "lualine_x", require("tinygit.statusline").blame)
			u.addToLuaLine("inactive_winbar", "lualine_x", require("tinygit.statusline").blame)
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
			{ "ga", ":Gitsigns stage_hunk<CR>", mode = "x", silent = true, desc = "󰊢 Stage Sel" },
			-- stylua: ignore start
			{ "gA", function() require("gitsigns").stage_buffer() end, desc = "󰊢 Add Buffer" },
			{ "<leader>gv", function() require("gitsigns").toggle_deleted() end, desc = "󰊢 View Deletions Inline" },
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
			attach_to_untracked = true,
		},
		config = function(_, opts)
			require("gitsigns").setup(opts)

			-- add hunk-count to lualine
			u.addToLuaLine("sections", "lualine_y", {
				function() return ("%s"):format(#require("gitsigns").get_hunks()) end,
				cond = function()
					local hunks = require("gitsigns").get_hunks()
					return hunks and #hunks > 0
				end,
			})
		end,
	},
}
