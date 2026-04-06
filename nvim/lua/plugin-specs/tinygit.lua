vim.pack.add { "https://github.com/chrisgrieser/nvim-tinygit" }
--------------------------------------------------------------------------------

-- stylua: ignore start
Keymap { "<leader>gg", function() require("tinygit").smartCommit { pushIfClean = true } end, desc = "󰊢 Smart-commit & push", nowait = true }
Keymap { "<leader>gc", function() require("tinygit").smartCommit { pushIfClean = false } end, desc = "󰊢 Smart-commit" }
Keymap { "<leader>gp", function() require("tinygit").push { pullBefore = true } end, desc = "󰊢 Pull & push" }
Keymap { "<leader>gf", function() require("tinygit").fixupCommit { autoRebase = true } end, desc = "󰊢 Fixup-commit & rebase" }
Keymap { "<leader>gm", function() require("tinygit").amendNoEdit { forcePushIfDiverged = true } end, desc = "󰊢 Amend-commit & f-push" }
Keymap { "<leader>gM", function() require("tinygit").amendOnlyMsg { forcePushIfDiverged = true } end, desc = "󰊢 Amend message & f-push" }
Keymap { "<leader>gh", function() require("tinygit").fileHistory() end, mode = { "n", "x" }, desc = "󰋚 File history" }
Keymap { "<leader>gu", function() require("tinygit").githubUrl("file") end, desc = " GitHub file URL" }
Keymap { "<leader>gu", function() require("tinygit").githubUrl("file") end, mode = "x", desc = " GitHub line URL" }
Keymap { "<leader>gU", function() require("tinygit").githubUrl("repo") end, mode = { "n", "x" }, desc = " GitHub repo URL" }
Keymap { "<leader>g?", function() require("tinygit").githubUrl("blame") end, mode = { "n", "x" }, desc = " GitHub blame" }
Keymap { "<leader>gt", function() require("tinygit").stashPush() end, desc = "󰜦 Stash" }
Keymap { "<leader>gT", function() require("tinygit").stashPop() end, desc = "󰜦 Stash pop" }

Keymap { "gi", function() require("tinygit").openIssueUnderCursor() end, desc = " Open issue under cursor" }

Keymap { "<leader>uc", function() require("tinygit").undoLastCommitOrAmend() end, desc = "󰊢 Undo last commit/amend" }
-- stylua: ignore end

--------------------------------------------------------------------------------

require("tinygit").setup {
	commit = {
		keepAbortedMsgSecs = 60 * 10, -- 10 mins
		spellcheck = true,
		preview = { loglines = 4 },
		keymapHints = false,
		subject = {
			autoFormat = function(subject)
				-- remove trailing `.` & lowercase title
				return subject:gsub("%.$", ""):gsub(": %u", string.lower)
			end,
			enforceType = true,
		},
	},
	push = {
		openReferencedIssues = true,
	},
	history = {
		autoUnshallowIfNeeded = true,
		diffPopup = { width = 0.9, height = 0.9 },
	},
	statusline = {
		blame = {
			hideAuthorNames = { "Chris Grieser", "chrisgrieser" },
			showOnlyTimeIfAuthor = { "🤖 automated" },
			maxMsgLen = 72,
		},
		fileState = { icon = "" },
	},
	config = function(_, opts) require("tinygit").setup(opts) end,
}

--------------------------------------------------------------------------------

vim.g.lualineAdd("tabline", "lualine_x", require("tinygit.statusline").blame)
vim.g.lualineAdd("sections", "lualine_y", require("tinygit.statusline").fileState)
vim.g.lualineAdd("sections", "lualine_y", require("tinygit.statusline").branchState)
