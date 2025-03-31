-- DOCS https://github.com/folke/snacks.nvim/blob/main/docs/picker.md
--------------------------------------------------------------------------------

return {
	"folke/snacks.nvim",
	keys = {
		{
			"<C-.>",
			function() require("snacks").picker.icons() end,
			mode = "i",
			desc = "󱗿 Icon picker",
		},
		{
			"go",
			function()
				require("snacks").picker.files {
					cmd = "rg",
					args = {
						"--sortr=modified", -- sort by recency
						("--ignore-file=" .. vim.fs.normalize("~/.config/ripgrep/ignore")),
					},
				}
			end,
			desc = "󱗿 Files",
		},
	},
	opts = {
		picker = {
			ui_select = true, -- use `vim.ui.select`

			-- https://github.com/folke/snacks.nvim/blob/main/docs/picker.md#%EF%B8%8F-layouts
			layout = function(source)
				local lll = {}
				if source == "files" or source == "recent" then
					lll.layout = {
						box = "horizontal",
						width = 0.6,
						height = 0.6,
						border = "none",
						{
							box = "vertical",
							border = vim.o.winborder,
							title = "{title} {live} {flags}",
							{ win = "input", height = 1, border = "bottom" },
							{ win = "list", border = "none" },
						},
					}
				else
					lll.layout = {
						box = "horizontal",
						width = 0.8,
						height = 0.6,
						border = "none",
						{
							box = "vertical",
							border = vim.o.winborder,
							title = "{title} {live} {flags}",
							{ win = "input", height = 1, border = "bottom" },
							{ win = "list", border = "none" },
						},
						{
							win = "preview",
							title = "{preview}",
							border = vim.o.winborder,
							width = 0.5,
							wo = { number = false, statuscolumn = " ", signcolumn = "no" },
						},
					}
				end
				return lll
			end,

			formatters = {
				file = { filename_first = true, truncate = 40 },
			},
			win = {
				input = {
					keys = {
						["<CR>"] = { "confirm", mode = "i" },
						["<Esc>"] = { "cancel", mode = "i" }, -- = disable normal mode
						["<Tab>"] = { "list_down", mode = "i" },
						["<S-Tab>"] = { "list_up", mode = "i" },
						["<M-CR>"] = { "select_and_next", mode = "i" }, -- consistent with `fzf`
						["<Up>"] = { "history_back", mode = "i" },
						["<Down>"] = { "history_forward", mode = "i" },
						["<C-h>"] = { "toggle_hidden_and_ignored", mode = "i" }, -- consistent with `fzf`
						["<D-s>"] = { "qflist_and_go", mode = "i" },
						["<D-p>"] = { "toggle_preview", mode = "i" },
						["<D-l>"] = { "reveal_in_macOS_Finder", mode = "i" },
						["<D-c>"] = { "copy_value", mode = "i" },
						["<PageUp>"] = { "preview_scroll_up", mode = "i" },
						["<PageDown>"] = { "list_scroll_down", mode = "i" },
						["?"] = { "toggle_help_input", mode = "i" },
						["!"] = { "inspect", mode = "i" },
					},
				},
			},
			actions = {
				toggle_hidden_and_ignored = function(picker)
					picker.opts.hidden = not picker.opts.hidden
					picker.opts.ignored = not picker.opts.ignored
					picker.opts.exclude = { ".DS_Store" }
					picker:find()
				end,
				reveal_in_macOS_Finder = function(picker)
					if jit.os ~= "OSX" then return end
					local item = picker:current()
					local absPath = item.cwd .. "/" .. item.file
					vim.system { "open", "-R", absPath }
					picker:close()
				end,
				qflist_and_go = function(picker)
					picker:action("qflist")
					vim.cmd.cclose()
					vim.cmd.cfirst()
				end,
				copy_value = function(picker)
					local value = picker:current().text
					vim.fn.setreg("+", value)
					vim.notify(value, nil, { title = "Copied", icon = "󰅍" })
					picker:close()
				end,
			},
		},
	},
}
