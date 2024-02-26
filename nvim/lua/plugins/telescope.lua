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
	["<D-s>"] = function(prompt_bufnr) -- sends selected, or if none selected, sends all
		require("telescope.actions").smart_send_to_qflist(prompt_bufnr)
		vim.cmd.cfirst()
	end,
	["<D-S>"] = "add_selected_to_qflist", -- appends to quickfix list
	["<M-CR>"] = function(prompt_bufnr) -- mapping consistent with fzf-multi-select
		require("telescope.actions").toggle_selection(prompt_bufnr)
		require("telescope.actions").move_selection_worse(prompt_bufnr)
	end,
	-- Reveal File in macOS Finder
	["<D-l>"] = function(prompt_bufnr)
		local path = require("telescope.actions.state").get_selected_entry().value
		require("telescope.actions").close(prompt_bufnr)
		vim.fn.system { "open", "-R", path }
	end,
	-- Copy path of file -- https://github.com/nvim-telescope/telescope-file-browser.nvim/issues/191
	["<C-p>"] = function(prompt_bufnr)
		local current_picker = require("telescope.actions.state").get_current_picker(prompt_bufnr)
		local cwd = tostring(current_picker.cwd or vim.loop.cwd()) -- cwd only set if passed as opt
		local relPath = require("telescope.actions.state").get_selected_entry().value
		local fullpath = cwd .. "/" .. relPath
		require("telescope.actions").close(prompt_bufnr)
		vim.fn.setreg("+", fullpath)
		u.notify("Copied", fullpath)
	end,
	-- Copy name of file
	["<C-n>"] = function(prompt_bufnr)
		local relPath = require("telescope.actions.state").get_selected_entry().value
		local name = vim.fs.basename(relPath)
		require("telescope.actions").close(prompt_bufnr)
		vim.fn.setreg("+", name)
		u.notify("Copied", name)
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

-- toggle `--hidden` & `--no-ignore` for the `find_files` picker
local function toggleHiddenAndIgnore(prompt_bufnr)
	local current_picker = require("telescope.actions.state").get_current_picker(prompt_bufnr)
	local cwd = tostring(current_picker.cwd or vim.loop.cwd()) -- cwd only set if passed as opt

	-- hidden status not stored, but title is, so we determine the previous state via title
	local prevTitle = current_picker.prompt_title
	local ignoreHidden = not prevTitle:find("hidden")

	local title = vim.fs.basename(cwd)
	if ignoreHidden then title = title .. " (--hidden --no-ignore)" end
	local currentQuery = require("telescope.actions.state").get_current_line()
	local existingFileIgnores = require("telescope.config").values.file_ignore_patterns or {}

	require("telescope.actions").close(prompt_bufnr)
	require("telescope.builtin").find_files {
		default_text = currentQuery,
		prompt_title = title,
		hidden = ignoreHidden,
		no_ignore = ignoreHidden,
		cwd = cwd,
		-- prevent these becoming visible through `--no-ignore`
		file_ignore_patterns = {
			"node_modules",
			".venv",
			"%.DS_Store$",
			"%.git/",
			"%.app/",
			unpack(existingFileIgnores), -- must be last for all items to be unpacked
		},
	}
end

--------------------------------------------------------------------------------
-- Nicer Display of file paths https://github.com/nvim-telescope/telescope.nvim/issues/2014

-- color parent as comment
vim.api.nvim_create_autocmd("FileType", {
	pattern = "TelescopeResults",
	callback = function(ctx)
		vim.api.nvim_buf_call(ctx.buf, function() vim.fn.matchadd("Comment", "\t\t.*$") end)
	end,
})

---@param path string
---@return string
local function filenameFirst(_, path)
	local tail = vim.fs.basename(path)
	local parent = vim.fs.dirname(path)
	if parent == "." then return tail end
	local parentDisplay = #parent > 25 and vim.fs.basename(parent) or parent
	return string.format("%s\t\t%s", tail, parentDisplay) -- parent colored via autocmd above
end

local function project() return vim.fs.basename(vim.loop.cwd() or "") end

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
			function() require("telescope.builtin").lsp_document_symbols { symbols = symbolFilter[ft] } end,
			{ desc = " Sections", buffer = true }
		)
	end,
})

--------------------------------------------------------------------------------

local function telescopeConfig()
	require("telescope").setup {
		defaults = {
			path_display = { "tail" },
			history = { path = vim.g.syncedData .. "/telescope_history" },
			selection_caret = "󰜋 ",
			multi_icon = "󰒆 ",
			results_title = false,
			dynamic_preview_title = true,
			preview = { timeout = 400, filesize_limit = 1 }, -- ms & Mb
			borderchars = { "─", "│", "─", "│", "┌", "┐", "┘", "└" },
			-- { "═", "║", "═", "║", "╔", "╗", "╝", "╚" }
			-- { "─", "│", "─", "│", "╭", "╮", "╯", "╰" }
			default_mappings = { i = keymappings_I, n = keymappings_N },
			layout_strategy = "horizontal",
			sorting_strategy = "ascending", -- so layout is consistent with prompt_position "top"
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
			vimgrep_arguments = {
				"rg",
				"--vimgrep",
				"--smart-case",
				"--trim",
				-- inherit global ignore file from `fd`
				("--ignore-file=" .. os.getenv("HOME") .. "/.config/fd/ignore"),
			},
			file_ignore_patterns = { "%.png$", "%.svg", "%.gif", "%.zip" },
		},
		pickers = {
			find_files = {
				prompt_prefix = "󰝰 ",
				path_display = filenameFirst,
				-- prioritze recently modified
				tiebreak = function(a, b, _)
					local a_stats = vim.loop.fs_stat(a.ordinal)
					local b_stats = vim.loop.fs_stat(b.ordinal)
					if not (a_stats and b_stats) then return false end
					return a_stats.mtime.sec > b_stats.mtime.sec
				end,
				-- FIX using the default fd command from telescope is somewhat buggy,
				-- e.g. not respecting `~/.config/fd/ignore`
				find_command = { "fd", "--type=file", "--type=symlink" },
				mappings = {
					i = {
						["<C-h>"] = toggleHiddenAndIgnore,
						-- automatically toggle hidden files when entering `.`
						["."] = function(prompt_bufnr)
							vim.api.nvim_feedkeys(".", "n", true)
							toggleHiddenAndIgnore(prompt_bufnr)
						end,
					},
				},
				follow = false,
			},
			oldfiles = {
				prompt_prefix = "󰋚 ",
				path_display = filenameFirst,
				file_ignore_patterns = { "%.log", "%.plist$", "COMMIT_EDITMSG" },
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
			git_status = {
				prompt_prefix = "󰊢 ",
				initial_mode = "normal",
				show_untracked = true,
				mappings = {
					n = {
						["<Tab>"] = "move_selection_worse",
						["<S-Tab>"] = "move_selection_better",
						["<CR>"] = "git_staging_toggle",
						["<D-CR>"] = "select_default", -- opens file
					},
				},
				layout_strategy = "vertical",
				preview_title = "Unstaged Files",
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
					dyn_title = function(_, entry) return entry.value end, -- hash as title
					get_command = function(entry, status)
						local hash = entry.value
						local previewWidth = vim.api.nvim_win_get_width(status.preview_win)
						local statArgs = ("%s,%s,25"):format(previewWidth, math.floor(previewWidth / 2))
						local previewFormat =
							"%C(bold)%C(magenta)%s %n%C(reset)%C(cyan)%D%C(reset)%n%b%n%C(blue)%an %C(yellow)(%ch) %C(reset)"
						local cmd = {
							"git show " .. hash,
							"--color=always",
							"--stat=" .. statArgs,
							("--format=%q"):format(previewFormat),
							"| sed -e 's/^ //' -e '$d' ;", -- remove clutter
						}
						return table.concat(cmd, " ")
					end,
				},
				mappings = {
					i = {
						["<C-r>"] = "git_reset_soft",
						["<C-h>"] = function(prompt_bufnr)
							local hash = require("telescope.actions.state").get_selected_entry().value
							require("telescope.actions").close(prompt_bufnr)
							vim.fn.setreg("+", hash)
							u.notify("Hash Copied", hash)
						end,
					},
				},
			},
			git_bcommits = {
				prompt_prefix = "󰊢 ",
				layout_config = { horizontal = { height = 0.99 } },
				git_command = { "git", "log", "--pretty=%h %s\t%cr" }, -- add commit time (%cr)
			},
			git_branches = {
				prompt_prefix = " ",
				show_remote_tracking_branches = true,
				initial_mode = "normal",
				previewer = false,
				layout_config = { horizontal = { height = 0.4, width = 0.7 } },
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
							local hlName = require("telescope.actions.state").get_selected_entry().value
							require("telescope.actions").close(prompt_bufnr)
							local value = vim.api.nvim_get_hl(0, { name = hlName })
							local out = { hlName }
							if value.fg then table.insert(out, ("#%06x"):format(value.fg)) end
							if value.bg then table.insert(out, ("#%06x"):format(value.bg)) end
							local str = table.concat(out, "\n")
							vim.fn.setreg("+", str)
							u.notify("Copied", str)
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
			lsp_type_definitions = {
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
				prompt_title = "Symbols",
				show_line = false,
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
					["string"] = "Comment",
				},
			},
			lsp_workspace_symbols = {
				prompt_prefix = "󰒕 ",
				fname_width = 0, -- can see name in preview title
				symbol_width = 30,
				ignore_symbols = { "variable", "constant", "property" },
				file_ignore_patterns = {
					"node_modules", -- ts/js
					".local", -- neodev.nvim
					"homebrew", -- nvim runtime
					"EmmyLua.spoon", -- Hammerspoon
				},
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
			-- insert at cursor instead (relevant for lua)
			import = { insert_at_top = false },
		},
	}
end

--------------------------------------------------------------------------------
return {
	{ -- fuzzy finder
		"nvim-telescope/telescope.nvim",
		cmd = "Telescope",
		external_dependencies = { "fd", "rg" },
		dependencies = {
			"nvim-lua/plenary.nvim",
			"nvim-tree/nvim-web-devicons",
			"natecraddock/telescope-zf-native.nvim",
		},
		config = function()
			telescopeConfig()
			require("telescope").load_extension("zf-native")
		end,
		keys = {
			{ "?", function() telescope("keymaps") end, desc = "⌨️ Search Keymaps" },
			{ "g.", function() telescope("resume") end, desc = " Continue" },
			{ "gs", function() telescope("treesitter") end, desc = " Symbols" },
			-- stylua: ignore
			{ "gw", function() telescope("lsp_workspace_symbols") end, desc = "󰒕 Workspace Symbols" },
			{ "gd", function() telescope("lsp_definitions") end, desc = "󰒕 Definitions" },
			{ "gD", function() telescope("lsp_type_definitions") end, desc = "󰒕 Type Definitions" },
			{ "gf", function() telescope("lsp_references") end, desc = "󰒕 References" },
			{ "<leader>ph", function() telescope("highlights") end, desc = " Highlights" },
			{ "<leader>pc", function() telescope("colorscheme") end, desc = " Colorschemes" },
			{ "<leader>gs", function() telescope("git_status") end, desc = " Status" },
			{ "<leader>gl", function() telescope("git_commits") end, desc = " Log" },
			{ "<leader>gL", function() telescope("git_bcommits") end, desc = " Buffer Commits" },
			{ "<leader>gb", function() telescope("git_branches") end, desc = " Branches" },
			{ "zl", function() telescope("spell_suggest") end, desc = "󰓆 Spell Suggest" },
			{
				"go",
				function()
					-- SOURCE https://github.com/nvim-telescope/telescope.nvim/issues/2905
					local scorer = require("telescope").extensions["zf-native"].native_zf_scorer()
					local my_fzf = {}
					setmetatable(my_fzf, { __index = scorer })
					local curBufRelPath = vim.api.nvim_buf_get_name(0):sub(#vim.loop.cwd() + 2)

					---@param prompt string
					---@param relPath string the ordinal from telescope
					---@return number score number from 1 to 0. lower the number the better. -1 will filter out the entry though.
					function my_fzf:scoring_function(prompt, relPath)
						-- only modify score when prompt is empty
						if prompt ~= "" then return scorer.scoring_function(self, prompt, relPath) end
						-- filter out current buffer
						if relPath == curBufRelPath then return -1 end

						-- prioritze recently modified
						local stat = vim.loop.fs_stat(relPath)
						if not stat then return 1 end
						local now = os.time()
						local ageYears = (now - stat.mtime.sec) / 60 / 60 / 24 / 365
						return math.min(ageYears, 1)
					end

					require("telescope.builtin").find_files {
						prompt_title = "Find Files: " .. project(),
						sorter = my_fzf,
					}
				end,
				desc = " Open File",
			},
			{
				"gr",
				function()
					-- HACK add buffers to oldfiles
					local listedBufs = vim.fn.getbufinfo { buflisted = 1 }
					local bufPaths = vim.tbl_map(function(buf) return buf.name end, listedBufs)
					vim.list_extend(vim.v.oldfiles, bufPaths)
					telescope("oldfiles")
				end,
				desc = " Recent Files",
			},
			{
				"gl",
				function()
					require("telescope.builtin").live_grep { prompt_title = "Live Grep: " .. project() }
				end,
				desc = " Live-Grep",
			},
			{
				"gL",
				function()
					require("telescope.builtin").live_grep {
						default_text = vim.fn.expand("<cword>"),
						prompt_title = "Live Grep: " .. project(),
					}
				end,
				desc = " Grep cword",
			},
		},
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
	{ -- Add imports
		"piersolenski/telescope-import.nvim",
		dependencies = "nvim-telescope/telescope.nvim",
		external_dependencies = "rg",
		keys = {
			{ "<leader>ci", function() telescope("import") end, desc = "󰋺 Add Import" },
		},
		config = function() require("telescope").load_extension("import") end,
	},
}
