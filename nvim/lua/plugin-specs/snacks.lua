-- vim: foldlevel=2
vim.pack.add {
	"https://github.com/nvim-mini/mini.icons",
	"https://github.com/folke/snacks.nvim",
}
--------------------------------------------------------------------------------

---@type snacks.Config
local opts = {}
local helpers = require("personal-plugins.snacks-helpers")
--------------------------------------------------------------------------------

opts.input = {
	icon = "",
	win = {
		relative = "editor",
		backdrop = 60,
		title_pos = "left",
		width = 50,
		row = math.ceil(vim.o.lines / 2) - 3,
	},
}

opts.words = {
	notify_jump = true,
	modes = { "n" },
	debounce = 300, -- delay until highlight
}

opts.indent = {
	char = "│",
	scope = { hl = "Comment" },
	animate = {
		-- slower for more dramatic effect :o
		duration = { step = 50, total = 1000 },
	},
}

opts.scratch = {
	filekey = { count = false, cwd = false, branch = false }, -- just one scratch per ft
	win = {
		width = 0.75,
		height = 0.8,
		footer_pos = "right",
		keys = { q = false, ["<D-w>"] = "close" }, -- so `q` is available as my comment operator
		on_win = function(win)
			-- FIX display of scratchpad title (partially hardcoded icon, etc.)
			local title = vim.iter(win.opts.title)
				:map(function(part) return vim.trim(part[1]) end)
				:join(" ")
				:gsub("  ", " ")
			vim.api.nvim_win_set_config(win.win, { title = title })
		end,
	},
	win_by_ft = {
		javascript = helpers.createScratchRunKeymap("node"),
		typescript = helpers.createScratchRunKeymap("node"),
		python = helpers.createScratchRunKeymap("python3"),
		applescript = helpers.createScratchRunKeymap("osascript"),
		swift = helpers.createScratchRunKeymap("swift"),
		zsh = helpers.createScratchRunKeymap("zsh"),
		lua = {
			keys = {
				source = { desc = "source" }, -- just to shorten keymap hint
				print = {
					-- overwrite chainsaw's `objectLog` with snacks.scratch's
					-- special `print` (uses virtualtext instead of notification)
					"<leader>lo",
					function()
						local logLine = ("print(%s)"):format(vim.fn.expand("<cword>"))
						local installed, chainsaw = pcall(require, "chainsaw.config.config")
						if installed then logLine = logLine .. " -- " .. chainsaw.config.marker end
						vim.cmd.normal { "o", bang = true }
						vim.api.nvim_set_current_line(logLine)
					end,
					desc = "print",
				},
			},
		},
	},
}

opts.notifier = {
	timeout = 7500,
	sort = { "added" }, -- sort only by time
	width = { min = 12, max = 0.45 },
	height = { min = 1, max = 0.8 },
	icons = { error = "󰅚", warn = "", info = "󰋽", debug = "󰃤", trace = "󰓗" },
	top_down = false,
}
opts.styles = {
	notification = {
		focusable = true,
		wo = { winblend = 10, wrap = true },
	},
}

opts.picker = {
	sources = {
		select = { -- vim.ui.select
			layout = { layout = { min_width = 40, width = 0.6 } },
			kinds = {}, -- allows-kind-specific config
		},
		notifications = { -- notification history
			formatters = { severity = { level = false } },
			confirm = function(picker)
				require("config.snacks-helpers").openNotif(picker:current().idx)
				picker:close()
			end,
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
				local ext = (vim.fs.ext(absPath))
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
				vim.notify(item.hl_group, nil, { title = "Copied", icon = "󰅍" })
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
		treesitter = {
			layout = "sidebar",
			filter = { markdown = { "Field" } }, -- requires `queries/markdown/locals.scm`
		},
		lsp_symbols = { layout = "sidebar" },
		lsp_config = {
			layout = "big_preview",
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
				vim.notify(value, nil, { icon = "󰅍", title = "Copied", ft = ft })
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
		git = {
			staged = "󰐖", -- consistent with tinygit
			added = "󰎔",
			modified = "󰄯",
			renamed = "󰏬",
		},
	},
}

--------------------------------------------------------------------------------

do
	require("snacks").setup(opts)

	-- issue & PR search: load GH token
	require("config.utils").loadGhToken()

	-- notifier: modify certain notifications
	vim.notify = function(msg, lvl, notiOpts) ---@diagnostic disable-line: duplicate-set-field intentional overwrite
		if type(msg) ~= "string" then msg = tostring(msg) end

		local ignore = (msg == "No code actions available" and vim.bo.ft == "typescript")
			or msg:find("Vim%(foldclose%):E490: No fold found")
		if ignore then return end

		if vim.startswith(msg, "[nvim-treesitter/") then notiOpts = { id = "treesitter-update" } end
		msg = msg:gsub("^vim%.pack: ", "[vim.pack] ")
		Snacks.notifier(msg, lvl, notiOpts)
	end

	-- picker: disable default keymaps to make the `?` help overview less cluttered
	-- (deferred, since they load a bunch of snacks modules)
	vim.defer_fn(function()
		require("snacks.picker.config.defaults").defaults.win.input.keys = {}
		require("snacks.picker.config.defaults").defaults.win.list.keys = {}
		require("snacks.picker.config.sources").explorer.win.list.keys = {}

		-- picker: remove the numbers from `vim.ui.select`
		local orig = require("snacks.picker.format").ui_select
		require("snacks.picker.format").ui_select = function(o)
			return function(item, picker)
				local formatted = orig(o)(item, picker)
				return vim.list_slice(formatted, 3)
			end
		end
	end, 4000)
end

--------------------------------------------------------------------------------

---WORDS---------------------------------------------------------------------
Keymap { "ö", function() Snacks.words.jump(1, true) end, desc = "󰗲 Next reference" }
Keymap { "Ö", function() Snacks.words.jump(-1, false) end, desc = "󰗲 Prev reference" }

---INDENT--------------------------------------------------------------------
Keymap { "<leader>oi", helpers.toggleInvisibleChars, desc = " Invisible chars" }

---SCRATCH-------------------------------------------------------------------
Keymap {
	"<leader>es",
	function()
		if vim.bo.ft == "lua" then -- ensure .luarc.jsonc
			local scratchRoot = vim.fn.stdpath("data") .. "/scratch" -- default root for snacks
			local json = '{ "runtime.version": "LuaJIT", "workspace.library": ["$VIMRUNTIME/lua"] }'
			vim.fn.mkdir(scratchRoot, "p")
			vim.fn.writefile({ json }, scratchRoot .. "/.luarc.jsonc")
		end
		Snacks.scratch()
	end,
	desc = " Scratch buffer",
}
Keymap { "<leader>el", function() Snacks.scratch.select() end, desc = " List scratches" }

---NOTIFY--------------------------------------------------------------------
Keymap {
	"<Esc>",
	function()
		Snacks.notifier.hide()
		vim.snippet.stop()
	end,
	desc = "󰎟 Dismiss notice & exit snippet",
}
Keymap { "<leader>in", function() helpers.openNotif("last") end, desc = "󰎟 Last notification" }
Keymap { "<leader>iN", function() Snacks.picker.notifications() end, desc = "󰎟 Notif. history" }

---PICKER--------------------------------------------------------------------

-- files
Keymap { "gt", function() Snacks.picker.explorer() end, desc = " File tree" }
Keymap { "go", helpers.betterFileOpen, desc = " Open files" }
Keymap { "gn", function() helpers.betterFileOpen(vim.g.notesDir) end, desc = " Notes" }
Keymap { "gP", helpers.browseProject, desc = " Project" }
Keymap {
	"g,",
	function() helpers.betterFileOpen(vim.fn.stdpath("config")) end,
	desc = " nvim config",
}
Keymap {
	"gr",
	function() Snacks.picker.recent() end,
	desc = " Recent files",
	nowait = true, -- due to nvim default mappings starting with `gr`
}
Keymap {
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
}
Keymap {
	"gp",
	function()
		Snacks.picker.files {
			title = "󰈮 Local plugins",
			cwd = vim.fn.stdpath("data") .. "/site/pack/core/opt",
			exclude = { "*/tests/*", "*.toml", "*.tmux", "*.txt" },
			matcher = { filename_bonus = false }, -- folder more important here
			formatters = { file = { filename_first = false } },
		}
	end,
	desc = "󰈮 Local plugins",
}

-- grep
Keymap { "gl", function() Snacks.picker.grep() end, desc = "󰛢 Grep" }
-- stylua: ignore
Keymap { "gL", function() Snacks.picker.grep { search = vim.fn.expand("<cword>") } end, desc = "󰛢 Grep cword" }
Keymap { "<leader>ci", helpers.importLuaModule, ft = "lua", desc = "󰢱 Import module" }

-- LSP
Keymap { "gf", function() Snacks.picker.lsp_references() end, desc = "󰈿 References" }
Keymap {
	"gf",
	function() Snacks.picker.lsp_references { auto_confirm = false } end,
	ft = "markdown",
	desc = "󰈿 References",
}
Keymap { "gd", function() Snacks.picker.lsp_definitions() end, desc = "󰈿 Definitions" }
Keymap { "gD", function() Snacks.picker.lsp_type_definitions() end, desc = "󰜁 Type definitions" }
-- stylua: ignore
Keymap { "gw", function() Snacks.picker.lsp_workspace_symbols() end, desc = " Workspace symbols" }

-- `lsp_symbols` tends to too much clutter like anonymous function
Keymap { "gs", function() Snacks.picker.treesitter() end, desc = "󰐅 Treesitter symbols" }

-- git
Keymap { "<leader>ga", function() Snacks.picker.git_diff() end, desc = "󰐖 Hunks" }
Keymap { "<leader>gA", function() Snacks.picker.git_status() end, desc = "󰐖 Files" }
Keymap { "<leader>gl", function() Snacks.picker.git_log() end, desc = "󱎸 Log" }
Keymap { "<leader>gb", function() Snacks.picker.git_branches() end, desc = "󰘬 Branches" }
Keymap { "<leader>gi", function() Snacks.picker.gh_issue() end, desc = " GitHub issues (open)" }
-- stylua: ignore
Keymap { "<leader>gI", function() Snacks.picker.gh_issue { state = "all" } end, desc = " GitHub issues (all)" }
Keymap { "<leader>gP", function() Snacks.picker.gh_pr() end, desc = " GitHub PRs" }

-- inspect
Keymap { "<leader>iv", function() Snacks.picker.help() end, desc = "󰋖 Vim help" }
Keymap { "<leader>ih", function() Snacks.picker.highlights() end, desc = " Highlight groups" }
Keymap { "<leader>is", function() Snacks.picker.pickers() end, desc = "󰗲 Snacks pickers" }
Keymap { "<leader>ik", function() Snacks.picker.keymaps() end, desc = "󰌌 Keymaps (global)" }
-- stylua: ignore
Keymap { "<leader>iK", function() Snacks.picker.keymaps { global = false, title = "󰌌 Keymaps (buffer)" } end, desc = "󰌌 Keymaps (buffer)" }
Keymap { "<leader>il", function() Snacks.picker.lsp_config() end, desc = " LSP servers" }

-- misc
Keymap { "<leader>pc", function() Snacks.picker.colorschemes() end, desc = " Colorschemes" }
Keymap { "<leader>eh", function() Snacks.picker.command_history() end, desc = " Ex-cmd history" }
Keymap { "<leader>yy", function() Snacks.picker.registers() end, desc = "󱛢 Yank ring" }
-- stylua: ignore
Keymap { "<C-.>", function() Snacks.picker.icons() end, mode = { "n", "i" }, desc = "󱗿 Icon picker" }
Keymap { "g.", function() Snacks.picker.resume() end, desc = "󰗲 Resume" }
Keymap { "g!", function() Snacks.picker.diagnostics() end, desc = " Workspace diagnostics" }
