local function projectName() return vim.fs.basename(vim.uv.cwd() or "") end
--------------------------------------------------------------------------------

local borderChars = { "─", "│", "─", "│", "┌", "┐", "┘", "└" }
if vim.g.borderStyle == "double" then
	borderChars = { "═", "║", "═", "║", "╔", "╗", "╝", "╚" }
end
if vim.g.borderStyle == "rounded" then
	borderChars = { "─", "│", "─", "│", "╭", "╮", "╯", "╰" }
end

local specialDirs = {
	"%.git/",
	"%.DS_Store$", -- macOS Finder
	"%.app/", -- macOS apps
	"%.spoon", -- Hammerspoon spoons
	"%.venv", -- python
	"__pycache__",
}

--------------------------------------------------------------------------------

local insertModeActions = {
	["?"] = "which_key",
	["<Tab>"] = "move_selection_worse",
	["<S-Tab>"] = "move_selection_better",
	["<CR>"] = "select_default",
	["<Esc>"] = "close",

	["<PageDown>"] = "preview_scrolling_down",
	["<PageUp>"] = "preview_scrolling_up",
	["<Up>"] = "cycle_history_prev",
	["<Down>"] = "cycle_history_next",
	["<D-s>"] = "smart_send_to_qflist",

	["<D-c>"] = function(prompt_bufnr) -- copy value
		local value = require("telescope.actions.state").get_selected_entry().value
		require("telescope.actions").close(prompt_bufnr)
		vim.fn.setreg("+", value)
		vim.notify(value, nil, { title = "Copied", icon = "󰅍" })
	end,
	-- mapping consistent with fzf-multi-select
	["<M-CR>"] = function(prompt_bufnr) -- multi-select
		require("telescope.actions").toggle_selection(prompt_bufnr)
		require("telescope.actions").move_selection_worse(prompt_bufnr)
	end,
}

local function toggleHiddenAction(prompt_bufnr)
	local current_picker = require("telescope.actions.state").get_current_picker(prompt_bufnr)
	local cwd = tostring(current_picker.cwd or vim.uv.cwd()) -- cwd only set if passed as opt

	local prevTitle = current_picker.prompt_title
	local currentQuery = require("telescope.actions.state").get_current_line()
	local title = "Find Files: " .. vim.fs.basename(cwd)
	local ignore = vim.deepcopy(require("telescope.config").values.file_ignore_patterns or {})
	local findCommand = vim.deepcopy(require("telescope.config").pickers.find_files.find_command)

	-- hidden status not stored, but title is, so we determine the previous state via title
	local includeIgnoreHidden = not prevTitle:find("hidden")
	if includeIgnoreHidden then
		vim.list_extend(ignore, { "node_modules", ".venv", "typings", "%.DS_Store$", "%.git/" })
		-- cannot simply toggle `hidden` since we are using `rg` as custom find command
		vim.list_extend(findCommand, { "--hidden", "--no-ignore", "--no-ignore-files" })
		title = title .. " (--hidden --no-ignore)"
	end

	-- ignore the existing current path due to using `rg --sortr=modified`
	local relPathCurrent = table.remove(current_picker.file_ignore_patterns)
	table.insert(ignore, relPathCurrent)

	require("telescope.actions").close(prompt_bufnr)
	require("telescope.builtin").find_files {
		default_text = currentQuery,
		prompt_title = title,
		find_command = findCommand,
		cwd = cwd,
		file_ignore_patterns = ignore,
		path_display = { "filename_first" }, -- cannot easily actual path_display
	}
end

local function copyColorValue(prompt_bufnr)
	local hlName = require("telescope.actions.state").get_selected_entry().value
	require("telescope.actions").close(prompt_bufnr)
	local value = vim.api.nvim_get_hl(0, { name = hlName })
	local out = {}
	if value.fg then table.insert(out, ("#%06x"):format(value.fg)) end
	if value.bg then table.insert(out, ("#%06x"):format(value.bg)) end
	if value.link then table.insert(out, "link: " .. value.link) end
	if #out > 0 then
		local toCopy = table.concat(out, "\n")
		vim.fn.setreg("+", toCopy)
		vim.notify(toCopy, nil, { title = "Copied", icon = "󰅍" })
	end
end

--------------------------------------------------------------------------------

vim.api.nvim_create_autocmd("FileType", {
	desc = "User: FIX `sidescrolloff` for Telescope",
	pattern = "TelescopePrompt",
	command = "setlocal sidescrolloff=1",
})

require("funcs.telescope-backdrop")

--------------------------------------------------------------------------------

local function telescopeConfig()
	require("telescope").setup {
		defaults = {
			path_display = { "tail" },
			selection_caret = " ",
			prompt_prefix = " ",
			multi_icon = "󰒆 ",
			results_title = false,
			prompt_title = false,
			dynamic_preview_title = true,
			preview = { timeout = 400, filesize_limit = 1 }, -- ms & Mb
			borderchars = borderChars,
			default_mappings = { i = insertModeActions, n = insertModeActions },
			layout_strategy = "horizontal",
			sorting_strategy = "ascending", -- so layout is consistent with `prompt_position = "top"`
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
				"--no-config",
				"--sortr=modified", -- small performance cost as it disables multithreading
				"--vimgrep",
				"--smart-case",
				"--follow",
				"--trim",
				("--ignore-file=" .. vim.fs.normalize("~/.config/ripgrep/ignore")),
			},
			-- stylua: ignore
			file_ignore_patterns = {
				"%.png$", "%.svg", "%.gif", "%.icns", "%.jpe?g", "%.webp", "%.icns",
				"%.zip", "%.pdf",
				unpack(specialDirs), -- needs to be last for correct unpacking
			},
		},
		pickers = {
			find_files = {
				-- INFO using `rg` instead of `fd` ensures that initially, the list
				-- of files is sorted by recently modified files. (`fd` does not
				-- have a `--sort` flag.)
				-- alternative approach: https://github.com/nvim-telescope/telescope.nvim/issues/2905
				find_command = {
					"rg",
					"--no-config",
					"--follow",
					"--files",
					"--sortr=modified",
					("--ignore-file=" .. vim.fs.normalize("~/.config/ripgrep/ignore")),
				},

				prompt_prefix = "󰝰 ",
				follow = true,
				mappings = {
					i = { ["<C-h>"] = toggleHiddenAction },
				},
				path_display = { "filename_first" },
				layout_config = { horizontal = { width = 0.6, height = 0.6 } }, -- use small layout, toggle via <D-p>
				previewer = false,
			},
			oldfiles = {
				prompt_prefix = "󰋚 ",
				path_display = function(_, path)
					local parentOfRoots = {
						vim.g.localRepos,
						vim.fs.normalize("~/.config"),
						vim.fs.normalize("~/Vaults"),
						vim.fn.stdpath("data") .. "/lazy",
						vim.env.HOMEBREW_PREFIX,
						vim.env.HOME,
					}
					vim.iter(parentOfRoots):each(function(root) path = path:gsub(vim.pesc(root), "") end)

					local project = path:match("/(.-)/") or "" -- highest parent
					local tail = vim.fs.basename(path)
					local out = tail .. "  " .. project

					local highlights = { { { #tail, #out }, "TelescopeResultsComment" } }
					return out, highlights
				end,
				file_ignore_patterns = { "COMMIT_EDITMSG" },

				layout_config = { horizontal = { width = 0.6, height = 0.6 } },
				previewer = false,
			},
			live_grep = {
				prompt_prefix = " ",
				disable_coordinates = true,
				layout_config = { horizontal = { preview_width = 0.7 } },
			},
			git_status = {
				prompt_prefix = "󰊢 ",
				show_untracked = true,
				file_ignore_patterns = {}, -- do not ignore images etc here
				mappings = {
					n = {
						["<Tab>"] = "move_selection_worse",
						["<S-Tab>"] = "move_selection_better",
						["<Space>"] = "git_staging_toggle",
						["<CR>"] = "select_default", -- opens file
					},
				},
				layout_strategy = "vertical",
				preview_title = "Files not staged",
				previewer = require("telescope.previewers").new_termopen_previewer {
					get_command = function(_, status)
						local width = vim.api.nvim_win_get_width(status.preview_win)
						local statArgs = ("%s,%s,25"):format(width, math.floor(width / 2))
						return { "git", "diff", "--color=always", "--stat=" .. statArgs }
					end,
				},
			},
			git_commits = {
				prompt_prefix = "󰊢 ",
				prompt_title = "Git Log",
				layout_config = { horizontal = { preview_width = 0.5 } },
				git_command = { "git", "log", "--all", "--format=%h %s %cr", "--", "." },
				previewer = require("telescope.previewers").new_termopen_previewer {
					dyn_title = function(_, entry) return entry.value end, -- hash as title
					get_command = function(entry, status)
						local hash = entry.value
						local previewWidth = vim.api.nvim_win_get_width(status.preview_win)
						local statArgs = ("%s,%s,25"):format(previewWidth, math.floor(previewWidth / 2))
						local previewFormat = "%C(bold)%C(magenta)%s%C(reset)%n"
							.. "%C(cyan)%D%n"
							.. "%C(blue)%an %C(yellow)(%ch)%n"
							.. "%C(reset)%b"

						return ("git show %s --color=always --stat=%s --format=%q | sed '$d'"):format(
							hash,
							statArgs,
							previewFormat
						)
					end,
				},
				mappings = {
					i = { ["<C-r>"] = "git_reset_mixed" },
				},
			},
			git_branches = {
				prompt_prefix = " ",
				show_remote_tracking_branches = true,
				previewer = false,
				layout_config = { horizontal = { height = 0.4, width = 0.7 } },
				mappings = {
					i = {
						["<D-n>"] = "git_create_branch",
						["<C-r>"] = "git_rename_branch",
					},
				},
			},
			keymaps = {
				prompt_prefix = " ",
				modes = { "n", "i", "c", "x", "o", "t" },
				show_plug = false,
			},
			highlights = {
				prompt_prefix = " ",
				layout_config = { horizontal = { preview_width = { 0.7, min = 20 } } },
				mappings = {
					i = { ["<CR>"] = copyColorValue },
				},
			},
			lsp_document_symbols = {
				prompt_prefix = "󰒕 ",
			},
			treesitter = {
				prompt_prefix = " ",
				symbols = { "function", "method" },
				show_line = false,
				symbol_highlights = { ["function"] = "Function", method = "Method" },
			},
			lsp_references = {
				prompt_prefix = "󰈿 ",
				trim_text = true,
				show_line = false,
				include_declaration = false,
				include_current_line = true,
				layout_config = { horizontal = { preview_width = { 0.7, min = 30 } } },
			},
			lsp_definitions = {
				prompt_prefix = "󰈿 ",
				trim_text = true,
				show_line = false,
				layout_config = { horizontal = { preview_width = { 0.7, min = 30 } } },
			},
			lsp_type_definitions = {
				prompt_prefix = "󰜁 ",
				trim_text = true,
				show_line = false,
				layout_config = { horizontal = { preview_width = { 0.7, min = 30 } } },
			},
			lsp_dynamic_workspace_symbols = { -- `dynamic` = updates results on typing
				prompt_prefix = "󰒕 ",
				fname_width = 0, -- can see name in preview title already
				symbol_width = 30,
				file_ignore_patterns = {
					"node_modules", -- js/ts
					"typings", -- python
					"homebrew", -- nvim runtime
					".local", -- local nvim plugins
					unpack(specialDirs), -- needs to be last for correct unpacking
				},
			},
			spell_suggest = {
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
						preview_width = 1, -- needs previewer for live preview of the theme
					},
				},
			},
		},
	}
end

--------------------------------------------------------------------------------
return {
	{
		"nvim-telescope/telescope.nvim",
		cmd = "Telescope",
		dependencies = { "nvim-lua/plenary.nvim", "nvim-tree/nvim-web-devicons" },
		config = telescopeConfig,
		keys = {
			{ "?", function() vim.cmd.Telescope("keymaps") end, desc = "⌨️ Search Keymaps" },
			{ "g.", function() vim.cmd.Telescope("resume") end, desc = "󰭎 Continue" },
			{
				"gs",
				function()
					local symbolFilter = {
						yaml = { "object", "array" },
						json = "module",
						toml = "object",
						markdown = "string", -- string -> headings in markdown files
					}
					-- stylua: ignore
					local ignoreSymbols = { "variable", "constant", "number", "package", "string", "object", "array", "boolean", "property" }
					local filter = symbolFilter[vim.bo.filetype]
					local opts = filter and { symbols = filter } or { ignore_symbols = ignoreSymbols }
					require("telescope.builtin").lsp_document_symbols(opts)
				end,
				desc = "󰒕 Symbols",
			},
			{
				"gs",
				function()
					-- using treesitter symbols instead, since the LSP symbols are crowded
					-- with anonymous functions
					vim.cmd.Telescope("treesitter")
				end,
				ft = "lua",
				desc = " Symbols",
			},
			{
				"g!",
				function()
					-- open all files in cwd of same ft, ensures workspace
					-- diagnostics are exhaustive
					local currentFile = vim.api.nvim_buf_get_name(0)
					local ext = currentFile:match("%w+$")
					vim.cmd.args("**/*." .. ext) -- open files matching glob
					vim.cmd.buffer(currentFile) -- stay at original buffer
					local msg = ("Opened %s %s files."):format(vim.fn.argc(), ext)
					vim.notify(msg, nil, { title = "󰒕 Diagnostics" })

					vim.cmd.Telescope("diagnostics") -- workspace diagnostics
				end,
				desc = "󰋼 Workspace Diagnostics",
			},
			{
				"gw",
				function() vim.cmd.Telescope("lsp_dynamic_workspace_symbols") end,
				desc = "󰒕 Workspace Symbols",
			},
			{ "gd", function() vim.cmd.Telescope("lsp_definitions") end, desc = "󰈿 Definitions" },
			{
				"gD",
				function() vim.cmd.Telescope("lsp_type_definitions") end,
				desc = "󰜁 Type Definitions",
			},
			{ "gf", function() vim.cmd.Telescope("lsp_references") end, desc = "󰈿 References" },
			{
				"gI",
				function() vim.cmd.Telescope("lsp_implementations") end,
				desc = "󰈿 Implementations",
			},
			{
				"<leader>ph",
				function() vim.cmd.Telescope("highlights") end,
				desc = " Search Highlights",
			},
			{ "<leader>gs", function() vim.cmd.Telescope("git_status") end, desc = "󰭎 Status" },
			{ "<leader>gl", function() vim.cmd.Telescope("git_commits") end, desc = "󰭎 Log" },
			{ "<leader>gb", function() vim.cmd.Telescope("git_branches") end, desc = "󰭎 Branches" },
			{ "zl", function() vim.cmd.Telescope("spell_suggest") end, desc = "󰓆 Spell Suggest" },
			{
				"<leader>pc",
				-- noautocmds -> no backdrop, so the colorscheme is previewable
				function() vim.cmd("noautocmd Telescope colorscheme") end,
				desc = " Colorschemes",
			},
			{
				"go",
				function()
					-- ignore current file, since using the `rg` workaround puts it on top
					local ignorePattern =
						vim.deepcopy(require("telescope.config").values.file_ignore_patterns or {})
					local cwd = vim.uv.cwd() or ""
					local relPathCurrent = vim.pesc(vim.api.nvim_buf_get_name(0):sub(#cwd + 2))
					table.insert(ignorePattern, relPathCurrent)

					-- add git info to file
					local changedFilesInCwd = {}
					local gitDir = vim.system({ "git", "rev-parse", "--show-toplevel" }):wait()
					local inGitRepo = gitDir.code == 0
					if inGitRepo then
						local rootLen = #vim.uv.cwd() - #vim.trim(gitDir.stdout) -- for cwd != git root
						local gitResult = vim.system({ "git", "status", "--short", "." }):wait().stdout
						local changes = vim.split(gitResult or "", "\n", { trimempty = true })
						vim.iter(changes):each(function(change)
							local gitChangeTypeLen = 3
							local relPath = change:sub(rootLen + gitChangeTypeLen + 1)
							table.insert(changedFilesInCwd, relPath)
						end)
					end

					require("telescope.builtin").find_files {
						prompt_title = "Find Files: " .. projectName(),
						file_ignore_patterns = ignorePattern,
						path_display = function(_, path)
							local tail = vim.fs.basename(path)
							local parent = vim.fs.dirname(path) == "." and "" or vim.fs.dirname(path)
							local out = tail .. "  " .. parent
							local highlights = {
								{ { #tail, #out }, "TelescopeResultsComment" },
							}
							if vim.tbl_contains(changedFilesInCwd, path) then
								table.insert(highlights, { { 0, #tail }, "Changed" })
							end
							return out, highlights
						end,
					}
				end,
				desc = "󰭎 Open File",
			},
			{
				"gr",
				function()
					-- add open buffers to oldfiles
					local openBufs = vim.iter(vim.fn.getbufinfo { buflisted = 1 })
						:map(function(buf) return buf.name end)
						:totable()
					vim.list_extend(vim.v.oldfiles, openBufs)
					vim.cmd.Telescope("oldfiles")
				end,
				desc = "󰭎 Recent Files",
			},
			{
				"gl",
				function()
					require("telescope.builtin").live_grep {
						prompt_title = "Live Grep: " .. projectName(),
					}
				end,
				desc = "󰭎 Live-Grep",
			},
			{
				"gl",
				function()
					vim.cmd.normal { '"zy', bang = true }
					local sel = vim.trim(vim.fn.getreg("z"))
					require("telescope.builtin").live_grep {
						default_text = sel,
						prompt_title = "Live Grep: " .. projectName(),
					}
				end,
				mode = "x",
				desc = "󰭎 Grep selection",
			},
		},
	},
	{ -- Icon Picker
		"nvim-telescope/telescope-symbols.nvim",
		dependencies = "nvim-telescope/telescope.nvim",
		keys = {
			{
				"<C-.>",
				mode = "i",
				function()
					require("telescope.builtin").symbols {
						sources = { "nerd", "math", "emoji" },
						layout_config = { horizontal = { width = 0.35 } },
					}
				end,
				desc = "󰭎 Icon Picker",
			},
		},
	},
}
