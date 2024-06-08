local u = require("config.utils")

-- Needs to be triggered manually, since lualine updates the git diff
-- component only on BufEnter.
local function updateLualineDiff()
	if package.loaded["lualine"] then
		require("lualine.components.diff.git_diff").update_diff_args()
	end
end
--------------------------------------------------------------------------------

return {
	{ -- lightweight git client
		"chrisgrieser/nvim-tinygit",
		event = "VeryLazy", -- load for status line component
		ft = "gitrebase", -- so ftplugin is loaded
		keys = {
			-- stylua: ignore start
			{ "gc", function() require("tinygit").smartCommit { pushIfClean = true } end, desc = "󰊢 Smart-Commit & Push", nowait = true },
			{ "gC", function() require("tinygit").smartCommit { pushIfClean = false } end, desc = "󰊢 Smart-Commit" },
			{ "<leader>gp", function() require("tinygit").push { pullBefore = true } end, desc = "󰊢 Pull & Push" },
			{ "<leader>gP", function() require("tinygit").push { createGitHubPr = true } end, desc = " Push & PR" },
			{ "<leader>gf", function() require("tinygit").fixupCommit { autoRebase = true } end, desc = "󰊢 Fixup & Rebase" },
			{ "<leader>gm", function() require("tinygit").amendNoEdit { forcePushIfDiverged = true } end, desc = "󰊢 Amend-No-Edit & F-Push" },
			{ "<leader>gM", function() require("tinygit").amendOnlyMsg { forcePushIfDiverged = true } end, desc = "󰊢 Amend Only Msg & F-Push" },
			{ "<leader>gi", function() require("tinygit").issuesAndPrs { state = "open" } end, desc = " Open Issues" },
			{ "<leader>gI", function() require("tinygit").issuesAndPrs { state = "closed" } end, desc = " Closed Issues" },
			{ "<leader>gd", function() require("tinygit").searchFileHistory() end, desc = "󰢷 File History" },
			{ "<leader>gD", function() require("tinygit").functionHistory() end, desc = "󰢷 Function History" },
			{ "<leader>gu", function() require("tinygit").githubUrl() end, mode = { "n", "x" }, desc = " GitHub URL" },
			{ "<leader>gU", function() require("tinygit").githubUrl("repo") end, mode = { "n", "x" }, desc = " GitHub Repo URL" },
			{ "<leader>g#", function() require("tinygit").openIssueUnderCursor() end, desc = " Open Issue under Cursor" },
			{ "<leader>uc", function() require("tinygit").undoLastCommitOrAmend() end, desc = "󰊢 Undo Last Commit/Amend" },
			-- stylua: ignore end
		},
		opts = {
			commitMsg = {
				conventionalCommits = { enforce = true },
				spellcheck = true,
				keepAbortedMsgSecs = 60 * 10, -- 10 mins
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
			{
				"ga",
				function()
					local range = nil
					if vim.fn.mode() == "V" then
						u.normal("V") -- leave visual mode so <> marks are set
						local startLn = vim.api.nvim_buf_get_mark(0, "<")[1]
						local endLn = vim.api.nvim_buf_get_mark(0, ">")[1]
						range = { startLn, endLn }
					end
					require("gitsigns").stage_hunk(range, nil, updateLualineDiff)
				end,
				mode = { "n", "x" },
				desc = "󰊢 Stage Hunk/Selection",
			},
			{
				"<leader>uh",
				function() require("gitsigns").reset_hunk(nil, nil, updateLualineDiff) end,
				mode = { "n", "x" },
				desc = "󰊢 Reset Hunk",
			},
			-- stylua: ignore start
			{ "gA", function() require("gitsigns").stage_buffer() end, desc = "󰊢 Add Buffer" },
			{ "gh", function() require("gitsigns").next_hunk() end, desc = "󰊢 Next Hunk" },
			{ "gH", function() require("gitsigns").prev_hunk() end, desc = "󰊢 Previous Hunk" },
			{ "gh", function() require("gitsigns").select_hunk() end, mode = { "o", "x" }, desc = "󱡔 󰊢 Hunk textobj" }, -- stylua: ignore end
			{ "<leader>g?", function() require("gitsigns").blame_line { full = true } end, desc = " Blame Line" }, -- stylua: ignore end

			-- undo,
			{ "<leader>ua", function() require("gitsigns").undo_stage_hunk() end, desc = "󰊢 Unstage Last Stage" },
			{ "<leader>uA", function() require("gitsigns").reset_buffer_index() end, desc = "󰊢 Unstage Buffer" },
			{ "<leader>ub", function() require("gitsigns").reset_buffer() end, desc = "󰊢 Reset Buffer" },

			{ "<leader>oi", function() require("gitsigns").toggle_deleted() end, desc = "󰊢 Inline Deletions" },
			{ "<leader>o?", function() require("gitsigns").toggle_current_line_blame() end, desc = " Git Blame"},
			-- stylua: ignore end
			{
				"<leader>op",
				function()
					if vim.b.gitsigns_previous_changes then
						require("gitsigns").reset_base()
						u.notify("GitSigns", "Reset Base")
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
					u.notify("GitSigns", "Changed base to " .. lastCommitToFile)
				end,
				desc = "󰊢 Previous/Present Changes",
			},
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
		config = function(_, opts)
			require("gitsigns").setup(opts)

			u.addToLuaLine(
				"sections",
				"lualine_y", -- same section as diff count
				{
					function() return "" end,
					cond = function() return vim.b.gitsigns_previous_changes end,
					color = function() return { fg = u.getHighlightValue("Boolean", "fg") } end,
				},
				"before"
			)
		end,
	},
}
