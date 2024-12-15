return {
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

		current_line_blame_formatter = "<author> (<author_time:%R>): <summary>",
		current_line_blame_formatter_nc = "+++ uncommitted",
		current_line_blame_opts = {
			virt_text = true, -- can be disabled, and the blame shown via "vim.b.gitsigns_blame_line"
			delay = 500,
		},
	},
	keys = {
		-- stylua: ignore start
		{ "<leader>ga", "<cmd>Gitsigns stage_hunk<CR>", desc = "󰊢 Stage hunk" },
		{ "<leader>ga", ":Gitsigns stage_hunk<CR>", mode = "x", silent = true, desc = "󰊢 Stage selection" },
		{ "<leader>gA", "<cmd>Gitsigns stage_buffer<CR>", desc = "󰊢 Stage file" },

		{ "gh", function() require("gitsigns").nav_hunk("next", { foldopen = true, navigation_message = true }) end, desc = "󰊢 Next hunk" },
		{ "gH", function() require("gitsigns").nav_hunk("prev", { foldopen = true, navigation_message = true }) end, desc = "󰊢 Previous hunk" },
		{ "gh", "<cmd>Gitsigns select_hunk<CR>", mode = { "o", "x" }, desc = "󰊢 Hunk textobj" },

		-- UNDO
		{ "<leader>ua", "<cmd>Gitsigns undo_stage_hunk<CR>", desc = "󰍵 Unstage last stage" },
		{ "<leader>uA", "<cmd>Gitsigns reset_buffer_index<CR>", desc = "󰍵 Unstage file" },
		{ "<leader>uh", "<cmd>Gitsigns reset_hunk<CR>", mode = { "n", "x" }, desc = "󰊢 Reset hunk" },
		{ "<leader>uf", "<cmd>Gitsigns reset_buffer<CR>", desc = "󰊢 Reset file" },
		-- stylua: ignore end
		{
			"<leader>o?",
			function() require("gitsigns").toggle_current_line_blame() end,
			desc = "󰆽 Line blame",
		},
		{
			"<leader>oi",
			function()
				require("gitsigns").toggle_deleted()
				require("gitsigns").toggle_word_diff()
				require("gitsigns").toggle_linehl()
			end,
			desc = "󰊢 Inline diff",
		},
		{
			"<leader>op",
			function()
				local notifyOpts = { title = "Gitsigns", icon = "󰊢" }
				if vim.b.gitsignsPrevChanges then
					require("gitsigns").reset_base()
					vim.notify("Base was reset.", nil, notifyOpts)
					vim.b.gitsignsPrevChanges = false
					return
				end

				local filepath = vim.api.nvim_buf_get_name(0)
				local gitArgs = { "git", "log", "--max-count=1", "--format=%h", "--", filepath }
				local out = vim.system(gitArgs):wait()
				local lastCommitToFile = vim.trim(out.stdout) .. "^"
				require("gitsigns").change_base(lastCommitToFile)
				vim.b.gitsignsPrevChanges = true
				vim.notify("Changed base to " .. lastCommitToFile, nil, notifyOpts)
			end,
			desc = "󰊢 Prev/present hunks",
		},
	},
	config = function(_, opts)
		require("gitsigns").setup(opts)

		-- STATUSLINE CHANGE COUNT
		-- INFO Using gitsigns.nvim's data since lualine's builtin component
		-- is updated much less frequently and is thus often out of sync
		-- with the gitsigns in the signcolumn.
		vim.g.lualineAdd("sections", "lualine_y", {
			"diff",
			source = function()
				local gs = vim.b.gitsigns_status_dict
				if not gs then return end
				return { added = gs.added, modified = gs.changed, removed = gs.removed }
			end,
		}, "before")

		-- STATUSLINE SIGN BASE
		vim.g.lualineAdd("sections", "lualine_y", {
			function() return "" end,
			cond = function() return vim.b.gitsignsPrevChanges end,
		}, "before")
	end,
}
