return {
	{ -- smart commit & amend actions
		"chrisgrieser/nvim-tinygit",
		dependencies = "stevearc/dressing.nvim",
		keys = {
			{ "<leader>gp", function() require("tinygit").push() end, desc = "󰊢 Push" },
			{ "<leader>gU", function() require("tinygit").githubUrl("repo") end, desc = " Goto Repo" },
			{
				"<leader>ga",
				function() require("tinygit").stageHunkWithInfo() end,
				desc = "󰊢 Stage Hunk",
			},
			{
				"<leader>gc",
				function() require("tinygit").smartCommit { openReferencedIssue = true } end,
				desc = "󰊢 Smart-Commit",
			},
			{
				"<leader>gg",
				function() require("tinygit").smartCommit { push = true, openReferencedIssue = true } end,
				desc = "󰊢 Smart-Commit & Push",
			},
			{
				"<leader>gm",
				function() require("tinygit").amendNoEdit { forcePush = true } end,
				desc = "󰊢 Amend-No-Edit & Push",
			},
			{
				"<leader>gM",
				function() require("tinygit").amendOnlyMsg { forcePush = true } end,
				desc = "󰊢 Amend Only Msg & Push",
			},
			{
				"<leader>gi",
				function() require("tinygit").issuesAndPrs { state = "open", type = "issue" } end,
				desc = " Open Issues",
			},
			{
				"<leader>gI",
				function() require("tinygit").issuesAndPrs { state = "closed" } end,
				desc = " Closed Issues",
			},
			{
				"<leader>gu",
				function() require("tinygit").githubUrl() end,
				mode = { "n", "x" },
				desc = " GitHub Link",
			},
		},
	},
	{ -- git sign gutter & hunk actions
		"lewis6991/gitsigns.nvim",
		event = "VeryLazy",
		keys = {
			-- { "<leader>ga", "<cmd>Gitsigns stage_hunk<CR>", desc = "󰊢 Add Hunk" },
			{ "<leader>gy", "<cmd>Gitsigns undo_stage_hunk<CR>", desc = "󰊢 Unstage Last Hunk" },
			{ "<leader>gA", "<cmd>Gitsigns stage_buffer<CR>", desc = "󰊢 Add Buffer" },
			{ "<leader>gv", "<cmd>Gitsigns preview_hunk<CR>", desc = "󰊢 Preview Hunk Diff" },
			{ "<leader>uh", "<cmd>Gitsigns reset_hunk<CR>", desc = "󰊢 Reset Hunk" },
			{ "<leader>ub", "<cmd>Gitsigns reset_buffer<CR>", desc = "󰊢 Reset Buffer" },
			{ "gh", "<cmd>Gitsigns select_hunk<CR>", mode = { "o", "x" }, desc = "󱡔 󰊢 hunk textobj" },
			{
				"gh",
				function() require("gitsigns").next_hunk { foldopen = true } end,
				desc = "󰊢 Next Hunk",
			},
			{
				"gH",
				function() require("gitsigns").next_hunk { foldopen = true } end,
				desc = "󰊢 Previous Hunk",
			},
			{
				"<leader>g?",
				function() require("gitsigns").blame_line { full = true } end,
				desc = "󰊢 Blame Line",
			},
		},
		opts = {
			max_file_length = 12000, -- lines
			preview_config = { border = require("config.utils").borderStyle },
		},
	},
	{ -- diff / merge / file history
		"sindrets/diffview.nvim",
		dependencies = "nvim-lua/plenary.nvim",
		cmd = { "DiffviewOpen", "DiffviewFileHistory" },
		keys = {
			{
				"<leader>gd",
				function()
					vim.ui.input({ prompt = "󰢷 Git Pickaxe (empty = full history)" }, function(pickaxe)
						if not pickaxe then return end

						local query = pickaxe ~= "" and (" -G'%s'"):format(pickaxe) or ""
						vim.cmd("DiffviewFileHistory %" .. query)
						vim.cmd.wincmd("w") -- go directly to file window
						vim.cmd.wincmd("|") -- maximize it

						-- directly search for the term
						if pickaxe ~= "" then vim.fn.execute("/" .. pickaxe, "silent!") end
					end)
				end,
				desc = "󰊢 Pickaxe File History",
			},
			{
				"<leader>gd",
				":DiffviewFileHistory<CR><C-w>w<C-w>|", -- requires `:` for '<'> marks
				mode = "x",
				desc = "󰊢 Line History (Diffview)",
			},
		},
		config = function() -- needs config, for access to diffview.actions in mappings
			require("diffview").setup {
				-- https://github.com/sindrets/diffview.nvim#configuration
				enhanced_diff_hl = false, -- true = no red for deletes
				show_help_hints = false,
				file_history_panel = {
					win_config = { height = 5 },
				},
				hooks = {
					diff_buf_read = function()
						-- set buffername, mostly for tabline (lualine)
						pcall(function() vim.api.nvim_buf_set_name(0, "Diffview") end)
					end,
				},
				keymaps = {
					view = {
						{ "n", "<D-w>", vim.cmd.tabclose, {} }, -- close tab instead of window
						{ "n", "<S-CR>", function() vim.cmd.wincmd("w") end, {} }, -- consistent with general buffer switcher
					},
					file_history_panel = {
						{ "n", "<D-w>", vim.cmd.tabclose, {} },
						{ "n", "?", require("diffview.actions").help("file_history_panel"), {} },
						{ "n", "<S-CR>", function() vim.cmd.wincmd("w") end, {} },
					},
				},
			}
		end,
	},
}
