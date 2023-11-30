return {
	{ -- lightweight git client
		"chrisgrieser/nvim-tinygit",
		dependencies = "stevearc/dressing.nvim",
		ft = "gitrebase", -- so ftplugin is loaded
		keys = {
			-- stylua: ignore start
			{ "gc", function() require("tinygit").smartCommit { pushIfClean = true } end, desc = "󰊢 Smart-Commit & Push" },
			{ "gC", function() require("tinygit").smartCommit { pushIfClean = false } end, desc = "󰊢 Smart-Commit" },
			{ "<leader>gp", function() require("tinygit").push { createGitHubPr = true } end, desc = " Push & PR" },
			{ "<leader>gf", function() require("tinygit").fixupCommit({ autoRebase = true }) end, desc = "󰊢 Fixup & Rebase" },
			{ "<leader>gm", function() require("tinygit").amendNoEdit { forcePush = true } end, desc = "󰊢 Amend-No-Edit & F-Push" },
			{ "<leader>gM", function() require("tinygit").amendOnlyMsg { forcePush = true } end, desc = "󰊢 Amend Only Msg & F-Push" },
			{ "<leader>gi", function() require("tinygit").issuesAndPrs { state = "open" } end, desc = " Open Issues" },
			{ "<leader>gI", function() require("tinygit").issuesAndPrs { state = "closed" } end, desc = " Closed Issues" },
			{ "<leader>gd", function() require("tinygit").searchFileHistory() end, desc = "󰢷 File History" },
			{ "<leader>gD", function() require("tinygit").functionHistory() end, desc = "󰢷 Function History" },
			{ "<leader>gu", function() require("tinygit").githubUrl() end, mode = { "n", "x" }, desc = " GitHub Link" },
			{ "<leader>gU", function() require("tinygit").githubUrl("repo") end, desc = " Goto Repo" },
			{ "<leader>g#", function() require("tinygit").openIssueUnderCursor() end, desc = " Open Issue under Cursor" },
		},
		opts = {
			commitMsg = {
				conventionalCommits = { enforce = true },
				emptyFillIn = false,
				spellcheck = true,
				openReferencedIssue = true,
			},
			historySearch = {
				diffPopup = {
					width = 0.9,
					height = 0.9,
					border = require("config.utils").borderStyle,
				},
				autoUnshallowIfNeeded = true,
			},
		},
	},
	{ -- git sign gutter & hunk actions
		"lewis6991/gitsigns.nvim",
		event = "VeryLazy",
		keys = {
			{ "ga", "<cmd>Gitsigns stage_hunk<CR>", desc = "󰊢 Stage Hunk" },
			{
				"ga",
				":Gitsigns stage_hunk<CR>",
				mode = "x",
				silent = true,
				desc = "󰊢 Stage Selection",
			},
			{ "<leader>ga", "<cmd>Gitsigns stage_buffer<CR>", desc = "󰊢 Add Buffer" },
			{ "<leader>gv", "<cmd>Gitsigns preview_hunk<CR>", desc = "󰊢 Preview Hunk" },
			{ "<leader>ua", "<cmd>Gitsigns undo_stage_hunk<CR>", desc = "󰊢 Unstage Last Stage" },
			{ "<leader>uh", "<cmd>Gitsigns reset_hunk<CR>", desc = "󰊢 Reset Hunk" },
			{ "<leader>ub", "<cmd>Gitsigns reset_buffer<CR>", desc = "󰊢 Reset Buffer" },
			-- stylua: ignore start
			{ "<leader>g?", function() require("gitsigns").blame_line { full = true } end, desc = "󰊢 Blame Line"},
			{ "gh", function() require("gitsigns").next_hunk { foldopen = true } end, desc = "󰊢 Next Hunk" },
			{ "gH", function() require("gitsigns").prev_hunk { foldopen = true } end, desc = "󰊢 Previous Hunk" },
			{ "gh", "<cmd>Gitsigns select_hunk<CR>", mode = { "o", "x" }, desc = "󱡔 󰊢 Hunk textobj" },
			-- stylua: ignore end
		},
		opts = {
			max_file_length = 12000, -- lines
			preview_config = { border = require("config.utils").borderStyle },
			-- deletions greater than one line will show a count to assess the size
			-- digits are actually nerdfont numbers to achieve smaller size
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
