-- vim: foldlevel=3
-- DOCS https://github.com/folke/snacks.nvim/blob/main/docs/picker.md
--------------------------------------------------------------------------------

-- lightweight version of `telescope-import.nvim`
local function importLuaModule()
	local function import(text) return vim.trim(text:gsub(".-:", "")) end

	require("snacks").picker.grep_word {
		title = "󰢱 Import module",
		cmd = "rg",
		args = { "--only-matching" },
		live = false,
		regex = true,
		search = [[local (\w+) ?= ?require\(["'](.*?)["']\)(\.[\w.]*)?]],
		ft = "lua",

		layout = { preset = "small_no_preview", layout = { width = 0.75 } },
		transform = function(item, ctx) -- ensure items are unique
			ctx.meta.done = ctx.meta.done or {} ---@type table<string, boolean>
			local imp = import(item.text)
			if ctx.meta.done[imp] then return false end
			ctx.meta.done[imp] = true
		end,
		format = function(item, _picker) -- only display the grepped line
			local out = {}
			local line = item.line:gsub("^local ", "")
			require("snacks").picker.highlight.format(item, line, out)
			return out
		end,
		confirm = function(picker, item) -- insert the grepped line below the current one
			picker:close()
			local lnum = vim.api.nvim_win_get_cursor(0)[1]
			assert(lnum)
			vim.api.nvim_buf_set_lines(0, lnum, lnum, false, { import(item.text) })
			vim.cmd.normal { "j==", bang = true }
		end,
	}
end

---@param dir string? defaults to cwd
---@param icon string?
local function betterFileOpen(dir, icon)
	local changedFiles = {}
	local gitDir = require("snacks").git.get_root(dir)
	if gitDir then
		local args = { "git", "-C", gitDir, "status", "--porcelain", "--ignored" }
		local gitStatus = vim.system(args):wait().stdout or ""
		local changes = vim.split(gitStatus, "\n", { trimempty = true })
		changedFiles = vim.iter(changes):fold({}, function(acc, line)
			local relPath = line:sub(4):gsub("^.+ -> ", "") -- gsub for renames
			local absPath = gitDir .. "/" .. relPath
			local change = line:sub(1, 2)
			if change == "??" then change = " A" end -- just nicer highlights for untracked
			acc[absPath] = change
			return acc
		end)
	end

	local currentFile = vim.api.nvim_buf_get_name(0)
	require("snacks").picker.files {
		cwd = dir,
		title = (icon or "") .. " " .. vim.fs.basename(dir or vim.uv.cwd()),
		-- exclude the current file
		transform = function(item, _ctx)
			vim.print(item) -- 🪚
			local itemPath = require("snacks").picker.util.path(item)
			if itemPath == currentFile then return false end
		end,
		-- add git status highlights
		format = function(item, picker)
			local itemPath = require("snacks").picker.util.path(item)
			item.status = changedFiles[itemPath]
			if vim.startswith(item.file, ".") then item.status = "!!" end -- hidden files
			return require("snacks.picker.format").file(item, picker)
		end,
	}
end

local function browseProject()
	local projectsFolder = vim.g.localRepos -- CONFIG

	local function browse(project)
		local path = vim.fs.joinpath(projectsFolder, project)
		require("snacks").picker.files { title = " " .. project, cwd = path }
	end
	local projects = vim.iter(vim.fs.dir(projectsFolder)):fold({}, function(acc, item, type)
		if type == "directory" then table.insert(acc, item) end
		return acc
	end)

	if #projects == 0 then
		vim.notify("No projects found.", vim.log.levels.WARN)
	elseif #projects == 1 then
		browse(projects[1])
	else
		vim.ui.select(projects, { prompt = " Select project" }, function(project)
			if project then browse(project) end
		end)
	end
end

--------------------------------------------------------------------------------

return {
	"folke/snacks.nvim",
	keys = {
		-- FILES
		{ "go", betterFileOpen, desc = " Open files" },
		{ "gt", function() require("snacks").picker.explorer() end, desc = "󰙅 File tree" },
		{ "gP", browseProject, desc = " Project" },

		-- `nowait` due to nvim default mappings starting with `gr`
		{
			"gr",
			function() require("snacks").picker.recent() end,
			desc = "󰋚 Recent files",
			nowait = true,
		},
		{
			"g,",
			function() betterFileOpen(vim.fn.stdpath("config"), "") end,
			desc = " nvim config",
		},
		{
			"g<CR>",
			function() betterFileOpen(os.getenv("HOME") .. "/.config", "") end,
			desc = " dotfiles",
		},
		{
			"gp",
			function()
				require("snacks").picker.files {
					title = "󰈮 Local plugins",
					cwd = vim.fn.stdpath("data") .. "/lazy",
					exclude = { "*/tests/*", "*.toml", "*.tmux", "*.txt" },
					matcher = { filename_bonus = false }, -- folder more important here
					formatters = { file = { filename_first = false } },
				}
			end,
			desc = "󰈮 Local plugins",
		},

		--------------------------------------------------------------------------
		-- GREP

		{ "gl", function() require("snacks").picker.grep() end, desc = "󰛢 Grep" },
		{ "<leader>ci", importLuaModule, ft = "lua", desc = "󰢱 Import module" },

		--------------------------------------------------------------------------
		-- LSP

		{ "gf", function() require("snacks").picker.lsp_references() end, desc = "󰈿 References" },
		{
			"gd",
			function() require("snacks").picker.lsp_definitions() end,
			desc = "󰈿 Definitions",
		},
		{
			"gD",
			function() require("snacks").picker.lsp_type_definitions() end,
			desc = "󰜁 Type definitions",
		},

		-- `lsp_symbols` tends to too much clutter like anonymous function
		{
			"gs",
			function() require("snacks").picker.treesitter() end,
			desc = "󰐅 Treesitter symbols",
		},
		-- treesitter does not work for markdown, so using LSP symbols here
		{
			"gs",
			function() require("snacks").picker.lsp_symbols() end,
			ft = "markdown",
			desc = "󰽛 Headings",
		},

		-- stylua: ignore
		{ "gw", function() require("snacks").picker.lsp_workspace_symbols() end, desc = "󰒕 Workspace symbols" },

		--------------------------------------------------------------------------
		-- GIT

		{ "<leader>gs", function() require("snacks").picker.git_status() end, desc = "󰗲 Status" },
		{ "<leader>gl", function() require("snacks").picker.git_log() end, desc = "󰗲 Log" },
		{
			"<leader>gH",
			function() require("snacks").picker.git_log_file() end,
			desc = "󰗲 File History",
		},
		{ "<leader>ga", function() require("snacks").picker.git_diff() end, desc = "󰐖 Hunks" },

		-- stylua: ignore start
		{ "<leader>gb", function() require("snacks").picker.git_branches() end, desc = "󰗲 Branches" },
		{ "<leader>gi", function() require("snacks").picker.gh_issue() end, desc = " GitHub Issues (open)" },
		{ "<leader>gI", function() require("snacks").picker.gh_issue { state = "all" } end, desc = " GitHub Issues (all)" },
		{ "<leader>gp", function() require("snacks").picker.gh_pr() end, desc = " GitHub PRs (open)" },
		{ "<leader>gP", function() require("snacks").picker.gh_pr { state = "all" } end, desc = " GitHub PRs (all)" },
		-- stylua: ignore end

		--------------------------------------------------------------------------
		-- INSPECT

		{ "<leader>iv", function() require("snacks").picker.help() end, desc = "󰋖 Vim help" },
		{
			"<leader>ih",
			function() require("snacks").picker.highlights() end,
			desc = " Highlights",
		},
		{
			"<leader>is",
			function() require("snacks").picker.pickers() end,
			desc = "󰗲 Snacks pickers",
		},
		{
			"<leader>ik",
			function() require("snacks").picker.keymaps() end,
			desc = "󰌌 Keymaps (global)",
		},
		{
			"<leader>iK",
			function()
				require("snacks").picker.keymaps { global = false, title = "󰌌 Keymaps (buffer)" }
			end,
			desc = "󰌌 Keymaps (buffer)",
		},

		--------------------------------------------------------------------------
		-- MISC

		{
			"<leader>pc",
			function() require("snacks").picker.colorschemes() end,
			desc = " Colorschemes",
		},
		{ "<leader>ms", function() require("snacks").picker.marks() end, desc = "󰃁 Select mark" },
		{ "<leader>ut", function() require("snacks").picker.undo() end, desc = "󰋚 Undo tree" },
		{
			"<leader>qq",
			function() require("snacks").picker.qflist() end,
			desc = " Search qf-list",
		},
		-- stylua: ignore
		{ "<C-.>", function() require("snacks").picker.icons() end, mode = { "n", "i" }, desc = "󱗿 Icon picker" },

		{ "g.", function() require("snacks").picker.resume() end, desc = "󰗲 Resume" },
	},

	init = require("config.utils").loadGhToken,
	opts = {
		gh = { -- https://github.com/folke/snacks.nvim/blob/main/docs/gh.md#%EF%B8%8F-config
		},
		picker = {
			sources = {
				undo = {
					win = {
						input = {
							keys = {
								-- <CR>: restores the selected undo point
								["<D-c>"] = { "yank_add", mode = "i" },
								["<D-d>"] = { "yank_del", mode = "i" },
							},
						},
					},
					layout = "big_preview",
				},
				marks = {
					transform = function(item) return item.label:find("%u") ~= nil end, -- only global marks
					win = {
						input = {
							keys = { ["<D-d>"] = { "delete_mark", mode = "i" } },
						},
					},
					actions = {
						delete_mark = function(picker)
							local markName = picker:current().label
							require("personal-plugins.marks").deleteMark(markName)
							picker:find() -- reload
						end,
					},
				},
				explorer = {
					auto_close = true,
					layout = { preset = "very_vertical" },
					win = {
						list = {
							keys = {
								-- consistent with Finder vim mode bindings
								["<D-up>"] = "explorer_up",
								["h"] = "explorer_close", -- go up folder
								["l"] = "confirm", -- enter folder / open file
								["zz"] = "explorer_close_all",
								["y"] = "explorer_copy",
								["n"] = "explorer_add",
								["d"] = "explorer_del",
								["m"] = "explorer_move",
								["o"] = "explorer_open", -- open with system application
								["<CR>"] = "explorer_rename",
								["-"] = "focus_input", -- i.e. search
								["."] = "toggle_hidden_and_ignored",

								-- consistent with `gh` for next hunk and `ge` for next diagnostic
								["gh"] = "explorer_git_next",
								["gH"] = "explorer_git_prev",
								["ge"] = "explorer_diagnostic_next",
								["gE"] = "explorer_diagnostic_prev",
							},
						},
					},
				},
				files = {
					cmd = "rg",
					args = {
						"--sortr=modified", -- sort by recency, slight performance impact
						("--ignore-file=" .. vim.fs.normalize("~/.config/ripgrep/ignore")),
					},
					exclude = { -- keep this ignored even if toggling to show hidden/ignored
						"node_modules",
						".DS_Store",
						"*.docx",
						"*.zip",
						"*.pptx",
						"*.svg",
					},
					layout = "small_no_preview",
					matcher = { frecency = true }, -- slight performance impact
					win = {
						input = {
							keys = {
								["<C-h>"] = { "toggle_hidden_and_ignored", mode = "i" }, -- consistent with `fzf`
								[":"] = { "complete_and_add_colon", mode = "i" },
							},
						},
					},
					actions = {
						complete_and_add_colon = function(picker)
							-- snacks allows opening files with `file:lnum`, but it
							-- only matches if the filename is complete. With this
							-- action, we complete the filename if using the 1st colon
							-- in the query.
							local query = vim.api.nvim_get_current_line()
							local file = picker:current().file
							if not file or query:find(":") then
								vim.fn.feedkeys(":", "n")
								return
							end
							vim.api.nvim_set_current_line(file .. ":")
							vim.cmd.startinsert { bang = true }
						end,
					},
				},
				recent = {
					layout = "small_no_preview",
					filter = {
						paths = {
							[vim.fs.normalize("~/.config/hammerspoon/Spoons/EmmyLua.spoon")] = false,
							[vim.g.iCloudSync] = false, -- e.g., scratch buffers
						},
						filter = function(item) return vim.fs.basename(item.file) ~= "COMMIT_EDITMSG" end,
					},
				},
				grep = {
					regex = false, -- use fixed strings by default
					cmd = "rg",
					args = {
						"--sortr=modified", -- sort by recency, slight performance impact
						("--ignore-file=" .. vim.fs.normalize("~/.config/ripgrep/ignore")),
					},
					layout = "big_preview",
					win = {
						input = {
							keys = {
								["<C-i>"] = { "toggle_hidden_and_ignored", mode = "i" }, -- consistent with `fzf`
								["<C-r>"] = { "toggle_regex", mode = "i" },
							},
						},
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
						local lnum = item.pos[1]
						vim.cmd(("edit +%d %s"):format(lnum, item.file))
					end,
					layout = "toggled_preview",
				},
				colorschemes = {
					-- at the bottom, so there is more space to preview
					layout = { max_height = 8, preset = "ivy" },
				},
				icons = {
					layout = {
						preset = "small_no_preview",
						layout = { width = 0.7 },
					},
					matcher = { frecency = true }, -- slight performance impact
					-- PENDING https://github.com/folke/snacks.nvim/pull/2520
					confirm = function(picker, item, action)
						picker:close()
						if not item then return end
						local value = item[action.field] or item.data or item.text
						vim.api.nvim_paste(value, true, -1)
						if picker.input.mode ~= "i" then return end
						vim.schedule(function()
							-- `nvim_paste` puts the cursor on the last character, so we need to
							-- emulate `a` to re-enter insert mode at the correct position. However,
							-- `:startinsert` does `i` and `:startinsert!` does `A`, so we need to
							-- check if the cursor is at the end of the line.
							local col = vim.fn.virtcol(".")
							local eol = vim.fn.virtcol("$") - 1
							if col == eol then
								vim.cmd.startinsert { bang = true }
							else
								vim.cmd.normal { "l", bang = true }
								vim.cmd.startinsert()
							end
						end)
					end,
				},
				highlights = {
					confirm = function(picker, item)
						vim.fn.setreg("+", item.hl_group)
						vim.notify(item.hl_group, nil, { title = "Copied", icon = "󰅍" })
						picker:close()
					end,
				},
				git_branches = {
					all = true, -- = include remotes
				},
				git_log = {
					layout = "toggled_preview",
				},
				git_log_file = {
					layout = "toggled_preview",
				},
				git_status = {
					layout = "big_preview",
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
				git_diff = {
					layout = "big_preview",
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
				gh_issue = {
					layout = "big_preview",
				},
				gh_pr = {
					layout = "big_preview",
				},
			},
			formatters = {
				file = { filename_first = true },
				selected = { unselected = false }, -- hide selection column when no selected items
			},
			previewers = {
				diff = { builtin = false }, -- use `delta` automatically
				git = { builtin = false },
			},
			toggles = {
				regex = { icon = "r", value = true }, -- invert
			},
			ui_select = true,
			layout = "wide_with_preview", -- = default layout
			layouts = { -- define available layouts
				small_no_preview = {
					layout = {
						box = "horizontal",
						width = 0.65,
						height = 0.6,
						border = "none",
						{
							box = "vertical",
							border = vim.o.winborder --[[@as "rounded"|"single"|"double"|"solid"]],
							title = "{title} {live} {flags}",
							{ win = "input", height = 1, border = "bottom" },
							{ win = "list", border = "none" },
						},
					},
				},
				very_vertical = {
					preset = "small_no_preview",
					layout = { height = 0.95, width = 0.45 },
				},
				wide_with_preview = {
					preset = "small_no_preview",
					layout = {
						width = 0.99,
						[2] = { -- as second column
							win = "preview",
							title = "{preview}",
							border = vim.o.winborder --[[@as "rounded"|"single"|"double"|"solid"]],
							width = 0.5,
							wo = { number = false, statuscolumn = " ", signcolumn = "no" },
						},
					},
				},
				toggled_preview = {
					preset = "big_preview",
					preview = false,
				},
				big_preview = {
					preset = "wide_with_preview",
					layout = {
						height = 0.85,
						[2] = { width = 0.6 }, -- second win is the preview
					},
				},
			},
			win = {
				input = {
					keys = {
						["<Esc>"] = { "close", mode = "i" }, --> disable normal mode
						["<CR>"] = { "confirm", mode = "i" },
						["<Tab>"] = { "list_down_wrapping", mode = "i" },
						["<S-Tab>"] = { "list_up", mode = "i" },
						["<D-Up>"] = { "list_top", mode = "i" },
						["<D-Down>"] = { "list_bottom", mode = "i" },

						["<M-CR>"] = { "select_and_next", mode = "i" }, -- consistent with `fzf`
						["<Up>"] = { "history_back", mode = "i" },
						["<Down>"] = { "history_forward", mode = "i" },

						["<D-f>"] = { "toggle_maximize", mode = "i" }, -- [f]ullscreen
						["<D-p>"] = { "toggle_preview", mode = "i" },
						["<C-CR>"] = { "cycle_win", mode = "i" },
						["<PageUp>"] = { "preview_scroll_up", mode = "i" },
						["<PageDown>"] = { "preview_scroll_down", mode = "i" },

						["<D-s>"] = { "qflist_and_go", mode = "i" },
						["<D-l>"] = { "reveal_in_macOS_Finder", mode = "i" },
						["<D-c>"] = { "yank", mode = "i" },

						["!"] = { "inspect", mode = "i" },
						["?"] = { "toggle_help_input", mode = "i" },
					},
				},
				list = {
					keys = {
						["<C-CR>"] = "cycle_win",
						["<D-p>"] = "toggle_preview",
						["G"] = "list_bottom",
						["gg"] = "list_top",
						["j"] = "list_down",
						["k"] = "list_up",
						["<Tab>"] = "list_down",
						["<S-Tab>"] = "list_up",
						["q"] = "close",
						["<Esc>"] = "close",

						["<D-l>"] = "reveal_in_macOS_Finder",
						["<D-c>"] = "yank",

						["!"] = "inspect",
						["?"] = "toggle_help_list",
					},
				},
				preview = { keys = { ["<C-CR>"] = { "cycle_win" } } },
			},
			actions = {
				list_down_wrapping = function(picker)
					local allVisible = #picker.list.items -- picker:count() only counts unfiltered
					local current = picker.list.cursor -- picker:current().idx incorrect for `smart` source
					local action = current == allVisible and "list_top" or "list_down"
					picker:action(action)
				end,
				reveal_in_macOS_Finder = function(picker)
					if jit.os ~= "OSX" then return end
					local path = picker:current().file
					if picker:current().cwd then path = picker:current().cwd .. "/" .. path end
					vim.system { "open", "-R", path }
					picker:close()
				end,
				qflist_and_go = function(picker)
					local query = vim.api.nvim_get_current_line()
					local title = ("%s: %s"):format(picker.title, query)
					picker:action("qflist")
					vim.fn.setqflist({}, "a", { title = title }) -- add missing title to qflist

					vim.cmd.cclose()
					vim.cmd("silent cfirst")
					vim.cmd.normal { "zv", bang = true } -- open folds

					vim.api.nvim_exec_autocmds("QuickFixCmdPost", {})
				end,
				toggle_hidden_and_ignored = function(picker)
					picker.opts["hidden"] = not picker.opts.hidden
					picker.opts["ignored"] = not picker.opts.ignored

					if picker.opts.finder ~= "explorer" then
						-- remove `--ignore-file` extra arg
						picker.opts["_originalArgs"] = picker.opts["_originalArgs"] or picker.opts.args
						local noIgnoreFileArgs = vim.iter(picker.opts.args)
							:filter(function(arg) return not vim.startswith(arg, "--ignore-file=") end)
							:totable()
						picker.opts["args"] = picker.opts.hidden and noIgnoreFileArgs
							or picker.opts["_originalArgs"]
					end

					picker:find()
				end,
			},
			prompt = "  ", -- 
			icons = {
				ui = { selected = "󰒆 " },
				undo = { saved = "" }, -- useless, since I have auto-saving
				git = {
					staged = "󰐖", -- consistent with tinygit
					added = "󰎔",
					modified = "󰄯",
					renamed = "󰏬",
				},
			},
		},
	},
}
