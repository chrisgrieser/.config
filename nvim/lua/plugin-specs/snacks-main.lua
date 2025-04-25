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
		vim.notify = function(msg, ...) ---@diagnostic disable-line: duplicate-set-field intentional overwrite
			if type(msg) == "string" then
				local ignore = msg == "No code actions available"
					or msg:find("^Client marksman quit with exit code 1 and signal 0.")
				if ignore then return end
			end
			Snacks.notifier(msg, ...)
		end

		-- disable default keymaps to make the `?` help overview less cluttered
		require("snacks.picker.config.defaults").defaults.win.input.keys = {}
		require("snacks.picker.config.defaults").defaults.win.list.keys = {}

		-- cleaner vim.ui.select
		---@type fun(kind?: string): snacks.picker.format
		require("snacks.picker.format").ui_select = function(kind)
			return function(item)
				if kind == "codeaction" then
					local action = item.item.action ---@type lsp.CodeAction
					return {
						{ action.title .. " " },
						{ action.kind or "", "SnacksPickerSpecial" },
					}
				end
				return { { item.formatted } }
			end
		end
	end,

	keys = {
		{ "ö", function() Snacks.words.jump(1, true) end, desc = "󰗲 Next reference" },
		{ "Ö", function() Snacks.words.jump(-1, true) end, desc = "󰗲 Prev reference" },
		{ "<leader>g?", function() Snacks.git.blame_line() end, desc = "󰆽 Blame line" },
		{
			"<leader>ee",
			function()
				vim.ui.input({
					prompt = "󰢱 Eval",
					win = { ft = "lua" }, --> this part is snacks-specific
				}, function(expr)
					if not expr then return end
					local result = vim.inspect(vim.fn.luaeval(expr))
					local opts = { title = "Eval", icon = "󰢱", ft = "lua" }
					vim.notify(result, vim.log.levels.DEBUG, opts)
				end)
			end,
			desc = "󰢱 Eval lua expr",
		},
		{
			"<leader>oi",
			function()
				if Snacks.indent.enabled then
					vim.opt_local.listchars:append { tab = " ", space = "·", trail = "·", lead = "·" }
					Snacks.indent.disable()
				else
					vim.opt_local.listchars:append { tab = "  ", space = " ", trail = " ", lead = " " }   
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
				border = vim.o.winborder --[[@as "rounded"|"single"|"double"|"solid"]],
				title_pos = "left",
				width = 50,
				row = math.ceil(vim.o.lines / 2) - 3,
			},
		},
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
		styles = {
			blame_line = {
				relative = "editor",
				width = 0.65,
				height = 0.8,
				border = vim.o.winborder --[[@as "rounded"|"single"|"double"|"solid"]],
				title = " 󰆽 Git blame ",
			},
		},
	},
}
