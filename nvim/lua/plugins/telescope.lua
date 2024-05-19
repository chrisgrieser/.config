local u = require("config.utils")
local telescope = vim.cmd.Telescope

local function projectName() return vim.fs.basename(vim.uv.cwd() or "") end

local function copyValue(prompt_bufnr)
	local value = require("telescope.actions.state").get_selected_entry().value
	require("telescope.actions").close(prompt_bufnr)
	u.copyAndNotify(value)
end
--------------------------------------------------------------------------------

local keymappings_I = {
	["?"] = "which_key",
	["<Tab>"] = "move_selection_worse",
	["<D-up>"] = "move_to_top",
	["<D-down>"] = "move_to_bottom",
	["<S-Tab>"] = "move_selection_better",
	["<CR>"] = "select_default",
	["<Esc>"] = "close",

	["<C-v>"] = "select_vertical",
	["<C-s>"] = "select_horizontal",
	["<PageDown>"] = "preview_scrolling_down",
	["<PageUp>"] = "preview_scrolling_up",
	["<Up>"] = "cycle_history_prev",
	["<Down>"] = "cycle_history_next",
	["<D-a>"] = "toggle_all",

	["<M-CR>"] = { -- mapping consistent with fzf-multi-select
		function(prompt_bufnr)
			require("telescope.actions").toggle_selection(prompt_bufnr)
			require("telescope.actions").move_selection_worse(prompt_bufnr)
		end,
		type = "action",
		opts = { desc = "󰒆 Multi-Select" },
	},

	["<D-u>"] = {
		function(prompt_bufnr)
			local current_picker = require("telescope.actions.state").get_current_picker(prompt_bufnr)
			local cwd = tostring(current_picker.cwd or vim.uv.cwd()) -- cwd only set if passed as opt
			local parent_dir = vim.fs.dirname(cwd)

			require("telescope.actions").close(prompt_bufnr)
			require("telescope.builtin").find_files {
				prompt_title = vim.fs.basename(parent_dir),
				cwd = parent_dir,
			}
		end,
		type = "action",
		opts = { desc = " cwd up" },
	},
	["<D-s>"] = {
		function(prompt_bufnr)
			require("telescope.actions").smart_send_to_qflist(prompt_bufnr)
			vim.cmd.cfirst()
		end,
		type = "action",
		opts = { desc = " Send to Quickfix" },
	},
	["<D-p>"] = {
		function(prompt_bufnr) require("telescope.actions.layout").cycle_layout_next(prompt_bufnr) end,
		type = "action",
		opts = { desc = " Toggle Preview" },
	},

	["<C-t>"] = { copyValue, type = "action", opts = { desc = "󰅍 Copy relative path" } },
	["<C-c>"] = { copyValue, type = "action", opts = { desc = "󰅍 Copy value" } },
	["<D-l>"] = {
		function(prompt_bufnr)
			local path = require("telescope.actions.state").get_selected_entry().value
			require("telescope.actions").close(prompt_bufnr)
			vim.system { "open", "-R", path }
		end,
		type = "action",
		opts = { desc = "󰀶 Reveal File" },
	},
	["<C-p>"] = {
		function(prompt_bufnr)
			local relPath = require("telescope.actions.state").get_selected_entry().value
			local current_picker = require("telescope.actions.state").get_current_picker(prompt_bufnr)
			local cwd = tostring(current_picker.cwd or vim.uv.cwd()) -- cwd only set if passed as opt
			local fullpath = cwd .. "/" .. relPath
			require("telescope.actions").close(prompt_bufnr)
			u.copyAndNotify(fullpath)
		end,
		type = "action",
		opts = { desc = "󰅍 Copy absolute path" },
	},
	["<C-n>"] = {
		function(prompt_bufnr)
			local relPath = require("telescope.actions.state").get_selected_entry().value
			require("telescope.actions").close(prompt_bufnr)
			u.copyAndNotify(vim.fs.basename(relPath))
		end,
		type = "action",
		opts = { desc = "󰅍 Copy filename" },
	},
}

-- add j/k/q to mappings if normal mode
local keymappings_N = vim.tbl_extend("force", keymappings_I, {
	["j"] = "move_selection_worse",
	["k"] = "move_selection_better",
	["q"] = {
		-- extra stuff needed to be able to set `nowait` for `q`
		function(prompt_bufnr) require("telescope.actions").close(prompt_bufnr) end,
		type = "action",
		opts = { nowait = true, desc = "close" },
	},
})

local toggleHiddenAction = {
	function(prompt_bufnr)
		local current_picker = require("telescope.actions.state").get_current_picker(prompt_bufnr)
		local cwd = tostring(current_picker.cwd or vim.uv.cwd()) -- cwd only set if passed as opt

		-- hidden status not stored, but title is, so we determine the previous state via title
		local prevTitle = current_picker.prompt_title
		local ignoreHidden = not prevTitle:find("hidden")

		local title = "Find Files: " .. vim.fs.basename(cwd)
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
		-- stylua: ignore
		file_ignore_patterns = {
			"node_modules", ".venv", "typings", "%.DS_Store$", "%.git/", "%.app/",
			unpack(existingFileIgnores), -- must be last for all items to be unpacked
		},
		}
	end,
	type = "action",
	opts = { desc = "󰈉 Toggle hidden" },
}

-- FILETYPE-SPECIFIC SYMBOL-SEARCH
-- (mostly for filetypes that do not know functions)
-- Also, we are using document symbols here since Treesitter apparently does not
-- support symbols for these filetypes.
vim.api.nvim_create_autocmd("FileType", {
	callback = function(ctx)
		local ft = ctx.match
		-- special keymaps in ftplugins
		if ft == "markdown" or ft == "bib" then return end

		local symbolFilter = {
			yaml = { "object", "array" },
			json = "module",
			toml = "object",
		}
		local filter = symbolFilter[ft]
		local desc, symbolSearch

		if filter then
			symbolSearch = function()
				require("telescope.builtin").lsp_document_symbols {
					prompt_prefix = "󰒕 ",
					symbols = filter,
				}
			end
			desc = " Sections"
		elseif ft == "lua" then
			-- in lua, use treesitter, since it skips anonymous functions
			symbolSearch = function()
				require("telescope.builtin").treesitter {
					show_line = false,
					prompt_prefix = " ",
					symbols = { "function", "method", "class", "struct" },
					symbol_highlights = { ["function"] = "Function", ["method"] = "@method" },
				}
			end
			desc = " Symbols"
		else
			symbolSearch = function()
				require("telescope.builtin").lsp_document_symbols {
					prompt_prefix = "󰒕 ",
					-- stylua: ignore
					ignore_symbols = {
						"variable", "constant", "number", "package", "string",
						"object", "array", "boolean", "property",
					},
				}
			end
			desc = "󰒕 Symbols"
		end
		vim.keymap.set("n", "gs", symbolSearch, { desc = desc, buffer = ctx.buf })
	end,
})

--------------------------------------------------------------------------------

local function telescopeConfig()
	local borderChars = { "─", "│", "─", "│", "┌", "┐", "┘", "└" }
	if vim.g.borderStyle == "double" then
		borderChars = { "═", "║", "═", "║", "╔", "╗", "╝", "╚" }
	end
	if vim.g.borderStyle == "rounded" then
		borderChars = { "─", "│", "─", "│", "╭", "╮", "╯", "╰" }
	end

	local smallLayout = { horizontal = { width = 0.6, height = 0.6 } }

	require("telescope").setup {
		defaults = {
			path_display = { "tail" },
			history = { path = vim.g.syncedData .. "/telescope_history" },
			selection_caret = "󰜋 ",
			multi_icon = "󰒆 ",
			results_title = false,
			dynamic_preview_title = true,
			preview = { timeout = 400, filesize_limit = 1 }, -- ms & Mb
			borderchars = borderChars,
			default_mappings = { i = keymappings_I, n = keymappings_N },
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
				("--ignore-file=" .. os.getenv("HOME") .. "/.config/rg/ignore"),
			},
			-- stylua: ignore
			file_ignore_patterns = {
				"%.png$", "%.svg", "%.gif", "%.icns", "%.jpe?g", -- images
				"%.zip", "%.pdf", -- misc
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
						["<C-h>"] = toggleHiddenAction,
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

				-- use small layout, toggle via <D-p>
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
					i = {
						["<CR>"] = {
							function(prompt_bufnr)
								local hlName = require("telescope.actions.state").get_selected_entry().value
								require("telescope.actions").close(prompt_bufnr)
								local value = vim.api.nvim_get_hl(0, { name = hlName })
								local out = {}
								if value.fg then table.insert(out, ("#%06x"):format(value.fg)) end
								if value.bg then table.insert(out, ("#%06x"):format(value.bg)) end
								u.copyAndNotify(table.concat(out, "\n"))
							end,
							type = "action",
							opts = { desc = " Copy Value" },
						},
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
				prompt_prefix = "󰈿 ",
				trim_text = true,
				show_line = false,
				initial_mode = "normal",
				layout_config = { horizontal = { preview_width = { 0.7, min = 30 } } },
			},
			lsp_dynamic_workspace_symbols = { -- dynamic = updates results on typing
				prompt_prefix = "󰒕 ",
				fname_width = 0, -- can see name in preview title
				symbol_width = 30,
				file_ignore_patterns = {
					"node_modules",
					".local", -- nvim runtime
					"homebrew", -- nvim runtime
					"typings", -- pyright types
					".venv", -- python
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
			{ "gD", function() telescope("lsp_type_definitions") end, desc = "󰈿 Type Definitions" },
			{ "gf", function() telescope("lsp_references") end, desc = "󰈿 References" },
			{ "<leader>ph", function() telescope("highlights") end, desc = " Highlights" },
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
					require("telescope.builtin").live_grep {
						prompt_title = "Live Grep: " .. projectName(),
					}
				end,
				desc = " Live-Grep",
			},
			{
				"gL",
				function()
					local word
					if vim.fn.mode() == "n" then
						word = vim.fn.expand("<cword>")
					else
						u.normal('"zy')
						word = vim.trim(vim.fn.getreg("z"))
					end
					require("telescope.builtin").live_grep {
						default_text = word,
						prompt_title = "Live Grep: " .. projectName(),
					}
				end,
				desc = " Grep cword",
			},
			{
				"<leader>pc",
				function()
					-- HACK remove built-in colorschemes from selection
					-- stylua: ignore
					local builtins = {
						"zellner", "torte", "slate", "shine", "ron", "quiet", "peachpuff",
						"pablo", "murphy", "lunaperche", "koehler", "industry", "evening",
						"elflord", "desert", "delek", "darkblue", "blue", "morning", "vim",
						"habamax", "retrobox", "sorbet", "zaibatsu", "wildcharm"
					}
					local original = vim.fn.getcompletion

					---@diagnostic disable-next-line: duplicate-set-field
					vim.fn.getcompletion = function()
						return vim.tbl_filter(
							function(color) return not vim.tbl_contains(builtins, color) end,
							original("", "color")
						)
					end

					telescope("colorscheme")
				end,
				desc = " Colorschemes",
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
