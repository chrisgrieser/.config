local u = require("config.utils")

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
			{ "<leader>g<D-d>", function() require("tinygit").lineHistory() end, mode = { "n", "x" }, desc = "󰢷 Line History" },
			{ "<leader>gu", function() require("tinygit").githubUrl() end, mode = { "n", "x" }, desc = " GitHub URL" },
			{ "<leader>gU", function() require("tinygit").githubUrl("repo") end, mode = { "n", "x" }, desc = " GitHub Repo URL" },
			{ "<leader>uc", function() require("tinygit").undoLastCommitOrAmend() end, desc = "󰊢 Undo Last Commit/Amend" },
			{ "g#", function() require("tinygit").openIssueUnderCursor() end, desc = " Open Issue under Cursor" },
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
			-- stylua: ignore start
			{ "ga", "<cmd>Gitsigns stage_hunk<CR>", desc = "󰊢 Stage Hunk" },
			{ "ga", ":Gitsigns stage_hunk<CR>", mode = "x", silent = true, desc = "󰊢 Stage Selection" },
			{ "gA", "<cmd>Gitsigns stage_buffer<CR>", desc = "󰊢 Add Buffer" },
			{ "gh", "<cmd>Gitsigns nav_hunk('next')<CR>", desc = "󰊢 Next Hunk" },
			{ "gH", "<cmd>Gitsigns nav_hunk('prev')<CR>", desc = "󰊢 Previous Hunk" },
			{ "gh", "<cmd>Gitsigns select_hunk<CR>", mode = { "o", "x" }, desc = "󱡔 󰊢 Hunk textobj" },
			{ "<leader>g?", function() require("gitsigns").blame_line { full = true } end, desc = " Blame Line" },

			-- UNDO
			{ "<leader>ua", "<cmd>Gitsigns undo_stage_hunk<CR>", desc = "󰊢 Unstage Last Stage" },
			{ "<leader>uA", "<cmd>Gitsigns reset_buffer_index<CR>", desc = "󰊢 Unstage Buffer" },
			{ "<leader>ub", "<cmd>Gitsigns reset_buffer<CR>", desc = "󰊢 Reset Buffer" },
			{ "<leader>uh", "<cmd>Gitsigns reset_hunk<CR>", mode = { "n", "x" }, desc = "󰊢 Reset Hunk" },

			-- OPTIONS
			{ "<leader>oi", "<cmd>Gitsigns toggle_deleted<CR>", desc = "󰊢 Inline Deletions" },
			{ "<leader>o?", "<cmd>Gitsigns toggle_current_line_blame<CR>", desc = " Git Blame" },
			-- stylua: ignore end
			{
				"<leader>op",
				function()
					if vim.b.gitsigns_previous_changes then
						require("gitsigns").reset_base()
						u.notify("Gitsigns", "Reset Base")
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
					u.notify("Gitsigns", "Changed base to " .. lastCommitToFile)
				end,
				desc = "󰊢 Previous/Present Changes",
			},
		},
		opts = {
			attach_to_untracked = true,
			max_file_length = 3000, -- lines
			-- deletions greater than one line will show a count to assess the size
			-- (digits are actually nerdfont numbers to achieve smaller size)
			-- stylua: ignore
			count_chars = { "", "󰬻", "󰬼", "󰬽", "󰬾", "󰬿", "󰭀", "󰭁", "󰭂", ["+"] = "󰿮" },
			signs_staged_enable = false, -- TODO buggy, try enabling later
			signs = {
				delete = { show_count = true },
				topdelete = { show_count = true },
				changedelete = { show_count = true },
			},
		},
		config = function(_, opts)
			require("gitsigns").setup(opts)

			local components = {
				{
					func = function() return "" end,
					cond = function() return vim.b.gitsigns_previous_changes end,
					fgColor = "Boolean",
				},
				{
					func = function() return "+" .. vim.b.gitsigns_status_dict.added end,
					cond = function() return vim.b.gitsigns_status_dict.added > 0 end,
					fgColor = "GitSignsAdd",
				},
				{
					func = function() return "~" .. vim.b.gitsigns_status_dict.changed end,
					cond = function() return vim.b.gitsigns_status_dict.changed > 0 end,
					fgColor = "GitSignsChange",
				},
				{
					func = function() return "~" .. vim.b.gitsigns_status_dict.table.removed end,
					cond = function() return vim.b.gitsigns_status_dict.table.removed > 0 end,
					fgColor = "GitSignsDelete",
				},
			}
			-- because we are inserting the items w/ `before` at the start of the section
			components = vim.fn.reverse(components)

			for _, component in ipairs(components) do
				local color = u.getHighlightValue(component.fgColor, "fg")
				u.addToLuaLine(
					"sections",
					"lualine_y", -- same section as diff count
					{
						component.func,
						color = { fg = color },
						cond = component.cond,
						padding = { left = 1, right = 0 },
					},
					"before"
				)
			end
		end,
	},
}
