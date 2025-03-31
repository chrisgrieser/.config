-- DOCS https://github.com/folke/snacks.nvim/blob/main/docs/picker.md
--------------------------------------------------------------------------------
---@module "snacks"

return {
	"folke/snacks.nvim",
	keys = {
		-- FILES
		{
			"go",
			function()
				Snacks.picker.files {
					title = " " .. vim.fs.basename(vim.uv.cwd() or "n/a"),
				}
			end,
			desc = " Open files",
		},
		{
			"g,",
			function()
				Snacks.picker.files {
					cwd = vim.fn.stdpath("config"),
					title = " nvim config",
				}
			end,
			desc = " nvim config",
		},
		{
			"gp",
			function()
				Snacks.picker.files {
					title = "󰈮 Local plugins",
					cwd = vim.fn.stdpath("data") .. "/lazy",
					exclude = { "tests/*", "doc/*", "*.toml" },
					matcher = { filename_bonus = false },
					formatters = { file = { filename_first = false } },
				}
			end,
			desc = "󰈮 Local plugins",
		},
		{
			"gr",
			function() Snacks.picker.recent() end,
			desc = " Recent files",
			nowait = true, -- nvim default mappings starting with `gr`
		},
		-- LSP
		{
			"<C-.>",
			function() Snacks.picker.icons() end,
			mode = { "n", "i" },
			desc = "󱗿 Icon picker",
		},
		{ "gf", function() Snacks.picker("lsp_references") end, desc = "󰈿 References" },
		{ "gd", function() Snacks.picker("lsp_definitions") end, desc = "󰈿 Definitions" },
		-- stylua: ignore
		{ "gD", function() Snacks.picker("lsp_type_definitions") end, desc = "󰜁 Type definitions" },
		--------------------------------------------------------------------------
		{ "g.", function() Snacks.picker("resume") end, desc = "󰭎 Resume" },
	},
	opts = {
		picker = {
			ui_select = true, -- use `vim.ui.select`
			-- https://github.com/folke/snacks.nvim/blob/main/docs/picker.md#%EF%B8%8F-layouts
			layout = function(source)
				local small = {
					layout = {
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
					},
				}
				local large = vim.deepcopy(small)
				large.layout.width = 0.9
				large.layout.height = 0.7
				large.layout[2] = {
					win = "preview",
					title = "{preview}",
					border = vim.o.winborder,
					width = 0.5,
					wo = { number = false, statuscolumn = " ", signcolumn = "no" },
				}

				if source == "files" or source == "recent" or source == "icons" then return small end
				return large
			end,

			sources = {
				files = {
					cmd = "rg",
					args = {
						"--sortr=modified", -- sort by recency
						("--ignore-file=" .. vim.fs.normalize("~/.config/ripgrep/ignore")),
					},
				},
				recent = {
					filter = { paths = {} },
				},
				icons = {
					layout = {
						preset = "vertical", -- BUG cannot disable the preset to have it use my default
						preview = false,
						layout = { height = 0.5, min_height = 10, min_width = 70 },
					},
				},
			},

			formatters = {
				file = {
					filename_first = true,
					truncate = math.huge,
				},
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
