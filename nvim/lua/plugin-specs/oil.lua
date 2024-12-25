return {
	"stevearc/oil.nvim",
	dependencies = "echasnovski/mini.icons",

	keys = {
		{ "<leader>fo", "<cmd>Oil --float<CR>", desc = "󰁴 Oil" },
	},

	---@module "oil"
	---@type oil.SetupOpts
	opts = {
		delete_to_trash = true,
		skip_confirm_for_simple_edits = false,
		use_default_keymaps = false,
		keymaps = {
			["?"] = { "actions.show_help", mode = "n" },
			["q"] = { "actions.close", mode = "n", nowait = true },
			["gs"] = { "actions.change_sort", mode = "n" },
			["C"] = { "actions.cd", mode = "n" },
			["<CR>"] = "actions.select",
			["<Tab>"] = { "actions.parent" },
			["<D-r>"] = { "actions.refresh" },
			["<D-p>"] = { "actions.preview" },
			["<D-s>"] = {
				function()
					require("oil").save()
					require("oil").close()
				end,
				desc = "Save & close",
			},
		},
		columns = { "icon" }, -- mtime,size
		win_options = {
			statuscolumn = " ", -- adds paddings
		},
		confirmation = {
			border = vim.g.borderStyle,
		},
		float = {
			border = vim.g.borderStyle,
			override = function(conf)
				local height = 0.85
				local width = 0.6
				conf.row = math.floor((1 - height) / 2 * vim.o.lines)
				conf.col = math.floor((1 - width) / 2 * vim.o.columns)
				conf.height = math.floor(vim.o.lines * height)
				conf.width = math.floor(vim.o.columns * width)
				return conf
			end,
			preview_split = "below",

			-- FIX display relative path of directory, not absolute one
			get_win_title = function(winid)
				local bufnr = vim.api.nvim_win_get_buf(winid)
				local absPath = vim.api.nvim_buf_get_name(bufnr):gsub("^oil://", "")
				local cwd = vim.uv.cwd() or ""
				local relPath = "." .. absPath:sub(#cwd + 1)
				local title = vim.startswith(absPath, cwd) and relPath or absPath:gsub(vim.env.HOME, "~")
				return " " .. title .. " "
			end,
		},
	},
}
