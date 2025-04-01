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
	-- get list of changed files
	local changedInfo = {}
	local gitDir = Snacks.git.get_root()
	if gitDir then
		local gitStatus = vim.system({ "git", "status", "--porcelain", "." }):wait().stdout
		local changes = vim.split(gitStatus or "", "\n", { trimempty = true })
		vim.iter(changes):each(function(line)
			local relPath = line:sub(4)
			local absPath = gitDir .. "/" .. relPath
			local change = line:sub(1, 2)
			changedInfo[absPath] = change
		end)
	end

	local currentFile = vim.api.nvim_buf_get_name(0)
	Snacks.picker.files {
		title = " " .. vim.fs.basename(vim.uv.cwd()),
		transform = function(item, _ctx)
			local itemPath = Snacks.picker.util.path(item)
			if itemPath == currentFile then return false end
		end,
		format = function(item, picker)
			local itemPath = Snacks.picker.util.path(item)
			item.status = changedInfo[itemPath]
			return require("snacks.picker.format").file(item, picker)
		end,
	}
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
					matcher = { filename_bonus = false },
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
		{ "gF", function() Snacks.picker.lsp_implementations() end, desc = "󰈿 Implementations" },
		{ "gd", function() Snacks.picker.lsp_definitions() end, desc = "󰈿 Definitions" },
		{ "gD", function() Snacks.picker.lsp_type_definitions() end, desc = "󰜁 Type definitions" },

		-- `lsp_symbols` tends to too much clutter like anonymous function
		{ "gs", function() Snacks.picker.treesitter() end, desc = "󰐅 Treesitter Symbols" },
		{ "gw", function() Snacks.picker.lsp_workspace_symbols() end, desc = "󰒕 Workspace symb." },
		{ "g!", function() Snacks.picker.diagnostics() end, desc = "󰋼 Workspace diagnostics" },

		--------------------------------------------------------------------------
		-- GIT

		{ "<leader>gb", function() Snacks.picker.git_branches() end, desc = "󰗲 Branches" },
		{ "<leader>gs", function() Snacks.picker.git_status() end, desc = "󰗲 Status" },
		{ "<leader>gl", function() Snacks.picker.git_log() end, desc = "󰗲 Log" },

		--------------------------------------------------------------------------
		-- INSPECT

		{ "<leader>ih", function() Snacks.picker.highlights() end, desc = "󰗲 Highlights" },
		{ "<leader>iv", function() Snacks.picker.help() end, desc = "󰋖 Vim help" },
		{ "<leader>ik", function() Snacks.picker.keymaps() end, desc = "󰌌 Keymaps (global)" },
		{ "<leader>is", function() Snacks.picker.pickers() end, desc = "󰗲 Snacks pickers" },
		{
			"<leader>iK",
			function() Snacks.picker.keymaps { global = false, title = "󰌌 Keymaps (buffer)" } end,
			desc = "󰌌 Keymaps (buffer)",
		},

		--------------------------------------------------------------------------
		-- MISC

		{ "<leader>pc", function() Snacks.picker.colorschemes() end, desc = "󰗲 Colorschemes" },
		{ "<leader>ut", function() Snacks.picker.undo() end, desc = "󰋚 Undo tree" },
		-- stylua: ignore
		{ "<C-.>", function() Snacks.picker.icons() end, mode = { "n", "i" }, desc = "󱗿 Icon picker" },
		{ "<leader>ml", function() Snacks.picker.marks() end, desc = "󰃃 List marks" },
		{ "g.", function() Snacks.picker.resume() end, desc = "󰗲 Resume" },
	},
	opts = {
		---@class snacks.picker.Config
		picker = {
			sources = {
				marks = { -- only global letters marks
					transform = function(item, _ctx)
						if not item.label:find("%u") then return false end
					end,
				},
				files = {
					cmd = "rg",
					args = {
						"--sortr=modified", -- sort by recency
						("--ignore-file=" .. vim.fs.normalize("~/.config/ripgrep/ignore")),
					},
					layout = "small_no_preview",
					exclude = { ".DS_Store" },
				},
				recent = {
					layout = "small_no_preview",
				},
				grep = {
					cmd = "rg",
					format = function(item, picker)
						item.line = nil -- `file` formatter, but do not display line
						return require("snacks.picker.format").file(item, picker)
					end,
					layout = {
						preset = "wide_with_preview",
						layout = { [2] = { width = 0.6 } }, -- sets preview wider
					},
					args = {
						"--sortr=modified", -- sort by recency
						("--ignore-file=" .. vim.fs.normalize("~/.config/ripgrep/ignore")),
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
				},
				colorschemes = {
					-- at the bottom, so there is more space to preview
					layout = { max_height = 9, preset = "ivy" },
				},
				icons = {
					layout = {
						preset = "small_no_preview",
						layout = { width = 0.7 },
					},
				},
				highlights = {
					confirm = function(picker, item)
						vim.fn.setreg("+", item.hl_group)
						vim.notify(item.hl_group, nil, { title = "Copied", icon = "󰅍" })
						picker:close()
					end,
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
				git_branches = {
					all = true, -- = include remotes
				},
			},
			formatters = {
				file = { filename_first = true, truncate = 70 },
				selected = { unselected = false }, -- don't show unselected
			},
			previewers = {
				diff = { builtin = false }, -- use delta automatically
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
							border = vim.o.winborder, ---@diagnostic disable-line: assign-type-mismatch faulty annotation
							title = "{title} {live} {flags}",
							{ win = "input", height = 1, border = "bottom" },
							{ win = "list", border = "none" },
						},
					},
				},
				wide_with_preview = {
					preset = "small_no_preview", -- inherit from above
					layout = {
						width = 0.99,
						[2] = { -- as second column
							win = "preview",
							title = "{preview}",
							border = vim.o.winborder, ---@diagnostic disable-line: assign-type-mismatch faulty annotation
							width = 0.5,
							wo = { number = false, statuscolumn = " ", signcolumn = "no" },
						},
					},
				},
			},
			win = {
				input = {
					keys = {
						["<CR>"] = { "confirm", mode = "i" },
						["<Esc>"] = { "cancel", mode = "i" }, -- = disable normal mode
						["<Tab>"] = { "list_down_wrapping", mode = "i" },
						["<S-Tab>"] = { "list_up", mode = "i" },
						["<D-Up>"] = { "list_top", "jump", mode = "i" },
						["<M-CR>"] = { "select_and_next", mode = "i" }, -- consistent with `fzf`
						["<Up>"] = { "history_back", mode = "i" },
						["<Down>"] = { "history_forward", mode = "i" },
						["<C-h>"] = { "toggle_hidden_and_ignored", mode = "i" }, -- consistent with `fzf`
						["<D-s>"] = { "qflist_and_go", mode = "i" },
						["<D-p>"] = { "toggle_preview", mode = "i" },
						["<D-l>"] = { "reveal_in_macOS_Finder", mode = "i" },
						["<D-c>"] = { "yank", mode = "i" },
						["<PageUp>"] = { "preview_scroll_up", mode = "i" },
						["<PageDown>"] = { "preview_scroll_down", mode = "i" },
						["?"] = { "inspect", mode = "i" },
					},
				},
			},
			actions = {
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
					vim.cmd.cfirst()
				end,
			},
			prompt = " ", -- slightly to the left
			icons = {
				ui = { selected = "󰒆 " },
				undo = { saved = "" }, -- useless, since I have auto-saving
				git = {
					commit = "",
					staged = "󰐖", -- consistent with tiyngit
					added = "",
					modified = "󰄯",
					renamed = "󰏫",
					untracked = "?",
				},
			},
		},
	},
}
