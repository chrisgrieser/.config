return {
	{ -- lightweight git client
		"chrisgrieser/nvim-tinygit",
		dependencies = "stevearc/dressing.nvim",
		keys = {
			-- stylua: ignore start
			{ "gc", function() require("tinygit").smartCommit { pushIfClean = true } end, desc = "󰊢 Smart-Commit & Push" },
			{ "<leader>gm", function() require("tinygit").amendNoEdit { forcePush = true } end, desc = "󰊢 Amend-No-Edit & Push" },
			{ "<leader>gM", function() require("tinygit").amendOnlyMsg { forcePush = true } end, desc = "󰊢 Amend Only Msg & Push" },
			{ "<leader>gi", function() require("tinygit").issuesAndPrs { state = "open" } end, desc = " Open Issues" },
			{ "<leader>gI", function() require("tinygit").issuesAndPrs { state = "closed" } end, desc = " Closed Issues" },
			{ "<leader>gu", function() require("tinygit").githubUrl() end, mode = { "n", "x" }, desc = " GitHub Link" },
			{ "<leader>gU", function() require("tinygit").githubUrl("repo") end, desc = " Goto Repo" },
			{ "<leader>gd", function() require("tinygit").searchFileHistory() end, desc = "󰢷 File History" },
			{ "<leader>g#", function() require("tinygit").openIssueUnderCursor() end, desc = " Open Issue under Cursor" },
			-- stylua: ignore end
		},
		opts = {
			commitMsg = {
				enforceConvCommits = { enabled = true },
				spellcheck = true,
				openReferencedIssue = true,
			},
			searchFileHistory = {
				diffPopupBorder = require("config.utils").borderStyle,
			},
		},
	},
	{ -- git sign gutter & hunk actions
		"lewis6991/gitsigns.nvim",
		event = "VeryLazy",
		keys = {
			{
				"ga",
				":Gitsigns stage_hunk<CR>",
				mode = { "n", "x" },
				desc = "󰊢 Stage Selected Hunks",
				silent = true,
			},
			{ "<leader>gy", "<cmd>Gitsigns undo_stage_hunk<CR>", desc = "󰊢 Unstage Last Hunk" },
			{ "<leader>gA", "<cmd>Gitsigns stage_buffer<CR>", desc = "󰊢 Add Buffer" },
			{ "<leader>gv", "<cmd>Gitsigns preview_hunk_inline<CR>", desc = "󰊢 Preview Hunk" },
			{ "<leader>ub", "<cmd>Gitsigns reset_buffer<CR>", desc = "󰊢 Reset Buffer" },
			-- stylua: ignore start
			{ "<leader>g?", function() require("gitsigns").blame_line { full = true } end, desc = "󰊢 Blame Line"},
			{ "gh", function() require("gitsigns").next_hunk { foldopen = true } end, desc = "󰊢 Next Hunk" },
			{ "gH", function() require("gitsigns").prev_hunk { foldopen = true } end, desc = "󰊢 Previous Hunk" },
			{ "gh", "<cmd>Gitsigns select_hunk<CR>", mode = { "o", "x" }, desc = "󱡔 󰊢 hunk textobj" },
			-- stylua: ignore end
		},
		opts = {
			max_file_length = 12000, -- lines
			preview_config = { border = require("config.utils").borderStyle },
			signs = {
				delete = { show_count = true },
				topdelete = { show_count = true },
				changedelete = { show_count = true },
			},
		},
	},
}
