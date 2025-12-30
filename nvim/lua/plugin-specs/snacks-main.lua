-- DOCS https://github.com/folke/snacks.nvim#-features
--------------------------------------------------------------------------------

return {
	"folke/snacks.nvim",
	event = "UIEnter",
	keys = {
		{ "ö", function() Snacks.words.jump(1, true) end, desc = "󰗲 Next reference" },
		{ "Ö", function() Snacks.words.jump(-1, false) end, desc = "󰗲 Prev reference" },
		{
			"<leader>oi",
			function()
				-- toggle invisible chars, disable when leaving buffer
				local function reEnable()
					vim.opt_local.listchars = vim.b.indent_prevListChars
					Snacks.indent.enable()
					vim.api.nvim_del_autocmd(vim.b.indent_autocmdId)
				end

				if Snacks.indent.enabled then
					vim.b.indent_prevListChars = vim.opt_local.listchars:get()
					-- stylua: ignore
					vim.opt_local.listchars:append { tab = " ", space = "·", trail = "·", lead = "·" }
					Snacks.indent.disable()
					vim.b.indent_autocmdId =
						vim.api.nvim_create_autocmd("BufLeave", { callback = reEnable })
				else
					reEnable()
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
			animate = {
				-- slower for more dramatic effect :o
				duration = { step = 50, total = 1000 },
			},
		},
	},
}
