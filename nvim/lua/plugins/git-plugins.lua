return {
	{ -- lightweight git client
		"chrisgrieser/nvim-tinygit",
		dependencies = "stevearc/dressing.nvim",
		keys = {
			-- stylua: ignore start
			{ "<leader>gp", function() require("tinygit").push() end, desc = "󰊢 Push" },
			{ "<leader>gc", function() require("tinygit").smartCommit { openReferencedIssue = true } end, desc = "󰊢 Smart-Commit" },
			{ "<leader>gg", function() require("tinygit").smartCommit { push = true, openReferencedIssue = true } end, desc = "󰊢 Smart-Commit & Push" },
			{ "<leader>gm", function() require("tinygit").amendNoEdit { forcePush = true } end, desc = "󰊢 Amend-No-Edit & Push" },
			{ "<leader>gM", function() require("tinygit").amendOnlyMsg { forcePush = true } end, desc = "󰊢 Amend Only Msg & Push" },
			{ "<leader>gi", function() require("tinygit").issuesAndPrs { state = "open" } end, desc = " Open Issues" },
			{ "<leader>gI", function() require("tinygit").issuesAndPrs { state = "closed" } end, desc = " Closed Issues" },
			{ "<leader>gu", function() require("tinygit").githubUrl() end, mode = { "n", "x" }, desc = " GitHub Link" },
			{ "<leader>gU", function() require("tinygit").githubUrl("repo") end, desc = " Goto Repo" },
			{ "<leader>gd", function() require("tinygit").searchFileHistory() end, desc = "󰢷 File History" },
			---@diagnostic disable-next-line: deprecated
			{ "<leader>ga", function() require("tinygit.staging").stageHunkWithInfo() end, desc = "󰊢 Stage Hunk" },
			-- stylua: ignore end
		},
	},
	{ -- git sign gutter & hunk actions
		"lewis6991/gitsigns.nvim",
		event = "VeryLazy",
		keys = {
			{ "<leader>ga", ":Gitsigns stage_hunk<CR>", mode = "x", desc = "󰊢 Stage Selected Hunks" },
			{ "<leader>gy", "<cmd>Gitsigns undo_stage_hunk<CR>", desc = "󰊢 Unstage Last Hunk" },
			{ "<leader>gA", "<cmd>Gitsigns stage_buffer<CR>", desc = "󰊢 Add Buffer" },
			{ "<leader>gv", "<cmd>Gitsigns preview_hunk<CR>", desc = "󰊢 Preview Hunk Diff" },
			{ "<leader>uh", "<cmd>Gitsigns reset_hunk<CR>", desc = "󰊢 Reset Hunk" },
			{ "<leader>ub", "<cmd>Gitsigns reset_buffer<CR>", desc = "󰊢 Reset Buffer" },
			-- stylua: ignore start
			{ "<leader>g?", function() require("gitsigns").blame_line { full = true } end, desc = "󰊢 Blame Line"},
			{ "gh", function() require("gitsigns").next_hunk { foldopen = true } end, desc = "󰊢 Next Hunk" },
			{ "gH", function() require("gitsigns").prev_hunk { foldopen = true } end, desc = "󰊢 Previous Hunk" },
			-- stylua: ignore end
			{
				"gh",
				"<cmd>Gitsigns select_hunk<CR>",
				mode = { "o", "x" },
				desc = "󱡔 󰊢 hunk textobj",
			},
			{
				"<leader>gq",
				function()
					require("gitsigns").setqflist("all", { open = false })
					vim.defer_fn(vim.cmd.cfirst, 100) -- PENDING https://github.com/lewis6991/gitsigns.nvim/issues/906
				end,
				desc = " Hunks to Quickfix",
			},
		},
		opts = {
			max_file_length = 12000, -- lines
			preview_config = { border = require("config.utils").borderStyle },
		},
	},
}
