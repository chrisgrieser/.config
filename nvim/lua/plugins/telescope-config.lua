local keymaps = require("funcs.telescope-keymaps")
local telescope = vim.cmd.Telescope
local function projectName() return vim.fs.basename(vim.uv.cwd() or "") end
--------------------------------------------------------------------------------

local borderChars = { "─", "│", "─", "│", "┌", "┐", "┘", "└" }
if vim.g.borderStyle == "double" then
	borderChars = { "═", "║", "═", "║", "╔", "╗", "╝", "╚" }
end
if vim.g.borderStyle == "rounded" then
	borderChars = { "─", "│", "─", "│", "╭", "╮", "╯", "╰" }
end

local smallLayout = { horizontal = { width = 0.6, height = 0.6 } }

vim.api.nvim_create_autocmd("FileType", {
	pattern = "TelescopePrompt",
	callback = function()
		vim.opt_local.sidescrolloff = 1
		vim.opt_local.list = true
	end,
})

--------------------------------------------------------------------------------

local function telescopeConfig()
	require("telescope").setup {
		defaults = {
			path_display = { "tail" },
			selection_caret = "󰜋 ",
			multi_icon = "󰒆 ",
			results_title = false,
			prompt_title = false,
			dynamic_preview_title = true,
			preview = { timeout = 400, filesize_limit = 1 }, -- ms & Mb
			borderchars = borderChars,
			default_mappings = { i = keymaps.insertMode, n = keymaps.normalMode },
			cycle_layout_list = {
				"horizontal",
				{ previewer = false, layout_strategy = "horizontal", layout_config = smallLayout },
			},
			layout_strategy = "horizontal",
			sorting_strategy = "ascending", -- so layout is consistent with prompt_position "top"
			layout_config = {
				horizontal = {
					prompt_position = "top",
					height = { 0.6, min = 13 },
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
				("--ignore-file=" .. vim.fs.normalize("~/.config/rg/ignore")),
			},
			-- stylua: ignore
			file_ignore_patterns = {
				-- filetypes
				"%.png$", "%.svg", "%.gif", "%.icns", "%.jpe?g",
				"%.zip", "%.pdf",
				-- special directories
				"%.git/",
				"%.DS_Store$", "%.app/", -- macOS apps
				".local", "homebrew", -- nvim runtime
				".venv", -- python
				"EmmyLua.spoon", -- Hammerspoon
			},
		},
		pickers = {
			find_files = {
				prompt_prefix = "󰝰 ",
				path_display = { "filename_first" },
				-- FIX telescope not respecting `~/.config/fd/ignore`
				find_command = { "fd", "--type=file", "--type=symlink" },
				mappings = {
					i = {
						["<C-h>"] = keymaps.toggleHidden,
					},
				},

				-- use small layout, toggle via <D-p>
				layout_config = smallLayout,
				previewer = false,
			},
			oldfiles = {
				prompt_prefix = "󰋚 ",
				path_display = function(_, path)
					local project = path
						:gsub(vim.pesc(vim.g.localRepos), "") -- root in localRepo root
						:gsub("/Users/%w+", "") -- remove home dir
						:match("/(.-)/") -- highest parent
					local tail = require("telescope.utils").path_tail(path)
					local text = tail .. "  " .. project

					local highlights = { { { #tail + 1, #text }, "TelescopeResultsComment" } }
					return text, highlights
				end,
				file_ignore_patterns = { "%.log", "%.plist$", "COMMIT_EDITMSG" },

				layout_config = smallLayout,
				previewer = false,
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
				file_ignore_patterns = {}, -- do not ignore images etc here
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
				-- add commit time (%cr) & `--all`
				git_command = { "git", "log", "--all", "--pretty=%h %s %cr", "--", "." },
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
					},
				},
			},
			git_bcommits = {
				prompt_prefix = "󰊢 ",
				layout_config = { horizontal = { height = 0.99 } },
				git_command = { "git", "log", "--pretty=%h %s %cr" }, -- add commit time (%cr)
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
				layout_config = { horizontal = { preview_width = { 0.7, min = 20 } } },
				mappings = {
					i = { ["<CR>"] = keymaps.copyColorValue },
				},
			},
			lsp_references = {
				prompt_prefix = "󰈿 ",
				trim_text = true,
				show_line = false,
				include_declaration = false,
				include_current_line = false,
				initial_mode = "normal",
				layout_config = { horizontal = { preview_width = { 0.7, min = 30 } } },
			},
			lsp_definitions = {
				prompt_prefix = "󰈿 ",
				trim_text = true,
				show_line = false,
				initial_mode = "normal",
				layout_config = { horizontal = { preview_width = { 0.7, min = 30 } } },
			},
			lsp_type_definitions = {
				prompt_prefix = "󰜁 ",
				trim_text = true,
				show_line = false,
				initial_mode = "normal",
				layout_config = { horizontal = { preview_width = { 0.7, min = 30 } } },
			},
			lsp_dynamic_workspace_symbols = { -- `dynamic` = updates results on typing
				prompt_prefix = "󰒕 ",
				fname_width = 0, -- can see name in preview title already
				symbol_width = 30,
				file_ignore_patterns = { "node_modules", "typings" },
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
				ignore_builtins = true,
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
			{ "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
		},
		config = function()
			telescopeConfig()
			require("telescope").load_extension("fzf")
		end,
		keys = {
			{ "?", function() telescope("keymaps") end, desc = "⌨️ Search Keymaps" },
			{ "g.", function() telescope("resume") end, desc = " Continue" },
			{
				"gw",
				function() telescope("lsp_dynamic_workspace_symbols") end,
				desc = "󰒕 Workspace Symbols",
			},
			{ "gd", function() telescope("lsp_definitions") end, desc = "󰈿 Definitions" },
			{ "gD", function() telescope("lsp_type_definitions") end, desc = "󰜁 Type Definitions" },
			{ "gf", function() telescope("lsp_references") end, desc = "󰈿 References" },
			{ "<leader>ph", function() telescope("highlights") end, desc = " Search Highlights" },
			{ "<leader>gs", function() telescope("git_status") end, desc = " Status" },
			{ "<leader>gl", function() telescope("git_commits") end, desc = " Log" },
			{ "<leader>gL", function() telescope("git_bcommits") end, desc = " Buffer Commits" },
			{ "<leader>gb", function() telescope("git_branches") end, desc = " Branches" },
			{ "zl", function() telescope("spell_suggest") end, desc = "󰓆 Spell Suggest" },
			{
				"go",
				function()
					-- SOURCE https://github.com/nvim-telescope/telescope.nvim/issues/2905
					local scorer = require("telescope").extensions["fzf"].native_fzf_sorter()
					local mySorter = {}
					setmetatable(mySorter, { __index = scorer })
					local curBufRelPath = vim.api.nvim_buf_get_name(0):sub(#vim.uv.cwd() + 2)

					---@param prompt string
					---@param relPath string the ordinal from telescope
					---@return number score number from 1 to 0. lower the number the better. -1 will filter out the entry though.
					function mySorter:scoring_function(prompt, relPath)
						-- only modify score when prompt is empty
						if prompt ~= "" then return scorer.scoring_function(self, prompt, relPath) end
						-- put current buffer to the bottom
						if relPath == curBufRelPath then return 1 end

						-- prioritze recently modified
						local stat = vim.uv.fs_stat(relPath)
						if not stat then return 1 end
						local now = os.time()
						local ageYears = (now - stat.mtime.sec) / 60 / 60 / 24 / 365
						return math.min(ageYears, 1)
					end

					require("telescope.builtin").find_files {
						prompt_title = "Find Files: " .. projectName(),
						sorter = mySorter,
					}
				end,
				desc = " Open File",
			},
			{
				"gr",
				function()
					-- HACK add open buffers to oldfiles
					local openBufs = vim.iter(vim.fn.getbufinfo { buflisted = 1 })
						:map(function(buf) return buf.name end)
						:totable()
					vim.list_extend(vim.v.oldfiles, openBufs)
					telescope("oldfiles")
				end,
				desc = " Recent Files",
			},
			{
				"gl",
				function()
					require("telescope.builtin").live_grep {
						prompt_title = "Live Grep: " .. projectName(),
					}
				end,
				desc = " Live-Grep",
			},
			{
				"gL",
				function()
					require("telescope.builtin").live_grep {
						default_text = vim.fn.expand("<cword>"),
						prompt_title = "Live Grep: " .. projectName(),
					}
				end,
				desc = " Grep cword",
			},
			{
				"gL",
				function()
					require("config.utils").normal('"zy')
					local sel = vim.trim(vim.fn.getreg("z"))
					require("telescope.builtin").live_grep {
						default_text = sel,
						prompt_title = "Live Grep: " .. projectName(),
					}
				end,
				mode = "x",
				desc = " Grep selection",
			},
			{
				"<leader>pc",
				function()
					-- PENDING https://github.com/nvim-telescope/telescope.nvim/pull/3155
					-- HACK remove built-in colorschemes from selection
					-- stylua: ignore
					local builtins = {
						"zellner", "torte", "slate", "shine", "ron", "quiet", "peachpuff",
						"pablo", "murphy", "lunaperche", "koehler", "industry", "evening",
						"elflord", "desert", "delek", "darkblue", "blue", "morning", "vim",
						"habamax", "retrobox", "sorbet", "zaibatsu", "wildcharm"
					}
					local originalFunc = vim.fn.getcompletion

					vim.fn.getcompletion = function() ---@diagnostic disable-line: duplicate-set-field
						return vim.tbl_filter(
							function(color) return not vim.tbl_contains(builtins, color) end,
							originalFunc("", "color")
						)
					end

					telescope("colorscheme")
				end,
				desc = " Preview Colorschemes",
			},
		},
	},
	{ -- Icon Picker
		"nvim-telescope/telescope-symbols.nvim",
		dependencies = "nvim-telescope/telescope.nvim",
		keys = {
			{
				"<C-.>",
				mode = { "n", "i" },
				function()
					require("telescope.builtin").symbols {
						sources = { "nerd", "math", "emoji" },
						layout_config = { horizontal = { width = 0.35 } },
					}
				end,
				desc = " Icon Picker",
			},
		},
	},
}
