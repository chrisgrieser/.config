-- DOCS https://github.com/folke/snacks.nvim/blob/main/docs/picker.md
--------------------------------------------------------------------------------

vim.api.nvim_create_autocmd("User", {
	group = vim.api.nvim_create_augroup("SnacksPickerOverrides", { clear = true }),
	desc = "User: lazy-load snacks-picker overwrites",
	pattern = "VeryLazy",
	callback = function(_ctx)
		-- disable default keymaps to make the `?` help overview less cluttered
		require("snacks.picker.config.defaults").defaults.win.input.keys = {}
		require("snacks.picker.config.defaults").defaults.win.list.keys = {}
		require("snacks.picker.config.sources").explorer.win.list.keys = {}

		-- remove the numbers from `vim.ui.select`
		local orig = require("snacks.picker.format").ui_select
		require("snacks.picker.format").ui_select = function(opts)
			return function(item, picker)
				local formatted = orig(opts)(item, picker)
				return vim.list_slice(formatted, 3)
			end
		end
	end,
})

--------------------------------------------------------------------------------

-- lightweight version of `telescope-import.nvim`
local function importLuaModule()
	Snacks.picker.grep {
		title = "󰢱 Import module",
		cmd = "rg",
		args = { "--only-matching", "--no-config" },
		live = false,
		regex = true,
		search = [[local (\w+) ?= ?require\(["'](.*?)["']\)(\.[\w.]*)?]],
		ft = "lua",

		layout = { preset = "small_no_preview", layout = { width = 0.75 } },
		transform = function(item, ctx) -- ensure items are unique
			ctx.meta.done = ctx.meta.done or {}
			local import = item.text:gsub(".-:", "") -- different occurrences of same import
			if ctx.meta.done[import] then return false end
			ctx.meta.done[import] = true
		end,
		format = function(item, _picker) -- only display the grepped line
			local out = {}
			local line = item.line:gsub("^local ", "")
			Snacks.picker.highlight.format(item, line, out)
			return out
		end,
		confirm = function(picker, item) -- insert the line below the current one
			picker:close()
			vim.cmd.normal { "o", bang = true }
			vim.api.nvim_set_current_line(item.line)
			vim.cmd.normal { "==l", bang = true }
		end,
	}
end
---@param dir string?
local function betterFileOpen(dir)
	if not dir then dir = vim.uv.cwd() end
	assert(dir and dir ~= "/", "No cwd set.")

	local changedFiles = {}
	local gitDir = Snacks.git.get_root(dir)
	if gitDir then
		local args = { "git", "-C", gitDir, "status", "--porcelain", "--ignored" }
		local gitStatus = vim.system(args):wait().stdout or ""
		local changes = vim.split(gitStatus, "\n", { trimempty = true })
		changedFiles = vim.iter(changes):fold({}, function(acc, line)
			local relPath = line:sub(4):gsub("^.+ -> ", "") -- `gsub` for renames
			local absPath = gitDir .. "/" .. relPath
			local change = line:sub(1, 2)
			if change == "??" then change = " A" end -- just nicer highlights for untracked
			acc[absPath] = change
			return acc
		end)
	end

	local currentFile = vim.api.nvim_buf_get_name(0)
	Snacks.picker.files {
		cwd = dir,
		title = "󰝰 " .. vim.fs.basename(dir),
		transform = function(item, _ctx) -- exclude the current file
			local itemPath = Snacks.picker.util.path(item)
			if itemPath == currentFile then return false end
		end,
		format = function(item, picker) -- add git status highlights
			local itemPath = Snacks.picker.util.path(item)
			item.status = changedFiles[itemPath]
			if vim.startswith(item.file, ".") then item.status = "!!" end -- hidden files
			return Snacks.picker.format.file(item, picker)
		end,
	}
end

local function browseProject()
	local projectsFolder = vim.g.localRepos -- CONFIG

	local projects = vim.iter(vim.fs.dir(projectsFolder)):fold({}, function(acc, item, type)
		if type == "directory" then table.insert(acc, item) end
		return acc
	end)

	if #projects == 0 then
		vim.notify("No projects found.", vim.log.levels.WARN)
	elseif #projects == 1 then
		betterFileOpen(projectsFolder .. "/" .. projects[1])
	else
		vim.ui.select(projects, { prompt = " Select project" }, function(project)
			if project then betterFileOpen(projectsFolder .. "/" .. project) end
		end)
	end
end

--------------------------------------------------------------------------------

return {
	"folke/snacks.nvim",
	keys = {
		---FILES------------------------------------------------------------------
		{ "gt", function() Snacks.picker.explorer() end, desc = " File tree" },
		{ "go", betterFileOpen, desc = " Open files" },
		{ "gn", function() betterFileOpen(vim.g.notesDir) end, desc = " Notes" },
		{ "gP", browseProject, desc = " Project" },
		{ "g,", function() betterFileOpen(vim.fn.stdpath("config")) end, desc = " nvim config" },
		{
			"gr",
			function() Snacks.picker.recent() end,
			desc = " Recent files",
			nowait = true, -- due to nvim default mappings starting with `gr`
		},
		{
			"gN",
			function()
				Snacks.picker.files {
					title = " nvim runtime",
					cwd = vim.env.VIMRUNTIME,
					exclude = { "*.txt", "*/testdir/*" },
					matcher = { filename_bonus = false }, -- folder more important here
					formatters = { file = { filename_first = false } },
				}
			end,
			desc = " nvim runtime",
		},
		{
			"gp",
			function()
				Snacks.picker.files {
					title = "󰈮 Local plugins",
					cwd = vim.fn.stdpath("data") .. "/lazy",
					exclude = { "*/tests/*", "*.toml", "*.tmux", "*.txt" },
					matcher = { filename_bonus = false }, -- folder more important here
					formatters = { file = { filename_first = false } },
				}
			end,
			desc = "󰈮 Local plugins",
		},

		---GREP-------------------------------------------------------------------
		{ "gl", function() Snacks.picker.grep() end, desc = "󰛢 Grep" },
		-- stylua: ignore
		{ "gL", function() Snacks.picker.grep { search = vim.fn.expand("<cword>") } end, desc = "󰛢 Grep cword" },
		{ "<leader>ci", importLuaModule, ft = "lua", desc = "󰢱 Import module" },

		---LSP--------------------------------------------------------------------
		{ "gf", function() Snacks.picker.lsp_references() end, desc = "󰈿 References" },
		{
			"gf",
			function() Snacks.picker.lsp_references { auto_confirm = false } end,
			ft = "markdown",
			desc = "󰈿 References",
		},
		{ "gd", function() Snacks.picker.lsp_definitions() end, desc = "󰈿 Definitions" },
		{ "gD", function() Snacks.picker.lsp_type_definitions() end, desc = "󰜁 Type definitions" },
		-- stylua: ignore
		{ "gw", function() Snacks.picker.lsp_workspace_symbols() end, desc = " Workspace symbols" },

		-- `lsp_symbols` tends to too much clutter like anonymous function
		{ "gs", function() Snacks.picker.treesitter() end, desc = "󰐅 Treesitter symbols" },

		---GIT--------------------------------------------------------------------
		{ "<leader>ga", function() Snacks.picker.git_diff() end, desc = "󰐖 Hunks" },
		{ "<leader>gA", function() Snacks.picker.git_status() end, desc = "󰐖 Files" },
		{ "<leader>gl", function() Snacks.picker.git_log() end, desc = "󱎸 Log" },
		{ "<leader>gb", function() Snacks.picker.git_branches() end, desc = "󰘬 Branches" },
		{ "<leader>gi", function() Snacks.picker.gh_issue() end, desc = " GitHub issues (open)" },
		-- stylua: ignore
		{ "<leader>gI", function() Snacks.picker.gh_issue { state = "all" } end, desc = " GitHub issues (all)" },
		{ "<leader>gP", function() Snacks.picker.gh_pr() end, desc = " GitHub PRs" },

		---INSPECT----------------------------------------------------------------
		{ "<leader>iv", function() Snacks.picker.help() end, desc = "󰋖 Vim help" },
		{ "<leader>ih", function() Snacks.picker.highlights() end, desc = " Highlight groups" },
		{ "<leader>is", function() Snacks.picker.pickers() end, desc = "󰗲 Snacks pickers" },
		{ "<leader>ik", function() Snacks.picker.keymaps() end, desc = "󰌌 Keymaps (global)" },
		-- stylua: ignore
		{ "<leader>iK", function() Snacks.picker.keymaps { global = false, title = "󰌌 Keymaps (buffer)" } end, desc = "󰌌 Keymaps (buffer)" },
		{ "<leader>il", function() Snacks.picker.lsp_config() end, desc = " LSP servers" },

		---MISC-------------------------------------------------------------------
		{ "<leader>pc", function() Snacks.picker.colorschemes() end, desc = " Colorschemes" },
		{ "<leader>eh", function() Snacks.picker.command_history() end, desc = " Ex-cmd history" },
		{ "<leader>yy", function() Snacks.picker.registers() end, desc = "󱛢 Yank ring" },
		{ "<leader>ut", function() Snacks.picker.undo() end, desc = "󰋚 Undo tree" },
		-- stylua: ignore
		{ "<C-.>", function() Snacks.picker.icons() end, mode = { "n", "i" }, desc = "󱗿 Icon picker" },
		{ "g.", function() Snacks.picker.resume() end, desc = "󰗲 Resume" },
		{ "g!", function() Snacks.picker.diagnostics() end, desc = " Workspace diagnostics" },
	},

	init = require("config.utils").loadGhToken, -- for issue & PR search
	---@type snacks.Config
	opts = {
		picker = {
			sources = {
				select = { -- vim.ui.select
					layout = {
						layout = { min_width = 40, backdrop = 40, width = 0.6 },
					},
					kinds = {}, -- allows-kind-specific config
				},
				files = {
					cmd = "rg",
					follow = true,
					args = {
						"--files", -- turn `rg` into a file finder
						"--sortr=modified", -- sort by recency, slight performance impact
						"--no-config",
						-- these are *always* ignored, even if `toggle_ignored` is switched
						("--ignore-file=" .. vim.env.HOME .. "/.config/ripgrep/ignore"),
					},
					layout = "small_no_preview",
					matcher = { frecency = true }, -- slight performance impact
					win = {
						input = {
							keys = { [":"] = { "complete_and_add_colon", mode = "i" } },
						},
					},
					-- 1. if binary, open in system application instead
					-- 2. if symlink, open the target, not the link
					confirm = function(picker, item, action)
						local absPath = Snacks.picker.util.path(item) or ""

						local symlinkTarget = vim.uv.fs_readlink(absPath)
						if symlinkTarget then
							local linkDir = vim.fs.dirname(item._path) -- not cwd, to handle relative symlinks
							local original = vim.fs.normalize(linkDir .. "/" .. symlinkTarget)
							assert(vim.uv.fs_stat(original), "file does not exist: " .. original)
							item._path = original
						end

						local binaryExt = { "pdf", "png", "webp", "docx" }
						local ext = absPath:match(".+%.([^.]+)$") or ""
						if vim.tbl_contains(binaryExt, ext) then
							vim.ui.open(absPath)
							picker:close()
						else
							Snacks.picker.actions.confirm(picker, item, action)
						end
					end,
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
				registers = {
					transform = function(item) return item.label:find("[1-9]") ~= nil end, -- only numbered
					confirm = { "yank", "close" },
				},
				explorer = {
					layout = { preset = "small_no_preview", layout = { height = 0.85 } },
					jump = { close = true },
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
								["<C-CR>"] = { "cycle_win", mode = "i" },

								-- consistent with `gh` for next hunk and `ge` for next diagnostic
								["gh"] = "explorer_git_next",
								["gH"] = "explorer_git_prev",
								["ge"] = "explorer_diagnostic_next",
								["gE"] = "explorer_diagnostic_prev",
							},
						},
					},
				},
				recent = { layout = "small_no_preview" },
				grep = {
					regex = false, -- use fixed strings by default
					cmd = "rg",
					args = {
						"--sortr=modified", -- sort by recency, slight performance impact
						"--no-config",
						-- these are *always* ignored, even if `toggle_ignored` is switched
						("--ignore-file=" .. vim.env.HOME .. "/.config/ripgrep/ignore"),
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
					layout = { preset = "big_preview", hidden = { "preview" } },
				},
				colorschemes = {
					-- at the bottom, so there is more space to preview
					layout = { hidden = { "preview" }, max_height = 8, preset = "ivy" },
				},
				icons = {
					layout = { preset = "small_no_preview", layout = { width = 0.7 } },
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
					-- confirm = copy name
					confirm = function(picker, item)
						vim.fn.setreg("+", item.hl_group)
						Snacks.notify(item.hl_group, { title = "Copied", icon = "󰅍" })
						picker:close()
					end,
				},
				git_log = {
					layout = { preset = "big_preview", hidden = { "preview" } },
				},
				git_status = {
					layout = "sidebar_no_input",
					win = {
						-- <CR> opens the file as usual
						list = { keys = { ["<Space>"] = "git_stage" } },
						preview = { keys = { ["<Space>"] = "git_stage" } },
					},
				},
				git_diff = {
					layout = "sidebar_no_input",
					win = {
						-- <CR> opens the file as usual
						list = { keys = { ["<Space>"] = "git_stage" } },
						preview = { keys = { ["<Space>"] = "git_stage" } },
					},
				},
				gh_issue = { layout = "big_preview" },
				gh_pr = { layout = "big_preview" },
				treesitter = { layout = "sidebar" },
				lsp_symbols = { layout = "sidebar" },
				lsp_config = {
					-- confirm: inspect LSP config
					confirm = function(picker, item)
						if not item.enabled then
							vim.notify("LSP server not enabled", vim.log.levels.WARN)
							return
						end
						picker:close()

						vim.schedule(function() -- scheduling needed for treesitter folding
							local client = item.attached and vim.lsp.get_clients({ name = item.name })[1]
								or vim.lsp.config[item.name]
							local type = item.attached and "running" or "enabled"
							Snacks.win {
								title = (" 󱈄 %s (%s) "):format(item.name, type),
								text = vim.inspect(client),
								width = 0.9,
								height = 0.9,
								border = vim.o.winborder --[[@as "rounded"|"single"|"double"]],
								bo = { ft = "lua" }, -- `.bo.ft` instead of `.ft` needed for treesitter folding
								wo = {
									statuscolumn = " ", -- adds padding
									cursorline = true,
									winfixbuf = true,
									fillchars = "fold: ,eob: ",
									foldmethod = "expr",
									foldexpr = "v:lua.vim.treesitter.foldexpr()",
								},
							}
						end)
					end,
				},
				command_history = { layout = "small_no_preview" },
			},
			formatters = {
				file = { filename_first = true },
			},
			previewers = {
				diff = {
					-- style = "terminal", -- "terminal" = use git command (deltas)
					wo = { wrap = false }, -- PENDING https://github.com/folke/snacks.nvim/issues/2490
				},
			},
			toggles = {
				regex = { icon = "regex", value = true }, -- invert -> only display if enabled
				follow = { icon = "no follow", value = false }, -- invert -> only display if disabled
				ignored = { icon = "ignored" },
				hidden = { icon = "hidden" },
			},
			ui_select = true,
			layout = "wide_with_preview", -- = default layout
			layouts = { -- define available layouts
				small_no_preview = {
					cycle = true, -- `list_up/down` action wraps
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
				wide_with_preview = {
					preset = "small_no_preview",
					layout = {
						width = 0.999,
						[2] = {
							win = "preview",
							title = "{preview}",
							border = vim.o.winborder --[[@as "rounded"|"single"|"double"|"solid"]],
							width = 0.5,
						},
					},
				},
				big_preview = {
					preset = "wide_with_preview",
					layout = {
						height = 0.8,
						[2] = { width = 0.6 }, -- second win is the preview
					},
				},
				sidebar = {
					preview = "main",
					cycle = true, -- `list_up/down` action wraps
					layout = {
						box = "vertical",
						position = "left", -- = split window
						width = 0.3,
						min_width = 25,
						{ win = "input", height = 1, border = "bottom" },
						{ win = "list" },
						{ win = "preview" },
					},
				},
				sidebar_no_input = {
					preview = "main",
					cycle = true, -- `list_up/down` action wraps
					layout = {
						box = "vertical",
						position = "left", -- = split window
						width = 0.3,
						min_width = 25,
						{ win = "list" },
						{ win = "preview" },
					},
				},
			},
			win = {
				input = {
					keys = {
						["<Esc>"] = { "close", mode = "i" }, --> disable normal mode
						["<D-w>"] = { "close", mode = "i" },
						["<CR>"] = { "confirm", mode = "i" },
						["<Tab>"] = { "list_down", mode = "i" },
						["<S-Tab>"] = { "list_up", mode = "i" },
						["<C-v>"] = { "edit_vsplit", mode = "i" },
						["<D-Up>"] = { "list_top", mode = "i" },
						["<D-Down>"] = { "list_bottom", mode = "i" },

						["<M-CR>"] = { "select_and_next", mode = "i" }, -- consistent with `fzf`
						["<Up>"] = { "history_back", mode = "i" },
						["<Down>"] = { "history_forward", mode = "i" },

						["<D-f>"] = { "toggle_maximize", mode = "i" }, -- [f]ullscreen
						["<C-CR>"] = { "cycle_win", mode = "i" },

						["<D-p>"] = { "toggle_preview", mode = "i" },
						["<PageUp>"] = { "preview_scroll_up", mode = "i" },
						["<PageDown>"] = { "preview_scroll_down", mode = "i" },

						-- mapping consistent with `fzf`
						["<C-h>"] = { { "toggle_hidden", "toggle_ignored" }, mode = "i" }, ---@diagnostic disable-line: assign-type-mismatch
						["<C-r>"] = { "toggle_regex", mode = "i" },
						["<C-f>"] = { "toggle_follow", mode = "i" },

						["<D-s>"] = { "qflist_and_go", mode = "i" },
						["<D-l>"] = { "reveal_in_macOS_Finder", mode = "i" },
						["<D-c>"] = { "yank", mode = "i" },

						["!"] = { "inspect", mode = "i" },
						["?"] = { "toggle_help_input", mode = "i" },
					},
				},
				list = {
					keys = {
						["q"] = "close",
						["<Esc>"] = "close",
						["<D-w>"] = "close",
						["<C-CR>"] = "cycle_win",
						["<D-p>"] = "toggle_preview",
						["G"] = "list_bottom",
						["gg"] = "list_top",
						["j"] = "list_down",
						["k"] = "list_up",
						["<Tab>"] = "list_down",
						["<S-Tab>"] = "list_up",
						["<PageUp>"] = "preview_scroll_up",
						["<PageDown>"] = "preview_scroll_down",

						["<D-l>"] = "reveal_in_macOS_Finder",
						["<D-c>"] = "yank",

						["!"] = "inspect",
						["?"] = "toggle_help_list",
					},
				},
				preview = {
					keys = {
						["q"] = "close",
						["<D-w>"] = "close",
						["<C-CR>"] = "cycle_win",
						["<Tab>"] = "list_down", -- cycle list from the preview win
						["<S-Tab>"] = "list_up",
					},
					wo = {
						number = false,
						statuscolumn = " ",
						signcolumn = "no",
					},
				},
			},
			actions = {
				yank = function(picker, item, action)
					-- override snack's yank function to make it cleaner
					if not item then return end
					local reg = action.reg or vim.v.register
					local value = item[action.field] or item.data or item.text
					vim.fn.setreg(reg, value)
					if action.notify ~= false then
						local buf = item.buf or vim.api.nvim_win_get_buf(picker.main)
						local ft = vim.bo[buf].filetype
						Snacks.notify(value, { icon = "󰅍", title = "Copied", ft = ft })
					end
				end,
				reveal_in_macOS_Finder = function(picker, item, _action)
					assert(jit.os == "OSX", "requires macOS")
					local absPath = assert(Snacks.picker.util.path(item), "no path")
					vim.system { "open", "-R", absPath }
					picker:close()
				end,
				qflist_and_go = function(picker, _item, _action)
					local query = vim.api.nvim_get_current_line()
					local title = picker.title .. (query and ": " .. query or "")
					picker:action("qflist")
					vim.fn.setqflist({}, "a", { title = title }) -- add missing title to qflist

					vim.cmd.cclose()
					vim.cmd("silent cfirst")
					vim.cmd.normal { "zv", bang = true } -- open folds

					vim.api.nvim_exec_autocmds("QuickFixCmdPost", {})
				end,
			},
			prompt = "  ", -- 
			icons = {
				ui = { selected = "󰒆" },
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
