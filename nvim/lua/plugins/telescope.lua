local keymappings = {
	-- INFO default mappings: https://github.com/nvim-telescope/telescope.nvim/blob/master/lua/telescope/mappings.lua#L133
	["<Esc>"] = "close",
	["<D-w>"] = "delete_buffer", -- only buffer picker
	["<S-Down>"] = "preview_scrolling_down",
	["<S-Up>"] = "preview_scrolling_up",
	["<C-h>"] = "cycle_history_prev",
	["<C-l>"] = "cycle_history_next",
	["^"] = "smart_send_to_qflist", -- sends selected, or if none selected, sends all
	["<D-a>"] = "select_all", 
}

local function telescopeConfig()
	require("telescope").setup {
		defaults = {
			selection_caret = "ﰉ ",
			prompt_prefix = "❱ ",
			multi_icon = "洛",
			path_display = { "tail" },
			borderchars = BorderChars,
			history = { path = VimDataDir .. "telescope_history" }, -- sync the history
			file_ignore_patterns = {
				"%.git/",
				"%.git$", -- git dir in submodules
				"node_modules/", -- node
				"venv/", -- python
				"%.app/", -- internals of mac apps
				"%.pxd", -- Pixelmator
				"%.plist", -- Alfred
				"%.harpoon", -- harpoon/projects
				"/INFO ", -- custom info files
				"%.png",
				"%.gif",
				"%.jpe?g",
				"%.icns",
				"%.zip",
			},
			mappings = {
				i = keymappings,
				n = keymappings,
			},
			vimgrep_arguments = {
				"rg",
				"--color=never",
				"--no-heading",
				"--with-filename",
				"--line-number",
				"--column",
				"--smart-case",
				"--trim", -- this added to trim results
			},
			layout_strategy = "horizontal",
			layout_config = {
				horizontal = {
					height = 0.9,
					preview_cutoff = 70,
					width = 0.9,
					preview_width = { 0.55, min = 30 },
				},
				cursor = {
					preview_cutoff = 9001, -- never use preview here
					height = 1,
				},
				bottom_pane = {
					height = 8,
					preview_cutoff = 70,
					prompt_position = "bottom",
				},
			},
		},

		pickers = {
			lsp_references = {
				prompt_prefix = " ",
				show_line = false,
				trim_text = true,
				include_declaration = false,
				initial_mode = "normal",
			},
			lsp_type_definitions = {
				prompt_prefix = "ﴰ ",
				show_line = false,
				trim_text = true,
				initial_mode = "normal",
				theme = "cursor",
				layout_config = {
					cursor = {
						width = 0.7,
						preview_cutoff = 30,
					},
				},
			},
			lsp_definitions = {
				prompt_prefix = " ",
				show_line = false,
				trim_text = true,
				initial_mode = "normal",
				theme = "cursor",
				layout_config = {
					cursor = {
						width = 0.7,
						preview_cutoff = 30,
					},
				},
			},
			lsp_document_symbols = {
				prompt_prefix = "璉 ",
				-- markdown headings are symbol-type "string"
				ignore_symbols = { "boolean", "number" }, 
				fname_width = 17,
			},
			lsp_workspace_symbols = {
				prompt_prefix = "璉 ",
				ignore_symbols = { "string", "boolean", "number" },
				fname_width = 17,
			},
			treesitter = {
				prompt_prefix = " ",
				show_line = false,
			},
			find_files = {
				prompt_title = "Project Files",
				prompt_prefix = " ",
				hidden = true,
				follow = true, -- follow symlinks
				no_ignore = false, -- use fd ignore files
			},
			keymaps = { prompt_prefix = "  ", modes = { "n", "i", "c", "x", "o", "t" } },
			oldfiles = { prompt_prefix = " " },
			highlights = { prompt_prefix = " " },
			buffers = {
				prompt_prefix = "﬘ ",
				ignore_current_buffer = false,
				initial_mode = "normal",
				sort_mru = true,
				prompt_title = false,
				results_title = false,
				theme = "cursor",
				layout_config = { cursor = { width = 0.5 } },
			},
			quickfix = {
				trim_text = true,
				show_line = true,
				prompt_prefix = " ",
			},
			live_grep = {
				cwd = "%:p:h",
				disable_coordinates = true,
				prompt_title = "Search in Folder",
				prompt_prefix = " ",
			},
			loclist = {
				trim_text = true,
				prompt_prefix = " ",
			},
			spell_suggest = {
				initial_mode = "normal",
				prompt_prefix = "暈",
				theme = "cursor",
				layout_config = { cursor = { width = 0.3 } },
			},
			colorscheme = {
				enable_preview = true,
				prompt_prefix = " ",
				results_title = false,
				layout_strategy = "bottom_pane",
			},
		},
		extensions = {
			file_browser = {
				prompt_prefix = " ",
				depth = false,
				hidden = true,
				display_stat = false,
				git_status = false,
				group = true,
				hide_parent_dir = false,
				select_buffer = true,
				mappings = {
					["i"] = {
						-- mappings should be consistent with nvim-ghengis mappings
						["<D-n>"] = require("telescope._extensions.file_browser.actions").create,
						["<C-r>"] = require("telescope._extensions.file_browser.actions").rename,
						["<D-BS>"] = require("telescope._extensions.file_browser.actions").remove,

						["<D-a>"] = require("telescope._extensions.file_browser.actions").select_all,
						["<D-b>"] = require("telescope._extensions.file_browser.actions").toggle_browser,
					},
				},
			},
		},
	}
end

return {
	{
		"nvim-telescope/telescope.nvim",
		cmd = "Telescope",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"nvim-tree/nvim-web-devicons",
			"nvim-telescope/telescope-file-browser.nvim",
		},
		config = function()
			telescopeConfig()
			require("telescope").load_extension("file_browser")
		end,
	},
}
