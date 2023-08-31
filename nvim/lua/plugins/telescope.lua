local u = require("config.utils")
--------------------------------------------------------------------------------

-- default mappings: https://github.com/nvim-telescope/telescope.nvim/blob/942fe5faef47b21241e970551eba407bc10d9547/lua/telescope/mappings.lua#L133
local keymappings_I = {
	["<CR>"] = "select_default",
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
	["<Down>"] = "move_selection_worse",
	["<Up>"] = "move_selection_better",
	["?"] = "which_key",
	["<D-CR>"] = function(prompt_bufnr)
		require("telescope.actions").toggle_selection(prompt_bufnr)
		require("telescope.actions").move_selection_worse(prompt_bufnr)
	end,
	["<D-l>"] = function(prompt_bufnr)
		-- Reveal File in macOS Finder
		local path = require("telescope.actions.state").get_selected_entry().value
		require("telescope.actions").close(prompt_bufnr)
		vim.fn.system { "open", "-R", path }
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

local keymappings_N = vim.deepcopy(keymappings_I)
keymappings_N["j"] = "move_selection_worse"
keymappings_N["k"] = "move_selection_better"

--------------------------------------------------------------------------------

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

			-- other ignores are defined via .gitignore, .ignore, or fd/ignore
			file_ignore_patterns = {
				"%.png$",
				"%.gif$",
				"%.jpe?g$",
				"%.icns$",
				"%.zip$",
				"%.pxd$",
				"%.plist$",
			},
			preview = {
				timeout = 200, -- ms
				filesize_limit = 0.3, -- in MB, do not preview big files for performance
			},
			path_display = function(_, path)
				local tail = vim.fs.basename(path)
				local parent = vim.fs.basename(vim.fs.dirname(path))
				if parent == "." then return tail end
				return string.format("%s  (%s)", tail, parent)
			end,
			borderchars = u.borderChars,
			history = { path = u.vimDataDir .. "telescope_history" }, -- sync the history
			default_mappings = { i = keymappings_I, n = keymappings_N },
			sorting_strategy = "ascending", -- so layout is correctly orientated with prompt_position "top"
			layout_strategy = "horizontal",
			layout_config = {
				horizontal = {
					prompt_position = "top",
					height = 0.75,
					width = 0.99,
					preview_cutoff = 70,
					preview_width = { 0.55, min = 30 },
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
				previewer = deltaPreviewer,
				layout_config = { horizontal = { height = 0.9 } },
				-- add commit time (%cr)
				git_command = { "git", "log", "--pretty=%h %s (%cr)", "--", "." },
			},
			git_bcommits = {
				prompt_prefix = "󰊢 ",
				initial_mode = "normal",
				results_title = "git log (buffer)",
				previewer = deltaPreviewer,
				layout_config = { horizontal = { height = 0.9 } },
				-- add commit time (%cr)
				git_command = { "git", "log", "--pretty=%h %s (%cr)", "--", "." },
			},
			git_branches = {
				prompt_prefix = "󰊢 ",
				initial_mode = "normal",
				layout_config = { horizontal = { height = 0.9 } },
			},
			keymaps = {
				prompt_prefix = " ",
				modes = { "n", "i", "c", "x", "o", "t" },
				show_plug = false, -- do not show mappings with "<Plug>"
				lhs_filter = function(lhs) return not lhs:find("Þ") end, -- remove which-key mappings
			},
			diagnostics = { prompt_prefix = "󰒕 ", no_sign = true },
			treesitter = { prompt_prefix = " ", show_line = false },
			highlights = {
				prompt_prefix = " ",
				layout_config = {
					horizontal = { preview_width = { 0.7, min = 30 } },
				},
			},
			find_files = {
				prompt_prefix = "󰝰 ",
				-- using the default find command from telescope is somewhat buggy,
				-- e.g. not respecting fd/ignore
				find_command = { "fd", "--hidden", "--follow", "--type=file", "--type=symlink" },
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
				ignore_symbols = { "boolean", "number", "string" },
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
				previewer = false,
				layout_config = {
					horizontal = { width = 0.4, height = 0.5 },
				},
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
				prompt_prefix = "󰕌 ",
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
			recent_files = {
				prompt_prefix = "󰋚 ",
				previewer = false,
				layout_config = {
					horizontal = {
						-- anchor = "W",
						width = 0.45,
						height = 0.5,
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
			"smartpde/telescope-recent-files", -- better oldfiles
			"debugloop/telescope-undo.nvim", -- undotree

			-- also listed here as dependency, so it can be used by telescope
			-- before cmp is loaded
			"nvim-telescope/telescope-fzf-native.nvim", -- better fuzzy finder
		},

		config = function()
			telescopeConfig()
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
