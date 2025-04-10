-- DOCS https://github.com/folke/snacks.nvim#-features
--------------------------------------------------------------------------------
---@module "snacks"
--------------------------------------------------------------------------------

return {
	"folke/snacks.nvim",

	-- for quickfile and bigfile
	priority = 1000,
	lazy = false,

	config = function(_, opts)
		require("snacks").setup(opts)

		-- ignore certain notifications
		---@diagnostic disable-next-line: duplicate-set-field intentional overwrite
		vim.notify = function(msg, ...)
			local ignore = msg == "No code actions available"
				or msg:find("^Client marksman quit with exit code 1 and signal 0.")
			if ignore then return end
			Snacks.notifier(msg, ...)
		end

		-- disable default keymaps to make the `?` help overview less cluttered
		require("snacks.picker.config.defaults").defaults.win.input.keys = {}
	end,

	keys = {
		{ "ö", function() Snacks.words.jump(1, true) end, desc = "󰗲 Next reference" },
		{ "Ö", function() Snacks.words.jump(-1, true) end, desc = "󰗲 Prev reference" },
		{ "<leader>g?", function() Snacks.git.blame_line() end, desc = "󰆽 Blame line" },
		{
			"<leader>ee",
			function()
				-- `win.ft = lua` requires Snacks.nvim
				vim.ui.input({ prompt = " Eval: ", win = { ft = "lua" } }, function(expr)
					if not expr then return end
					local result = vim.inspect(vim.fn.luaeval(expr))
					local opts = { title = "Eval", icon = "", ft = "lua" }
					vim.notify(result, vim.log.levels.DEBUG, opts)
				end)
			end,
			desc = " Eval",
		},
	},
	---@type snacks.Config
	opts = {
		bigfile = {
			notify = true,
			size = 1024 * 1024, -- 1.0MB
			line_length = math.huge, -- disable, since buggy with Alfred's `info.plist`
		},
		quickfile = {
			enabled = true,
		},
		words = {
			notify_jump = true,
			modes = { "n" },
			debounce = 300,
		},
		input = {
			icon = "",
			win = {
				relative = "editor",
				backdrop = 60,
				border = vim.o.winborder --[[@as "rounded"|"single"|"double"|"solid"]],
				title_pos = "left",
				width = 50,
				row = math.ceil(vim.o.lines / 2) - 3,
			},
		},
		indent = {
			char = "│",
			scope = { hl = "Comment" },
			chunk = {
				enabled = false,
				hl = "Comment",
			},
			animate = {
				-- slower for more dramatic effect :D
				duration = { steps = 200, total = 1000 },
			},
		},
		blame_line = {
			win = {
				relative = "cursor",
				width = 0.6,
				height = 0.6,
				border = vim.o.winborder --[[@as "rounded"|"single"|"double"|"solid"]],
				title = " 󰆽 Git blame ",
			},
		},
	},
}
