vim.pack.add { "https://github.com/folke/snacks.nvim" }
--------------------------------------------------------------------------------

---@type snacks.Config
local opts = {}
local helpers = require("config.snacks-helpers")
--------------------------------------------------------------------------------

opts.input = {
	icon = "",
	win = {
		relative = "editor",
		backdrop = 60,
		title_pos = "left",
		width = 50,
		row = math.ceil(vim.o.lines / 2) - 3,
	},
}

opts.words = {
	notify_jump = true,
	modes = { "n" },
	debounce = 300, -- delay until highlight
}

opts.indent = {
	char = "│",
	scope = { hl = "Comment" },
	animate = {
		-- slower for more dramatic effect :o
		duration = { step = 50, total = 1000 },
	},
}

opts.scratch = {
	filekey = { count = false, cwd = false, branch = false }, -- just one scratch per ft
	win = {
		width = 0.75,
		height = 0.8,
		footer_pos = "right",
		keys = { q = false, ["<D-w>"] = "close" }, -- so `q` is available as my comment operator
		on_win = function(win)
			-- FIX display of scratchpad title (partially hardcoded icon, etc.)
			local title = vim.iter(win.opts.title)
				:map(function(part) return vim.trim(part[1]) end)
				:join(" ")
				:gsub("  ", " ")
			vim.api.nvim_win_set_config(win.win, { title = title })
		end,
	},
	win_by_ft = {
		javascript = helpers.createRunKeymap("node"),
		typescript = createRunKeymap("node"),
		python = createRunKeymap("python3"),
		applescript = createRunKeymap("osascript"),
		swift = createRunKeymap("swift"),
		zsh = createRunKeymap("zsh"),
		lua = {
			keys = {
				source = { desc = "source" }, -- just to shorten keymap hint
				print = {
					-- overwrite chainsaw's `objectLog` with snacks.scratch's
					-- special `print` (uses virtualtext instead of notification)
					"<leader>lo",
					function()
						local logLine = ("print(%s)"):format(vim.fn.expand("<cword>"))
						local installed, chainsaw = pcall(require, "chainsaw.config.config")
						if installed then logLine = logLine .. " -- " .. chainsaw.config.marker end
						vim.cmd.normal { "o", bang = true }
						vim.api.nvim_set_current_line(logLine)
					end,
					desc = "print",
				},
			},
		},
	},
}

--------------------------------------------------------------------------------
require("snacks").setup(opts)
--------------------------------------------------------------------------------

require("config.utils").pluginKeymaps {
	-- words
	{ "ö", function() Snacks.words.jump(1, true) end, desc = "󰗲 Next reference" },
	{ "Ö", function() Snacks.words.jump(-1, false) end, desc = "󰗲 Prev reference" },

	-- indent
	{ "<leader>oi", helpers.toggleInvisibleChars, desc = " Invisible chars" },

	-- scratch
	{
		"<leader>es",
		function()
			if vim.bo.ft == "lua" then helpers.ensureLuarcForScratch() end
			Snacks.scratch()
		end,
		desc = " Scratch buffer",
	},
	{ "<leader>el", function() Snacks.scratch.select() end, desc = " List scratches" },
}
