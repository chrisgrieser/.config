-- DOCS https://github.com/folke/snacks.nvim/blob/main/docs/picker.md
--------------------------------------------------------------------------------
---@module "snacks"

return {
	"folke/snacks.nvim",
	keys = {
		-- FILES
		{
			"go",
			function() Snacks.picker.smart { title = "󰧑 " .. vim.fs.basename(vim.uv.cwd()) } end,
			desc = "󰧑 Smart open files",
		},
		{
			"gO",
			function() Snacks.picker.files { title = " " .. vim.fs.basename(vim.uv.cwd()) } end,
			desc = " Open files",
		},
		{
			"g,",
			function()
				Snacks.picker.files { cwd = vim.fn.stdpath("config"), title = " nvim config" }
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
			"gP",
			function()
				local projects = vim.iter(vim.fs.dir(vim.g.localRepos))
					:fold({}, function(acc, item, type)
						if type == "directory" then table.insert(acc, item) end
						return acc
					end)

				vim.ui.select(projects, { prompt = " Select project: " }, function(project)
					if not project then return end
					local path = vim.fs.joinpath(vim.g.localRepos, project)
					Snacks.picker.projects { title = " " .. project, cwd = path }
				end)
			end,
			desc = " Project",
		},
		{
			"gr",
			function() Snacks.picker.recent() end,
			desc = " Recent files",
			nowait = true, -- nvim default mappings starting with `gr`
		},
		{ "gl", function() Snacks.picker.grep() end, desc = "󰛢 Grep" },
		{
			"<leader>ci",
			function()
				Snacks.picker.grep{

				}
			end,
			ft = "lua",
			desc = "󰛢 Import",
		},

		--------------------------------------------------------------------------
		-- LSP

		{ "gf", function() Snacks.picker.lsp_references() end, desc = "󰈿 References" },
		{ "gd", function() Snacks.picker.lsp_definitions() end, desc = "󰈿 Definitions" },
		{ "gD", function() Snacks.picker.lsp_type_definitions() end, desc = "󰜁 Type definitions" },
		-- stylua: ignore
		{ "gw", function() Snacks.picker.lsp_workspace_symbols() end, desc = "󰒕 Workspace symbols" },
		{ "gs", function() Snacks.picker.lsp_symbols() end, desc = "󰒕 Symbols" },
		{ "g!", function() Snacks.picker.diagnostics() end, desc = "󰋼 Workspace diagnostics" },

		--------------------------------------------------------------------------
		-- GIT

		{ "<leader>gb", function() Snacks.picker.git_branches() end, desc = "󰭎 Branches" },
		{ "<leader>gs", function() Snacks.picker.git_status() end, desc = "󰭎 Status" },
		{ "<leader>gl", function() Snacks.picker.git_log() end, desc = "󰭎 Log" },

		--------------------------------------------------------------------------
		-- MISC

		{ "<leader>ih", function() Snacks.picker.highlights() end, desc = "󰗲 Highlights" },
		{ "<leader>pc", function() Snacks.picker.colorschemes() end, desc = "󰗲 Colorschemes" },
		-- stylua: ignore
		{ "<C-.>", function() Snacks.picker.icons() end, mode = { "n", "i" }, desc = "󱗿 Icon picker" },

		{ "g.", function() Snacks.picker.resume() end, desc = "󰗲 Resume" },
		{ "<leader>iv", function() Snacks.picker.help() end, desc = "󰋖 Vim help" },

		{ "<leader>ut", function() Snacks.picker.undo() end, desc = "󰋚 Undo tree" },

		{ "<leader>ik", function() Snacks.picker.keymaps() end, desc = "󰌌 Keymaps (global)" },
		{
			"<leader>iK",
			function() Snacks.picker.keymaps { global = false, title = "󰌌 Keymaps (buffer)" } end,
			desc = "󰌌 Keymaps (buffer)",
		},
	},
	opts = {
		---@class snacks.picker.Config
		picker = {
			ui_select = true, -- use `vim.ui.select`
			-- https://github.com/folke/snacks.nvim/blob/main/docs/picker.md#%EF%B8%8F-layouts

			sources = {
				files = {
					cmd = "rg",
					args = {
						"--sortr=modified", -- sort by recency
						("--ignore-file=" .. vim.fs.normalize("~/.config/ripgrep/ignore")),
					},
					layout = "small_no_preview",
				},
				recent = {
					filter = { paths = {} },
					layout = "small_no_preview",
				},
				smart = {
					layout = "small_no_preview",
				},
				grep = {
					cmd = "rg",
					args = {
						"--sortr=modified", -- sort by recency
						("--ignore-file=" .. vim.fs.normalize("~/.config/ripgrep/ignore")),
					},
				},
				help = {
					confirm = function(picker)
						picker:action("help")
						vim.cmd.only() -- so help is full window
					end,
				},
				keymaps = {
					-- open keymap definition
					confirm = function(picker, item)
						if not item.file then return end
						picker:close()
						vim.cmd(("edit +%d %s"):format(item.pos[1], item.file))
					end,
				},
				colorschemes = {
					layout = { preset = "ivy" }, -- at the bottom, so there is more space to preview
				},
				icons = {
					layout = {
						preset = "small_no_preview",
						layout = { width = 0.7 },
					},
				},
				highlights = {
					confirm = function(picker, item)
						vim.fn.setreg("+", item.hl_group)
						vim.notify(item.hl_group, nil, { title = "Copied", icon = "󰅍" })
						picker:close()
					end,
				},
				git_status = {
					win = {
						input = {
							keys = {
								["<Tab>"] = { "list_down_wrapping", mode = "i" },
								["<Space>"] = { "git_stage", mode = "i" },
								-- <CR> opens the file as usual
							},
						},
					},
				},
				git_branches = {
					all = true, -- = include remotes
				},
			},

			formatters = {
				file = { filename_first = true, truncate = 70 },
			},
			previewers = {
				diff = { builtin = false }, -- use delta automatically
				git = { builtin = false },
			},
			layout = "wide_with_preview", -- use this as default layout
			layouts = { -- define available layouts
				small_no_preview = {
					layout = {
						box = "horizontal",
						width = 0.6,
						height = 0.6,
						border = "none",
						{
							box = "vertical",
							border = vim.o.winborder, ---@diagnostic disable-line: assign-type-mismatch faulty annotation
							title = "{title} {live} {flags}",
							{ win = "input", height = 1, border = "bottom" },
							{ win = "list", border = "none" },
						},
					},
				},
				wide_with_preview = {
					preset = "small_no_preview", -- inherit from above
					layout = {
						width = 0.99,
						[2] = { -- as second column
							win = "preview",
							title = "{preview}",
							border = vim.o.winborder, ---@diagnostic disable-line: assign-type-mismatch faulty annotation
							width = 0.5,
							wo = { number = false, statuscolumn = " ", signcolumn = "no" },
						},
					},
				},
			},
			win = {
				input = {
					keys = {
						["<CR>"] = { "confirm", mode = "i" },
						["<Esc>"] = { "cancel", mode = "i" }, -- = disable normal mode
						["<Tab>"] = { "list_down_wrapping", mode = "i" },
						["<S-Tab>"] = { "list_up", mode = "i" },
						["<D-Up>"] = { "list_top", "jump", mode = "i" },
						["<M-CR>"] = { "select_and_next", mode = "i" }, -- consistent with `fzf`
						["<Up>"] = { "history_back", mode = "i" },
						["<Down>"] = { "history_forward", mode = "i" },
						["<C-h>"] = { "toggle_hidden_and_ignored", mode = "i" }, -- consistent with `fzf`
						["<D-s>"] = { "qflist_and_go", mode = "i" },
						["<D-p>"] = { "toggle_preview", mode = "i" },
						["<D-l>"] = { "reveal_in_macOS_Finder", mode = "i" },
						["<D-c>"] = { "yank_display_text", mode = "i" },
						["<PageUp>"] = { "preview_scroll_up", mode = "i" },
						["<PageDown>"] = { "preview_scroll_down", mode = "i" },
						["?"] = { "inspect", mode = "i" },
					},
				},
			},
			actions = {
				list_down_wrapping = function(picker)
					local allVisible = #picker.list.items -- picker:count() only counts unfiltered
					local current = picker.list.cursor -- picker:current().idx incorrect for `smart` source
					local action = current == allVisible and "list_top" or "list_down"
					picker:action(action)
				end,
				toggle_hidden_and_ignored = function(picker)
					picker.opts["hidden"] = not picker.opts.hidden
					picker.opts["ignored"] = not picker.opts.ignored
					picker.opts["exclude"] = { ".DS_Store" }
					picker:find()
				end,
				reveal_in_macOS_Finder = function(picker)
					local item = picker:current()
					if jit.os ~= "OSX" or not item then return end
					local absPath = item.cwd .. "/" .. item.file
					vim.system { "open", "-R", absPath }
					picker:close()
				end,
				qflist_and_go = function(picker)
					picker:action("qflist")
					vim.cmd.cclose()
					vim.cmd.cfirst()
				end,
				yank_display_text = function(picker)
					local value = picker:current().text
					vim.fn.setreg("+", value)
					vim.notify(value, nil, { title = "Copied", icon = "󰅍" })
					picker:close()
				end,
			},
			prompt = " ", -- slightly to the left
			icons = { ---@diagnostic disable-line: missing-fields -- faulty annotation
				ui = { selected = "󰒆 ", unselected = "  " },
				git = { staged = "󰐖" }, -- consistent with tinygit
				undo = { saved = "" }, -- useless, since I have auto-saving
			},
		},
	},
}
