return {
	"chrisgrieser/nvim-tinygit",
	event = "VeryLazy", -- load for status line component
	keys = {
			-- stylua: ignore start
			{ "<leader>gg", function() require("tinygit").smartCommit { pushIfClean = true } end, desc = "󰊢 Smart-commit & push", nowait = true },
			{ "<leader>gc", function() require("tinygit").smartCommit { pushIfClean = false } end, desc = "󰊢 Smart-commit" },
			{ "<leader>gn", function() require("tinygit").interactiveStaging() end, desc = "󰊢 Interactive staging" },
			{ "<leader>gp", function() require("tinygit").push { pullBefore = true } end, desc = "󰊢 Pull & push" },
			{ "<leader>gP", function() require("tinygit").createGitHubPr() end, desc = " Create PR" },
			{ "<leader>gf", function() require("tinygit").fixupCommit { autoRebase = true } end, desc = "󰊢 Fixup-commit & rebase" },
			{ "<leader>gm", function() require("tinygit").amendNoEdit { forcePushIfDiverged = true } end, desc = "󰊢 Amend-commit & f-push" },
			{ "<leader>gM", function() require("tinygit").amendOnlyMsg { forcePushIfDiverged = true } end, desc = "󰊢 Amend message & f-push" },
			{ "<leader>gi", function() require("tinygit").issuesAndPrs { state = "open" } end, desc = " Open issues" },
			{ "<leader>gI", function() require("tinygit").issuesAndPrs { state = "closed" } end, desc = " Closed issues" },
			{ "<leader>gh", function() require("tinygit").fileHistory() end, mode = { "n", "x" }, desc = "󰋚 File history" },
			{ "<leader>gu", function() require("tinygit").githubUrl("file") end, mode = { "n", "x" }, desc = " GitHub line URL" },
			{ "<leader>gU", function() require("tinygit").githubUrl("repo") end, mode = { "n", "x" }, desc = " GitHub repo URL" },
			{ "<leader>g!", function() require("tinygit").githubUrl("blame") end, mode = { "n", "x" }, desc = "󰆽 GitHub blame" },
			{ "<leader>gt", function() require("tinygit").stashPush() end, desc = "󰜦 Stash" },
			{ "<leader>gT", function() require("tinygit").stashPop() end, desc = "󰜦 Stash pop" },

			{ "gi", function() require("tinygit").openIssueUnderCursor() end, desc = " Open issue under cursor" },

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
}
