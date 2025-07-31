-- DOCS https://github.com/folke/snacks.nvim#-features
---@module "snacks"
--------------------------------------------------------------------------------

return {
	"folke/snacks.nvim",
	event = "UIEnter",

	config = function(_, opts)
		require("snacks").setup(opts)

		-- modify certain notifications
		vim.notify = function(msg, lvl, nOpts) ---@diagnostic disable-line: duplicate-set-field intentional overwrite
			nOpts = nOpts or {}

			local ignore = (msg == "No code actions available" and vim.bo.ft == "typescript")
				or msg:find("^Client marksman quit with exit code 1 and signal 0.") -- https://github.com/artempyanykh/marksman/issues/348
				or msg:find("^Error executing vim.schedule.*/_folding_range.lua:311")
			if ignore then return end

			if msg:find("Hunk %d+ of %d+") then -- gitsigns.nvim
				nOpts.style = "minimal"
				msg = msg .. "  "
				nOpts.icon = "󰊢 "
				nOpts.id = "gitsigns"
			elseif msg:find("^%[nvim%-treesitter") then -- treesitter parser update
				nOpts.id = "treesitter-parser-update"
			end
			Snacks.notifier(msg, lvl, nOpts)
		end

		-- disable default keymaps to make the `?` help overview less cluttered
		require("snacks.picker.config.defaults").defaults.win.input.keys = {}
		require("snacks.picker.config.defaults").defaults.win.list.keys = {}
		require("snacks.picker.config.sources").explorer.win.list.keys = {}
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
				border = vim.o.winborder --[[@as "rounded"|"single"|"double"|"solid"]],
				title_pos = "left",
				width = 50,
				row = math.ceil(vim.o.lines / 2) - 3,
			},
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
