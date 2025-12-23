-- DOCS https://github.com/folke/snacks.nvim#-features
--------------------------------------------------------------------------------

return {
	"folke/snacks.nvim",
	event = "UIEnter",
	keys = {
		{ "ö", function() Snacks.words.jump(1, true) end, desc = "󰗲 Next reference" },
		{ "Ö", function() Snacks.words.jump(-1, true) end, desc = "󰗲 Prev reference" },
		{
			"<leader>oi",
			function()
				if Snacks.indent.enabled then
					vim.g.prev_listchars = vim.opt_local.listchars:get()
					vim.opt_local.listchars:append {
						tab = " ",
						space = "·",
						trail = "·",
						lead = "·",
					}
					Snacks.indent.disable()
				else
					vim.opt_local.listchars = vim.g.prev_listchars
					Snacks.indent.enable()
				end
			end,
			desc = " Invisible chars",
		},
	},
	---@type snacks.Config
	opts = {
		input = {
			icon = "",
			win = {
				relative = "editor",
				backdrop = 60,
				title_pos = "left",
				width = 50,
				row = math.ceil(vim.o.lines / 2) - 3,
			},
		},
		words = {
			notify_jump = true,
			modes = { "n" },
			debounce = 300, -- delay until highlight
		},
		indent = {
			char = "│",
			scope = { hl = "Comment" },
			chunk = {
				enabled = false,
				hl = "Comment",
			},
			animate = {
				-- slower for more dramatic effect :o
				duration = { steps = 200, total = 1000 },
			},
		},
	},
}
