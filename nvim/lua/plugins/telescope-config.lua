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

local specialDirs = {
	"%.git/",
	"%.DS_Store$", -- macOS Finder
	"%.app/", -- macOS apps
	".venv", -- python,
	"EmmyLua.spoon", -- Hammerspoon
}

--------------------------------------------------------------------------------

vim.api.nvim_create_autocmd("FileType", {
	pattern = "TelescopePrompt",
	callback = function() vim.opt_local.sidescrolloff = 1 end,
})

require("funcs.telescope-backdrop").setup()

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
			default_mappings = { i = keymaps.insertMode, n = keymaps.normalMode },
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
				"--no-config",
				"--sortr=modified", -- performance cost as it disables multithreading
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
				mappings = { i = keymaps.fileActions },
				path_display = { "filename_first" },
				layout_config = { horizontal = { width = 0.6, height = 0.6 } }, -- use small layout, toggle via <D-p>
				previewer = false,
			},
			oldfiles = {
				prompt_prefix = "󰋚 ",
				path_display = function(_, path)
					local roots = {
						vim.g.localRepos,
						vim.fs.normalize("~/.config"),
						vim.fn.stdpath("data") .. "/lazy",
						os.getenv("HOME") or "",
						os.getenv("HOMEBREW_PREFIX") or "",
					}
					vim.iter(roots):each(function(root) path = path:gsub(vim.pesc(root), "") end)

					local project = path:match("/(.-)/") or "" -- highest parent
					local tail = vim.fs.basename(path)
					local out = tail .. "  " .. project

					local highlights = { { { #tail, #out }, "TelescopeResultsComment" } }
					return out, highlights
				end,
				file_ignore_patterns = { "%.log", "%.plist$", "COMMIT_EDITMSG" },

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
				initial_mode = "normal",
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
				initial_mode = "normal",
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
				mappings = { i = keymaps.highlightsActions },
			},
			lsp_document_symbols = {
				prompt_prefix = "󰒕 ",
			},
			lsp_references = {
				prompt_prefix = "󰈿 ",
				trim_text = true,
				show_line = false,
				include_declaration = false,
				include_current_line = true,
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
				file_ignore_patterns = {
					".local", -- local nvim plugins
					"node_modules", -- js/ts
					"typings", -- python
					"homebrew", -- for nvim runtime
					unpack(specialDirs), -- needs to be last for correct unpacking
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
			{ "?", function() telescope("keymaps") end, desc = "⌨️ Search Keymaps" },
			{ "g.", function() telescope("resume") end, desc = "󰭎 Continue" },
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
			-- stylua: ignore
			{ "g!", function() telescope("diagnostics") end, desc = "󰋼 Workspace Diagnostics" },
			{ "gw", function() telescope("lsp_dynamic_workspace_symbols") end, desc = "󰒕 Workspace Symbols" },
			{ "gd", function() telescope("lsp_definitions") end, desc = "󰈿 Definitions" },
			{ "gD", function() telescope("lsp_type_definitions") end, desc = "󰜁 Type Definitions" },
			{ "gf", function() telescope("lsp_references") end, desc = "󰈿 References" },
			{ "gI", function() telescope("lsp_implementations") end, desc = "󰈿 Implementations" },
			{ "<leader>ph", function() telescope("highlights") end, desc = " Search Highlights" },
			{ "<leader>gs", function() telescope("git_status") end, desc = "󰭎 Status" },
			{ "<leader>gl", function() telescope("git_commits") end, desc = "󰭎 Log" },
			{ "<leader>gb", function() telescope("git_branches") end, desc = "󰭎 Branches" },
			{ "zl", function() telescope("spell_suggest") end, desc = "󰓆 Spell Suggest" },
			{
				"<leader>pc",
				-- noautocmds -> no backdrop -> colorscheme previewable
				function() vim.cmd("noautocmd Telescope colorscheme") end,
				desc = " Colorschemes",
			},
			{
				"go",
				function()
					-- ignore current file, since using the `rg` workaround puts it on top
					local ignorePattern =
						vim.deepcopy(require("telescope.config").values.file_ignore_patterns or {})
					local cwd = vim.uv.cwd()
					if cwd then
						local relPathCurrent = vim.pesc(vim.api.nvim_buf_get_name(0):sub(#cwd + 2))
						table.insert(ignorePattern, relPathCurrent)
					end

					-- add git info to file
					local changedFilesInCwd = {}
					local gitDir = vim.system({ "git", "rev-parse", "--show-toplevel" }):wait()
					local inGitRepo = gitDir.code == 0
					if inGitRepo then
						local pathInGitRoot = #vim.uv.cwd() - #vim.trim(gitDir.stdout) -- for cwd != git root
						local gitResult = vim.system({ "git", "diff", "--name-only", "." }):wait().stdout
						local changes = vim.split(gitResult or "", "\n", { trimempty = true })
						for _, change in ipairs(changes) do
							local file = change:sub(pathInGitRoot + 1) -- only relative path
							table.insert(changedFilesInCwd, file)
						end
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
					telescope("oldfiles")
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
				"gL",
				function()
					require("telescope.builtin").live_grep {
						default_text = vim.fn.expand("<cword>"),
						prompt_title = "Live Grep: " .. projectName(),
					}
				end,
				desc = "󰭎 Grep cword",
			},
			{
				"gL",
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
