local u = require("config.utils")
--------------------------------------------------------------------------------

local keymappings = {
	-- default mappings: https://github.com/nvim-telescope/telescope.nvim/blob/942fe5faef47b21241e970551eba407bc10d9547/lua/telescope/mappings.lua#L133
	["<Esc>"] = "close",
	["<PageDown>"] = "preview_scrolling_down",
	["<PageUp>"] = "preview_scrolling_up",
	["<C-h>"] = "cycle_history_prev",
	["<C-l>"] = "cycle_history_next",
	["<D-s>"] = function(prompt_bufnr) -- sends selected, or if none selected, sends all
		require("funcs.quickfix").deleteList() -- delete current list
		require("telescope.actions").smart_send_to_qflist(prompt_bufnr)
	end,
	["<Tab>"] = "move_selection_worse",
	["<S-Tab>"] = "move_selection_better",
	["?"] = "which_key",
	["<D-CR>"] = function(prompt_bufnr)
		require("telescope.actions").toggle_selection(prompt_bufnr)
		require("telescope.actions").move_selection_worse(prompt_bufnr)
	end,
	["<C-p>"] = function(prompt_bufnr)
		-- Copy path of file -- https://github.com/nvim-telescope/telescope-file-browser.nvim/issues/191
		local path = require("telescope.actions.state").get_selected_entry().value
		require("telescope.actions").close(prompt_bufnr)

		local clipboardOpt = vim.opt.clipboard:get()
		local useSystemClipb = #clipboardOpt > 0 and clipboardOpt[1]:find("unnamed")
		local reg = useSystemClipb and "+" or '"'
		vim.fn.setreg(reg, path)
		vim.notify("COPIED \n" .. path)
	end,
}

local function telescopeConfig()
	-- https://github.com/nvim-telescope/telescope.nvim/issues/605
	local deltaPreviewer = require("telescope.previewers").new_termopen_previewer {
		get_command = function(entry)
			-- we can't use pipes
			-- stylua: ignore
			return { "git", "-c", "core.pager=delta", "-c", "delta.side-by-side=false", "diff", entry.value .. "^!" }
		end,
	}

	require("telescope").setup {
		defaults = {
			selection_caret = "󰜋 ",
			prompt_prefix = "❱ ",
			multi_icon = "󰒆 ",
			preview = {
				timeout = 100, -- ms
				filesize_limit = 0.3, -- in MB, do not preview big files for performance
			},
			path_display = { "tail" },
			borderchars = u.borderChars,
			history = { path = u.vimDataDir .. "telescope_history" }, -- sync the history
			file_ignore_patterns = {
				"%.git/",
				"%.git$", -- git dir in submodules
				"node_modules/", -- node
				"venv/", -- python
				"%.app/", -- internals of mac apps
				"%.pxd", -- Pixelmator
				"%.plist$", -- Alfred
				"%.project-root$", -- harpoon/projects
				"%.png$",
				"%.gif$",
				"%.icns",
				"%.zip$",
				".DS_Store", -- needs to be explicitly added, since unignored in some repos
				"%-bkp$", -- backup files
			},
			mappings = {
				i = keymappings,
				n = keymappings,
			},
			sorting_strategy = "ascending", -- so layout is correctly orientated with prompt_position "top"
			layout_strategy = "horizontal",
			layout_config = {
				horizontal = {
					prompt_position = "top",
					height = 0.7,
					width = 0.99,
					preview_cutoff = 70,
					preview_width = { 0.50, min = 30 },
					-- anchor = "S",
				},
			},
		},
		pickers = {
			git_status = {
				prompt_prefix = "󰊢 ",
				show_untracked = true,
			},
			git_commits = {
				prompt_prefix = "󰊢 ",
				initial_mode = "normal",
				results_title = "git log",
				git_command = { "git", "log", "--all", "--pretty=%h %s (%cr)", "--", "." },
				previewer = deltaPreviewer,
			},
			git_bcommits = {
				prompt_prefix = "󰊢 ",
				initial_mode = "normal",
				results_title = "git log (buffer)",
				previewer = deltaPreviewer,
			},
			git_branches = {
				prompt_prefix = "󰊢 ",
				initial_mode = "normal",
			},
			keymaps = {
				prompt_prefix = " ",
				modes = { "n", "i", "c", "x", "o", "t" },
				show_plug = false, -- do not show mappings with "<Plug>"
				lhs_filter = function(lhs) return not lhs:find("Þ") end, -- remove which-key mappings
			},
			diagnostics = { prompt_prefix = "󰒕 ", no_sign = true },
			treesitter = { prompt_prefix = " ", show_line = false },
			oldfiles = { prompt_prefix = "󰋚 " },
			highlights = {
				prompt_prefix = " ",
				layout_config = {
					horizontal = {
						preview_width = { 0.7, min = 30 },
					},
				},
			},
			live_grep = { prompt_prefix = " ", disable_coordinates = true },
			grep_string = { prompt_prefix = " ", disable_coordinates = true },
			loclist = {
				prompt_prefix = " ",
				trim_text = true,
				fname_width = 0,
			},
			lsp_references = {
				prompt_prefix = "󰈿 ",
				show_line = true,
				trim_text = true,
				include_declaration = false,
				include_current_line = false,
				initial_mode = "normal",
				fname_width = 12,
			},
			lsp_definitions = {
				prompt_prefix = "󰈿 ",
				show_line = true,
				trim_text = true,
				initial_mode = "normal",
				fname_width = 12,
			},
			lsp_document_symbols = {
				prompt_prefix = "󰒕 ",
				-- markdown headings are symbol-type "string", therefore shouldn't be ignored
				ignore_symbols = { "boolean", "number" },
				fname_width = 12,
			},
			lsp_workspace_symbols = {
				prompt_prefix = "󰒕 ",
				ignore_symbols = { "string", "boolean", "number" },
				fname_width = 12,
			},
			buffers = {
				prompt_prefix = "󰽙 ",
				ignore_current_buffer = false,
				initial_mode = "normal",
				mappings = { n = { ["<D-w>"] = "delete_buffer" } },
				sort_mru = true,
				prompt_title = false,
				results_title = false,
				theme = "cursor",
				previewer = false,
				layout_config = { cursor = { width = 0.5, height = 0.4 } },
			},
			spell_suggest = {
				initial_mode = "normal",
				prompt_prefix = "󰓆",
				theme = "cursor",
				previewer = false,
				layout_config = { cursor = { width = 0.3 } },
			},
			colorscheme = {
				enable_preview = true,
				prompt_prefix = " ",
				results_title = false,
				layout_strategy = "horizontal",
				layout_config = {
					horizontal = {
						height = 0.4,
						width = 0.3,
						anchor = "SE",
						preview_width = 1, -- needs preview for live preview of the theme
					},
				},
			},
		},
		extensions = {
			undo = {
				entry_format = "#$ID ($STAT) $TIME",
				layout_config = {
					-- more space for diffview useful here
					horizontal = {
						height = 0.8,
						preview_width = { 0.70, min = 30 },
					},
				},
				mappings = {
					i = {
						["<cr>"] = require("telescope-undo.actions").restore,
						["<D-S-c>"] = require("telescope-undo.actions").yank_additions,
						["<D-c>"] = require("telescope-undo.actions").yank_deletions,
					},
				},
			},
			file_browser = {
				prompt_prefix = " ",
				depth = 2, -- initial depth (1 = only current folder)
				auto_depth = true, -- unlimited depth as soon as prompt is non-empty
				hidden = true,
				display_stat = false,
				git_status = true, -- seems to be buggy sometimes
				group = true,
				hide_parent_dir = true, -- "../"
				select_buffer = false,
				mappings = {
					i = {
						-- mappings should be consistent with nvim-ghengis mappings
						["<C-r>"] = require("telescope._extensions.file_browser.actions").rename,
						["<D-BS>"] = require("telescope._extensions.file_browser.actions").remove,

						-- go up
						["<D-Up>"] = require("telescope._extensions.file_browser.actions").goto_parent_dir,

						-- unmap <BS> on empty prompt going up; requires lowercase key
						["<bs>"] = false,
						-- disable to prevent interference with setting undopoints via `<C-g>u`
						["<C-g>"] = false,
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
			"nvim-tree/nvim-web-devicons", -- add icons
			"nvim-telescope/telescope-file-browser.nvim", -- search folders
			"smartpde/telescope-recent-files", -- better oldfiles
			"debugloop/telescope-undo.nvim", -- undotree

			-- also listed here as dependency, so it can be used by telescope
			-- before cmp is loaded
			"nvim-telescope/telescope-fzf-native.nvim", -- better fuzzy finder
		},

		config = function()
			telescopeConfig()
			require("telescope").load_extension("file_browser")
			require("telescope").load_extension("recent_files")
			require("telescope").load_extension("undo")

			-- INFO since used for cmp-fuzzy-buffer already, might as well add it
			-- here as well. Even though performance-wise vanilla telescope is fine
			-- for me, it does add the minor benefit of having better query syntax
			-- https://github.com/nvim-telescope/telescope-fzf-native.nvim#telescope-fzf-nativenvim
			require("telescope").load_extension("fzf")
		end,
	},
}
