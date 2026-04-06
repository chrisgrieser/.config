vim.pack.add { "https://github.com/lewis6991/gitsigns.nvim" }
--------------------------------------------------------------------------------

require("gitsigns").setup {
	signs_staged_enable = true,
	attach_to_untracked = true,
	-- stylua: ignore
	count_chars = { "", "󰬻", "󰬼", "󰬽", "󰬾", "󰬿", "󰭀", "󰭁", "󰭂", ["+"] = "󰿮" },
	signs = {
		delete = { show_count = true },
		topdelete = { show_count = true },
		changedelete = { show_count = true },
	},
	current_line_blame_formatter = "<summary> (<author_time:%R>, <author>))",
	current_line_blame_formatter_nc = "+++ uncommitted",
	current_line_blame_opts = { delay = 500 },
}

-- Using gitsigns's data since lualine's builtin component is updated less
-- frequently and thus often out of sync with gitsigns in the signcolumn.
vim.g.lualineAdd("sections", "lualine_y", {
	"diff",
	source = function()
		local gs = vim.b.gitsigns_status_dict
		if not gs then return end
		return { added = gs.added, modified = gs.changed, removed = gs.removed }
	end,
	fmt = function(str) return vim.b.gitsignsPrevChanges and "󰑟 " .. str or str end,
}, "before")

--------------------------------------------------------------------------------

Keymap { "ga", "<cmd>Gitsigns stage_hunk<CR>", desc = "󰊢 (Un-)Stage hunk" }
-- stylua: ignore
Keymap { "ga", ":Gitsigns stage_hunk<CR>", mode = "x", silent = true, desc = "󰊢 Un/stage selection" }
Keymap { "gA", "<cmd>Gitsigns stage_buffer<CR>", desc = "󰊢 Stage file" }
Keymap { "gh", "<cmd>Gitsigns select_hunk<CR>", mode = { "o", "x" }, desc = "󰊢 Hunk textobj" }

Keymap {
	"gh",
	function()
		if vim.wo.diff then return vim.cmd.normal { "]c", bang = true } end
		require("gitsigns").nav_hunk("next", { foldopen = true, navigation_message = true })
	end,
	desc = "󰊢 Next hunk",
}
Keymap {
	"gH",
	function()
		if vim.wo.diff then return vim.cmd.normal { "[c", bang = true } end
		require("gitsigns").nav_hunk("prev", { foldopen = true, navigation_message = true })
	end,
	desc = "󰊢 Previous hunk",
}
Keymap {
	"<leader>op",
	function()
		if vim.b.gitsignsPrevChanges then
			require("gitsigns").reset_base()
		else
			local filepath = vim.api.nvim_buf_get_name(0)
			local gitArgs = { "git", "log", "--max-count=1", "--format=%h", "--", filepath }
			local out = vim.system(gitArgs):wait()
			local lastCommitToFile = vim.trim(out.stdout) .. "^"
			require("gitsigns").change_base(lastCommitToFile)
		end
		vim.b.gitsignsPrevChanges = not vim.b.gitsignsPrevChanges
	end,
	desc = "󰊢 Prev/present hunks",
}

-- UNDO
Keymap { "<leader>ua", "<cmd>Gitsigns undo_stage_hunk<CR>", desc = "󰊢 Undo last stage" }
Keymap { "<leader>uA", "<cmd>Gitsigns reset_buffer_index<CR>", desc = "󰊢 Unstage file" }
-- stylua: ignore
Keymap { "<leader>uh", "<cmd>Gitsigns reset_hunk<CR>", mode = { "n", "x" }, desc = "󰊢 Reset hunk" }
Keymap { "<leader>uf", "<cmd>Gitsigns reset_buffer<CR>", desc = "󰊢 Reset file" }
-- stylua: ignore
Keymap { "<leader>o?", function() require("gitsigns").toggle_current_line_blame() end, desc = "󰆽 Line blame" }
-- stylua: ignore
Keymap { "<leader>gv", function() require("gitsigns").preview_hunk_inline() end, desc = " Preview hunk inline" }
Keymap {
	"<leader>ov",
	function()
		require("gitsigns").toggle_linehl()
		require("gitsigns").toggle_word_diff()
		require("gitsigns").toggle_deleted()
	end,
	desc = " Inline diff view",
}
