-- DOCS https://github.com/folke/snacks.nvim/blob/main/docs/picker.md
--------------------------------------------------------------------------------
---@module "snacks"

-- lightweight version of `telescope-import.nvim`
local function importLuaModule()
	local function import(text) return vim.trim(text:gsub(".-:", "")) end

	Snacks.picker.grep_word {
		title = "󰢱 Import module",
		cmd = "rg",
		args = { "--only-matching" },
		regex = true,
		supports_live = false,
		search = [[local (\w+) ?= ?require\(["'](.*?)["']\)(\.[\w.]*)?]],
		ft = "lua",

		live = false,
		layout = { preset = "small_no_preview", layout = { width = 0.75 } },
		transform = function(item, ctx)
			-- ensure items are unique
			ctx.meta.done = ctx.meta.done or {} ---@type table<string, boolean>
			local imp = import(item.text)
			if ctx.meta.done[imp] then return false end
			ctx.meta.done[imp] = true
		end,
		format = function(item, _picker)
			-- only display the grepped line
			local out = {}
			Snacks.picker.highlight.format(item, item.line, out)
			return out
		end,
		confirm = function(picker, item)
			-- insert the grepped line below the current one
			picker:close()
			local lnum = vim.api.nvim_win_get_cursor(0)[1]
			vim.api.nvim_buf_set_lines(0, lnum, lnum, false, { import(item.text) })
			vim.cmd.normal { "j==", bang = true }
		end,
	}
end

local function betterFileOpen()
	local changedFiles = {}
	local gitDir = Snacks.git.get_root()
	if gitDir then
		local args = { "git", "status", "--porcelain", "--ignored", "." }
		local gitStatus = vim.system(args):wait().stdout
		local changes = vim.split(gitStatus or "", "\n", { trimempty = true })
		vim.iter(changes):each(function(line)
			local relPath = line:sub(4)
			local change = line:sub(1, 2)
			if change == "??" then change = "A " end -- just nicer highlights for untracked
			if change:find("R") then relPath = relPath:gsub(".+ -> ", "") end -- renamed
			local absPath = gitDir .. "/" .. relPath
			changedFiles[absPath] = change
		end)
	end

	local currentFile = vim.api.nvim_buf_get_name(0)
	Snacks.picker.files {
		title = " " .. vim.fs.basename(vim.uv.cwd()),
		-- exclude the current file
		transform = function(item, _ctx)
			local itemPath = Snacks.picker.util.path(item)
			if itemPath == currentFile then return false end
		end,
		-- add git status and hidden status as highlights
		format = function(item, picker)
			local itemPath = Snacks.picker.util.path(item)
			item.status = changedFiles[itemPath]
			if vim.startswith(item.file, ".") then item.status = "!!" end -- hidden files
			return require("snacks.picker.format").file(item, picker)
		end,
	}
end

local file_without_line = function(item, picker)
	item.line = nil
	return require("snacks.picker.format").file(item, picker)
end

--------------------------------------------------------------------------------

return {
	"folke/snacks.nvim",
	keys = {
		-- FILES
		{ "go", betterFileOpen, desc = " Open files" },
		{
			"gr",
			function()
				-- HACK since `.stdpath("data")` cannot be overridden with nil, we
				-- need to remove it from the default settings itself
				require("snacks.picker.config.sources").recent.filter.paths[vim.fn.stdpath("data")] =
					nil
				Snacks.picker.recent()
			end,
			desc = "󰋚 Recent files",
			nowait = true, -- nvim default mappings starting with `gr`
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
					exclude = { "*/tests/*", "*/doc/*", "*.toml" },
					matcher = { filename_bonus = false }, -- folder more important here
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
					Snacks.picker.files { title = " " .. project, cwd = path }
				end)
			end,
			desc = " Project",
		},

		--------------------------------------------------------------------------
		-- GREP

		{ "gl", function() Snacks.picker.grep() end, desc = "󰛢 Grep" },
		{ "<leader>ci", importLuaModule, ft = "lua", desc = "󰢱 Import module" },

		--------------------------------------------------------------------------
		-- LSP

		{ "gf", function() Snacks.picker.lsp_references() end, desc = "󰈿 References" },
		{ "gd", function() Snacks.picker.lsp_definitions() end, desc = "󰈿 Definitions" },
		{ "gD", function() Snacks.picker.lsp_type_definitions() end, desc = "󰜁 Type definitions" },

		-- `lsp_symbols` tends to too much clutter like anonymous function
		{ "gs", function() Snacks.picker.treesitter() end, desc = "󰐅 Treesitter symbols" },
		-- treesitter does not work for markdown, so using LSP symbols here
		{ "gs", function() Snacks.picker.lsp_symbols() end, ft = "markdown", desc = "󰽛 Headings" },

		-- stylua: ignore
		{ "gw", function() Snacks.picker.lsp_workspace_symbols() end, desc = "󰒕 Workspace symbols" },
		{ "g!", function() Snacks.picker.diagnostics() end, desc = "󰋼 Workspace diagnostics" },

		--------------------------------------------------------------------------
		-- GIT

		{ "<leader>gb", function() Snacks.picker.git_branches() end, desc = "󰗲 Branches" },
		{ "<leader>gs", function() Snacks.picker.git_status() end, desc = "󰗲 Status" },
		{ "<leader>gl", function() Snacks.picker.git_log() end, desc = "󰗲 Log" },

		--------------------------------------------------------------------------
		-- INSPECT

		{ "<leader>ih", function() Snacks.picker.highlights() end, desc = " Highlights" },
		{ "<leader>iv", function() Snacks.picker.help() end, desc = "󰋖 Vim help" },
		{ "<leader>is", function() Snacks.picker.pickers() end, desc = "󰗲 Snacks pickers" },
		{ "<leader>ik", function() Snacks.picker.keymaps() end, desc = "󰌌 Keymaps (global)" },
		{
			"<leader>iK",
			function() Snacks.picker.keymaps { global = false, title = "󰌌 Keymaps (buffer)" } end,
			desc = "󰌌 Keymaps (buffer)",
		},

		--------------------------------------------------------------------------
		-- MISC

		{ "<leader>pc", function() Snacks.picker.colorschemes() end, desc = " Colorschemes" },
		{ "<leader>ut", function() Snacks.picker.undo() end, desc = "󰋚 Undo tree" },
		-- stylua: ignore
		{ "<C-.>", function() Snacks.picker.icons() end, mode = { "n", "i" }, desc = "󱗿 Icon picker" },
		{ "g.", function() Snacks.picker.resume() end, desc = "󰗲 Resume" },
	},
	opts = {
		---@class snacks.picker.Config
		picker = {
			sources = {
				files = {
					cmd = "rg",
					args = {
						"--sortr=modified", -- sort by recency, slight performance impact
						("--ignore-file=" .. vim.fs.normalize("~/.config/ripgrep/ignore")),
					},
					exclude = { ".DS_Store" },
					layout = "small_no_preview",
					matcher = { frecency = true }, -- slight performance impact
				},
				recent = {
					layout = "small_no_preview",
					filter = {
						paths = { [vim.g.icloudSync] = false }, -- e.g., scratch buffers
					},
				},
				grep = {
					cmd = "rg",
					args = {
						"--sortr=modified", -- sort by recency, slight performance impact
						("--ignore-file=" .. vim.fs.normalize("~/.config/ripgrep/ignore")),
					},
					format = file_without_line,
					layout = {
						preset = "wide_with_preview",
						layout = { [2] = { width = 0.6 } }, -- sets preview wider
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
					layout = {
						preset = "wide_with_preview",
						preview = false, ---@diagnostic disable-line: assign-type-mismatch
					},
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
					confirm = function(picker, item)
						-- as opposed to snacks's default `nvim_put`, `nvim_paste`
						-- inserts at correct pos in insert mode & is also dot-repeatable
						picker:close()
						vim.api.nvim_paste(item.icon, false, -1)
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
				lsp_definitions = { format = file_without_line },
				lsp_references = { format = file_without_line },
				lsp_type_definitions = { format = file_without_line },
			},
			formatters = {
				file = { filename_first = true, truncate = 70 },
				selected = { unselected = false }, -- don't show unselected
			},
			previewers = {
				diff = { builtin = false }, -- use `delta` automatically
				git = { builtin = false },
			},
			ui_select = false, -- using my own version `vim.ui.select`
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
							border = vim.o.winborder --[[@as "rounded"|"single"|"double"|"solid"]],
							title = "{title} {live} {flags}",
							{ win = "input", height = 1, border = "bottom" },
							{ win = "list", border = "none" },
						},
					},
				},
				wide_with_preview = {
					preset = "small_no_preview", -- inherit from this preset
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
			},
			win = {
				input = {
					keys = {
						["<Esc>"] = { "cancel", mode = "i" }, --> disable normal mode
						["<CR>"] = { "confirm", mode = "i" },
						["<Tab>"] = { "list_down_wrapping", mode = "i" },
						["<S-Tab>"] = { "list_up", mode = "i" },
						["<D-Up>"] = { "list_top", mode = "i" },

						["<M-CR>"] = { "select_and_next", mode = "i" }, -- consistent with `fzf`
						["<Up>"] = { "history_back", mode = "i" },
						["<Down>"] = { "history_forward", mode = "i" },

						["<C-h>"] = { "toggle_hidden_and_ignored", mode = "i" }, -- consistent with `fzf`
						["<D-f>"] = { "toggle_maximize", mode = "i" }, -- [f]ullscreen
						["<D-p>"] = { "toggle_preview", mode = "i" },
						["<C-CR>"] = { "cycle_win", mode = "i" },
						["<PageUp>"] = { "preview_scroll_up", mode = "i" },
						["<PageDown>"] = { "preview_scroll_down", mode = "i" },

						["<D-s>"] = { "qflist_and_go", mode = "i" },
						["<D-l>"] = { "reveal_in_macOS_Finder", mode = "i" },
						["<D-c>"] = { "yank", mode = "i" },
						[":"] = { "complete_and_add_colon", mode = "i" },

						["!"] = { "inspect", mode = "i" },
						["?"] = { "toggle_help_input", mode = "i" },
					},
				},
				list = {
					keys = { ["<C-CR>"] = { "cycle_win" } },
				},
				preview = {
					keys = { ["<C-CR>"] = { "cycle_win" } },
				},
			},
			actions = {
				complete_and_add_colon = function(picker)
					-- snacks allows opening files with `file:lnum`, but it only
					-- matches if the filename is complete. With this action, we
					-- complete the filename if using the 1st colon in the query.
					local query = vim.api.nvim_get_current_line()
					local file = picker:current().file
					if not file or query:find(":") then
						vim.fn.feedkeys(":", "n")
						return
					end
					vim.api.nvim_set_current_line(file .. ":")
					vim.cmd.startinsert { bang = true }
				end,
				list_down_wrapping = function(picker)
					local allVisible = #picker.list.items -- picker:count() only counts unfiltered
					local current = picker.list.cursor -- picker:current().idx incorrect for `smart` source
					local action = current == allVisible and "list_top" or "list_down"
					picker:action(action)
				end,
				toggle_hidden_and_ignored = function(picker)
					picker.opts["hidden"] = not picker.opts.hidden
					picker.opts["ignored"] = not picker.opts.ignored
					picker:find()
				end,
				reveal_in_macOS_Finder = function(picker)
					if jit.os ~= "OSX" then return end
					vim.system { "open", "-R", picker:current().file }
					picker:close()
				end,
				qflist_and_go = function(picker)
					picker:action("qflist")
					vim.cmd.cclose()
					vim.cmd("silent cfirst")
					vim.cmd.normal { "zv", bang = true } -- open folds
				end,
			},
			prompt = " ", -- slightly to the left
			icons = {
				ui = { selected = "󰒆 " },
				undo = { saved = "" }, -- useless, since I have auto-saving
				git = {
					commit = "", -- save some space
					staged = "󰐖", -- consistent with tiyngit
					added = "󰎔",
					modified = "󰄯",
					renamed = "󰏬",
				},
			},
		},
	},
}
