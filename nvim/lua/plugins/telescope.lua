local u = require("config.utils")
local telescope = vim.cmd.Telescope

--------------------------------------------------------------------------------
-- MAPPINGS

-- default mappings: https://github.com/nvim-telescope/telescope.nvim/blob/942fe5faef47b21241e970551eba407bc10d9547/lua/telescope/mappings.lua#L133
local keymappings_I = {
	["<Tab>"] = "move_selection_worse",
	["<S-Tab>"] = "move_selection_better",
	["<CR>"] = "select_default",
	["<Esc>"] = "close",
	["<PageDown>"] = "preview_scrolling_down",
	["<PageUp>"] = "preview_scrolling_up",
	["<Up>"] = "cycle_history_prev",
	["<Down>"] = "cycle_history_next",
	["<D-a>"] = "toggle_all",
	["<D-s>"] = function(prompt_bufnr)
		require("telescope.actions").smart_send_to_qflist(prompt_bufnr) -- sends selected, or if none selected, sends all
		vim.cmd.cfirst()
	end,
	["<M-CR>"] = function(prompt_bufnr) -- consistent with fzf-multi-select
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
		local current_picker = require("telescope.actions.state").get_current_picker(prompt_bufnr)
		local cwd = current_picker.cwd and tostring(current_picker.cwd) or vim.loop.cwd()
		local path = require("telescope.actions.state").get_selected_entry().value
		local fullpath = cwd .. "/" .. path
		require("telescope.actions").close(prompt_bufnr)
		vim.fn.setreg("+", fullpath)
		u.notify("Copied", fullpath)
	end,
	["<C-n>"] = function(prompt_bufnr)
		-- Copy name of file -- https://github.com/nvim-telescope/telescope-file-browser.nvim/issues/191
		local path = require("telescope.actions.state").get_selected_entry().value
		local name = vim.fs.basename(path)
		require("telescope.actions").close(prompt_bufnr)
		vim.fn.setreg("+", name)
		u.notify("Copied", name)
	end,
}

-- mappings for `:Telescope find_files`
local hiddenIgnoreActive = false
local findFileMappings = {
	-- toggle `--hidden` & `--no-ignore`
	["<C-h>"] = function(prompt_bufnr)
		local current_picker = require("telescope.actions.state").get_current_picker(prompt_bufnr)
		-- cwd is only set if passed as telescope option
		local cwd = current_picker.cwd and tostring(current_picker.cwd) or vim.loop.cwd()
		hiddenIgnoreActive = not hiddenIgnoreActive
		local title = vim.fs.basename(cwd)
		if hiddenIgnoreActive then title = title .. " (--hidden --no-ignore)" end

		require("telescope.actions").close(prompt_bufnr)
		require("telescope.builtin").find_files {
			prompt_title = title,
			hidden = hiddenIgnoreActive,
			no_ignore = hiddenIgnoreActive,
			cwd = cwd,
			-- prevent these becoming visible through `--no-ignore`
			file_ignore_patterns = {
				"node_modules",
				".venv",
				"%.DS_Store$",
				"%.git/",
			},
		}
	end,
	-- search directory up
	["<D-up>"] = function(prompt_bufnr)
		local current_picker = require("telescope.actions.state").get_current_picker(prompt_bufnr)
		-- cwd is only set if passed as telescope option
		local cwd = current_picker.cwd and tostring(current_picker.cwd) or vim.loop.cwd()
		local parent_dir = vim.fs.dirname(cwd)

		require("telescope.actions").close(prompt_bufnr)
		require("telescope.builtin").find_files {
			prompt_title = vim.fs.basename(parent_dir),
			cwd = parent_dir,
		}
	end,
}

-- add j/k/q to mappings if normal mode
local normalModeOnly = {
	["j"] = "move_selection_worse",
	["k"] = "move_selection_better",
	["q"] = {
		-- extra stuff needed to be able to set `nowait` for `q`
		function(prompt_bufnr) require("telescope.actions").close(prompt_bufnr) end,
		type = "action",
		opts = { nowait = true },
	},
}
local keymappings_N = vim.tbl_extend("force", keymappings_I, normalModeOnly)

--------------------------------------------------------------------------------
-- Better listing of files https://github.com/nvim-telescope/telescope.nvim/issues/2014

-- color parent as comment
vim.api.nvim_create_autocmd("FileType", {
	pattern = "TelescopeResults",
	callback = function(ctx)
		vim.api.nvim_buf_call(ctx.buf, function()
			vim.fn.matchadd("Comment", "\t\t.*$")
			vim.api.nvim_set_hl(0, "TelescopeParent", { link = "Comment" })
		end)
	end,
})

---requires the autocmd above
---@param path string
---@return string
local function filenameFirst(_, path)
	local tail = vim.fs.basename(path)
	local parent = vim.fs.dirname(path)
	if parent == "." then return tail end
	local parentDisplay = #parent > 25 and vim.fs.basename(parent) or parent
	return string.format("%s\t\t%s", tail, parentDisplay) -- parent colored via autocmd above
end

--------------------------------------------------------------------------------

-- Setup filetype-specific symbol-filters for symbol-search
-- (mostly for filetypes that do not know functions)
-- Also, we are using document symbols here since Treesitter apparently does not
-- support symbols for these filetypes.
local symbolFilter = {
	yaml = { "object", "array" },
	json = "module",
	toml = "object",
	markdown = "string", -- = headings
}
vim.api.nvim_create_autocmd("FileType", {
	pattern = vim.tbl_keys(symbolFilter),
	callback = function(ctx)
		local ft = ctx.match
		vim.keymap.set(
			"n",
			"gs",
			function()
				require("telescope.builtin").lsp_document_symbols {
					prompt_title = "Sections",
					symbols = symbolFilter[ft],
				}
			end,
			{ desc = " Sections", buffer = true }
		)
	end,
})

--------------------------------------------------------------------------------

local function telescopeConfig()
	-- color the `M` in `:Telescope git_status`
	u.colorschemeMod("TelescopeResultsDiffChange", { link = "diffChanged" })

	require("telescope").setup {
		defaults = {
			path_display = { "tail" },
			selection_caret = "󰜋 ",
			multi_icon = "󰒆 ",
			results_title = false,
			dynamic_preview_title = true,
			preview = { timeout = 400, filesize_limit = 1 }, -- ms & Mb
			borderchars = { "─", "│", "─", "│", "┌", "┐", "┘", "└" },
			-- { "═", "║", "═", "║", "╔", "╗", "╝", "╚" }
			-- { "─", "│", "─", "│", "╭", "╮", "╯", "╰" }
			default_mappings = { i = keymappings_I, n = keymappings_N },
			sorting_strategy = "ascending", -- so layout is consistent with prompt_position "top"
			layout_strategy = "horizontal",
			layout_config = {
				horizontal = {
					prompt_position = "top",
					height = { 0.75, min = 13 },
					width = 0.99,
					preview_cutoff = 70,
					preview_width = { 0.55, min = 30 },
				},
				vertical = {
					prompt_position = "top",
					mirror = true,
					height = 0.9,
					width = 0.7,
					preview_cutoff = 12,
					preview_height = { 0.4, min = 10 },
					anchor = "S",
				},
			},
			-- stylua: ignore
			-- other ignores are defined via .gitignore, .ignore, /fd/ignore, or /git/ignore
			file_ignore_patterns = {
				"%.png$", "%.gif$", "%.jpe?g$", "%.icns$",
				"%.pdf$", "%.zip$", "%.plist$",
			},
			vimgrep_arguments = {
				"rg",
				"--vimgrep",
				"--smart-case",
				"--trim",
				-- inherit global ignore file from `fd`
				("--ignore-file=" .. os.getenv("HOME") .. "/.config/fd/ignore"),
			},
		},
		pickers = {
			find_files = {
				path_display = filenameFirst,
				prompt_prefix = "󰝰 ",
				-- FIX using the default fd command from telescope is somewhat buggy,
				-- e.g. not respecting `~/.config/fd/ignore`
				find_command = { "fd", "--type=file", "--type=symlink" },
				mappings = { i = findFileMappings },
				follow = false,
			},
			oldfiles = {
				path_display = filenameFirst,
				prompt_prefix = "󰋚 ",
				previewer = false,
				layout_config = {
					horizontal = { anchor = "W", width = 0.5, height = 0.55 },
				},
			},
			live_grep = {
				prompt_prefix = " ",
				disable_coordinates = true,
				layout_config = { horizontal = { preview_width = 0.7 } },
			},
			grep_string = {
				prompt_prefix = " ",
				disable_coordinates = true,
				layout_config = { horizontal = { preview_width = 0.7 } },
			},
			git_status = {
				prompt_prefix = "󰊢 ",
				-- stylua: ignore
				git_icons = { added = "A", changed = "M", copied = "C", deleted = "D", renamed = "R", unmerged = "U", untracked = "?" },
				initial_mode = "normal",
				show_untracked = true,
				mappings = {
					n = {
						["<Tab>"] = "move_selection_worse",
						["<S-Tab>"] = "move_selection_better",
						["<M-CR>"] = "git_staging_toggle",
					},
				},
				layout_strategy = "vertical",
				previewer = require("telescope.previewers").new_termopen_previewer {
					get_command = function(_, status)
						local width = vim.api.nvim_win_get_width(status.preview_win)
						local statArgs = ("%s,%s,25"):format(width, math.floor(width / 2))
						local cmd = {
							"git diff ",
							"--color=always",
							"--compact-summary",
							"--stat=" .. statArgs,
							"| sed -e 's/^ //' -e '$d' ;", -- remove clutter
						}
						return table.concat(cmd, " ")
					end,
				},
			},
			git_commits = {
				prompt_prefix = "󰊢 ",
				initial_mode = "normal",
				prompt_title = "Git Log",
				layout_config = { horizontal = { preview_width = 0.5 } },
				-- add commit time (%cr) & `--all`, double `\t` for highlighting
				git_command = { "git", "log", "--all", "--pretty=%h %s\t\t%cr", "--", "." },
				previewer = require("telescope.previewers").new_termopen_previewer {
					dyn_title = function(_, entry) return entry.value end, -- use hash as title
					get_command = function(entry, status)
						local hash = entry.value
						local previewWinWidth = vim.api.nvim_win_get_width(status.preview_win)
						local statArgs = ("%s,%s,25"):format(
							previewWinWidth,
							math.floor(previewWinWidth / 2)
						)
						local previewFormat =
							"%C(bold)%C(magenta)%s %n%C(reset)%C(cyan)%D%C(reset)%b %n%C(blue)%an %C(yellow)(%ch) %C(reset)"
						local cmd = {
							"git show " .. hash,
							"--color=always",
							"--stat=" .. statArgs,
							"--format='" .. previewFormat .. "'",
							"| sed -e 's/^ //' -e '$d' ;", -- remove clutter
						}
						return table.concat(cmd, " ")
					end,
				},
			},
			git_branches = {
				prompt_prefix = " ",
				show_remote_tracking_branches = true,
				initial_mode = "normal",
				previewer = false,
				layout_config = { horizontal = { height = 0.4, width = 0.6 } },
				mappings = {
					n = {
						["<D-n>"] = "git_create_branch",
						["<C-r>"] = "git_rename_branch",
					},
				},
			},
			keymaps = {
				prompt_prefix = " ",
				modes = { "n", "i", "c", "x", "o", "t" },
				show_plug = false, -- do not show mappings with "<Plug>"
				lhs_filter = function(lhs) return not lhs:find("Þ") end, -- remove which-key mappings
			},
			highlights = {
				prompt_prefix = " ",
				layout_config = {
					horizontal = { preview_width = { 0.7, min = 20 } },
				},
				mappings = {
					i = {
						-- copy value of highlight instead of sending a message
						["<CR>"] = function(prompt_bufnr)
							local highlightName =
								require("telescope.actions.state").get_selected_entry().value
							require("telescope.actions").close(prompt_bufnr)
							vim.fn.setreg("+", highlightName)
							u.notify("Copied", highlightName)
						end,
					},
				},
			},
			lsp_references = {
				prompt_prefix = "󰈿 ",
				trim_text = true,
				show_line = false,
				include_declaration = false,
				include_current_line = false,
				initial_mode = "normal",
				layout_config = {
					horizontal = { preview_width = { 0.7, min = 30 } },
				},
			},
			lsp_definitions = {
				prompt_prefix = "󰈿 ",
				trim_text = true,
				show_line = false,
				initial_mode = "normal",
				layout_config = {
					horizontal = { preview_width = { 0.7, min = 30 } },
				},
			},
			-- using treesitter-symbol search over LSP symbol search, as treesitter
			-- symbol search leaves out anonymous functions
			treesitter = {
				prompt_prefix = " ",
				show_line = false,
				prompt_title = "Symbols",
				symbols = { "function", "class", "method" },
				symbol_highlights = { ["function"] = "Function" },
			},
			lsp_document_symbols = {
				prompt_prefix = "󰒕 ",
				symbols = { "function", "class", "method" },
				symbol_highlights = {
					["module"] = "Comment",
					["array"] = "Comment",
					["object"] = "Comment",
				},
			},
			lsp_workspace_symbols = { -- workspace symbols are not working correctly in lua
				prompt_prefix = "󰒕 ",
				fname_width = 12,
				symbols = { "function", "class", "method" },
			},
			spell_suggest = {
				initial_mode = "normal",
				prompt_prefix = "󰓆",
				previewer = false,
				theme = "cursor",
				layout_config = { cursor = { width = 0.3 } },
			},
			colorscheme = {
				enable_preview = true,
				prompt_prefix = " ",
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
			-- insert at cursor instead, relevant for lua
			import = { insert_at_top = false },
		},
	}
end

--------------------------------------------------------------------------------

return {
	{ -- fuzzy finder
		"nvim-telescope/telescope.nvim",
		cmd = "Telescope",
		keys = {
			{ "?", function() telescope("keymaps") end, desc = "⌨️ Search Keymaps" },
			{ "g.", function() telescope("resume") end, desc = " Continue" },
			{ "gs", function() telescope("treesitter") end, desc = " Symbols" },
			{ "gd", function() telescope("lsp_definitions") end, desc = "󰒕 Definitions" },
			{ "gf", function() telescope("lsp_references") end, desc = "󰒕 References" },
			{
				"gw",
				function() telescope("lsp_workspace_symbols") end,
				desc = "󰒕 Workspace Symbols",
			},
			-- stylua: ignore end

			{ "<leader>ph", function() telescope("highlights") end, desc = " Highlights" },
			{ "<leader>pc", function() telescope("colorscheme") end, desc = " Colorschemes" },
			{ "<leader>gs", function() telescope("git_status") end, desc = " Status" },
			{ "<leader>gl", function() telescope("git_commits") end, desc = " Log" },
			{ "<leader>gb", function() telescope("git_branches") end, desc = " Branches" },
			{ "zl", function() telescope("spell_suggest") end, desc = "󰓆 Spell Suggest" },
			{
				"gr",
				function()
					-- add buffers to oldfiles
					local listedBufs = vim.fn.getbufinfo { buflisted = 1 }
					local bufPaths = vim.tbl_map(function(buf) return buf.name end, listedBufs)
					vim.list_extend(vim.v.oldfiles, bufPaths)
					telescope("oldfiles")
				end,
				desc = " Recent Files",
			},
			{
				"go",
				function()
					require("telescope.builtin").find_files {
						prompt_title = "Find Files: " .. vim.fs.basename(vim.loop.cwd() or ""),
					}
				end,
				desc = " Open File",
			},
			{
				"gl",
				function()
					require("telescope.builtin").live_grep {
						prompt_title = "Live Grep: " .. vim.fs.basename(vim.loop.cwd() or ""),
					}
				end,
				desc = " Live-Grep",
			},
			{ "gL", function() telescope("grep_string") end, desc = " Grep cword" },
		},
		dependencies = { "nvim-lua/plenary.nvim", "nvim-tree/nvim-web-devicons" },
		config = telescopeConfig,
	},
	{ -- Icon Picker
		"nvim-telescope/telescope-symbols.nvim",
		dependencies = "nvim-telescope/telescope.nvim",
		keys = {
			{
				"<D-ö>",
				mode = { "n", "i" },
				function()
					require("telescope.builtin").symbols {
						sources = { "nerd", "math" },
						layout_config = { horizontal = { width = 0.35, height = 0.55 } },
					}
				end,
				desc = " Icon Picker",
			},
		},
	},
	{ -- Add imports (requires `rg`)
		"piersolenski/telescope-import.nvim",
		dependencies = "nvim-telescope/telescope.nvim",
		keys = {
			{ "<leader>ci", function() telescope("import") end, desc = "󰋺 Add Import" },
		},
		config = function() require("telescope").load_extension("import") end,
	},
}
