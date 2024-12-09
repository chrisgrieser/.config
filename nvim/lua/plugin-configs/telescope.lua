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
	"__pycache__", -- python
}

vim.api.nvim_create_autocmd("FileType", {
	group = vim.api.nvim_create_augroup("TelescopeFix", { clear = true }),
	desc = "User: FIX `sidescrolloff` for Telescope",
	pattern = "TelescopePrompt",
	command = "setlocal sidescrolloff=1",
})

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

return {
	"nvim-telescope/telescope.nvim",
	cmd = "Telescope",
	dependencies = { "nvim-lua/plenary.nvim", "echasnovski/mini.icons" },
	config = function()
		require("personal-plugins.telescope-backdrop")

		require("telescope").setup {
			defaults = {
				scroll_strategy = "cycle", -- do not cycle from top to bottom

				path_display = { "tail" },
				selection_caret = " ",
				prompt_prefix = " ",
				multi_icon = "󰒆 ",
				results_title = false, -- just says "Results" in most cases
				dynamic_preview_title = true,
				preview = { timeout = 500, filesize_limit = 1 }, -- ms & Mb
				borderchars = borderChars,
				default_mappings = {
					i = {
						["?"] = "which_key",
						["<Tab>"] = "move_selection_worse",
						["<S-Tab>"] = "move_selection_better",
						["<CR>"] = "select_default",
						["<Esc>"] = "close", -- effectively disables normal mode for Telescope

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
					},
				},
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
					"%.png$", "%.svg", "%.gif", "%.jpe?g", "%.webp", "%.icns", "%.ico",
					"%.zip", "%.pdf",
					unpack(specialDirs), -- needs to be last for complete unpacking
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
					prompt_title = "󰝰 Files in cwd",
					path_display = { "filename_first" },
					layout_config = { horizontal = { width = 0.6, height = 0.6 } }, -- use small layout, toggle via <D-p>
					previewer = false,
					follow = true,
					mappings = {
						i = {
							["<C-h>"] = function(promptBufnr)
								local current_picker =
									require("telescope.actions.state").get_current_picker(promptBufnr)
								local cwd = tostring(current_picker.cwd or vim.uv.cwd()) -- cwd only set if passed as opt

								local prevTitle = current_picker.prompt_title
								local currentQuery = require("telescope.actions.state").get_current_line()
								local title = "󰝰 Find files: " .. vim.fs.basename(cwd)
								local ignore = vim.deepcopy(
									require("telescope.config").values.file_ignore_patterns or {}
								)
								local findCommand =
									vim.deepcopy(require("telescope.config").pickers.find_files.find_command)

								-- hidden status not stored, but title is, so we determine the previous state via title
								local includeIgnoreHidden = not prevTitle:find("hidden")
								if includeIgnoreHidden then
									vim.list_extend(
										ignore,
										{ "node_modules", ".venv", "typings", "%.DS_Store$", "%.git/" }
									)
									-- cannot simply toggle `hidden` since we are using `rg` as custom find command
									vim.list_extend(
										findCommand,
										{ "--hidden", "--no-ignore", "--no-ignore-files" }
									)
									title = title .. " (--hidden --no-ignore)"
								end

								-- ignore the existing current path due to using `rg --sortr=modified`
								local relPathCurrent = table.remove(current_picker.file_ignore_patterns)
								table.insert(ignore, relPathCurrent)

								require("telescope.actions").close(promptBufnr)
								require("telescope.builtin").find_files {
									default_text = currentQuery,
									prompt_title = title,
									find_command = findCommand,
									cwd = cwd,
									file_ignore_patterns = ignore,
									path_display = { "filename_first" },
								}
							end,
						},
					},
				},
				oldfiles = {
					prompt_title = "󰋚 Recent files",
					path_display = function(_, path)
						local parentOfRoots = {
							vim.g.localRepos,
							vim.fs.normalize("~/Vaults"),
							vim.fn.stdpath("data") .. "/lazy",
							vim.env.HOMEBREW_PREFIX,
							vim.env.HOME,
						}
						vim.iter(parentOfRoots)
							:each(function(root) path = path:gsub(vim.pesc(root), "") end)

						-- project = highest parent
						local project = path:match("/(%.config/.-)/") or path:match("/(.-)/") or ""
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
					prompt_title = " Live grep",
					disable_coordinates = true,
					layout_config = { horizontal = { preview_width = 0.7 } },
				},
				git_status = {
					prompt_title = "󰊢 Git status",
					show_untracked = true,
					file_ignore_patterns = {}, -- do not ignore images etc here
					mappings = {
						i = {
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
					prompt_title = "󰊢 Git log",
					layout_config = {
						horizontal = { preview_width = 0.4 },
					},
					git_command = { "git", "log", "--all", "--format=%h%s", "--", "." },
					previewer = require("telescope.previewers").new_termopen_previewer {
						dyn_title = function(_, entry) return entry.value end, -- hash as title
						get_command = function(entry, status)
							local hash = entry.value
							local width = vim.api.nvim_win_get_width(status.preview_win)
							local statArgs = ("%d,%d,25"):format(width, math.floor(width / 2))
							local format = "%C(bold)%C(magenta)%s%C(reset)%n"
								.. "%C(cyan)%D%n"
								.. "%C(blue)%an %C(yellow)(%ch)%n"
								.. "%C(reset)%b"

							return ("git show %s --color=always --stat=%s --format=%q | sed '$d'"):format(
								hash,
								statArgs,
								format
							)
						end,
					},
					mappings = {
						i = { ["<C-r>"] = "git_reset_mixed" },
					},
				},
				git_branches = {
					prompt_title = "󰘬 Git branches",
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
					prompt_title = "⌨️ Keymaps",
					modes = { "n", "i", "c", "x", "o", "t" },
					show_plug = false,
				},
				highlights = {
					prompt_title = " Highlights",
					layout_config = { horizontal = { preview_width = { 0.7, min = 20 } } },
					mappings = {
						i = {
							["<CR>"] = function(promptBufnr)
								local hlName = require("telescope.actions.state").get_selected_entry().value
								require("telescope.actions").close(promptBufnr)
								local hlValue = vim.api.nvim_get_hl(0, { name = hlName })
								local out = vim.iter(hlValue):fold({}, function(acc, key, val)
									if key == "link" then acc.link = val end
									if key == "fg" then acc.fg = ("#%06x"):format(val) end
									if key == "bg" then acc.bg = ("#%06x"):format(val) end
									return acc
								end)
								if vim.tbl_isempty(out) then return end

								local values = table.concat(vim.tbl_values(out), "\n")
								local keys = table.concat(vim.tbl_keys(out), " & ")
								vim.fn.setreg("+", values)
								local msg = ("**%s**\n%s"):format(keys, values)
								vim.notify(msg, nil, { title = "Copied", icon = "" })
							end,
						},
					},
				},
				lsp_references = {
					prompt_title = "󰈿 LSP references",
					trim_text = true,
					show_line = false,
					include_declaration = false,
					include_current_line = true,
					layout_config = { horizontal = { preview_width = { 0.7, min = 30 } } },
				},
				lsp_definitions = {
					prompt_title = "󰈿 LSP definitions",
					trim_text = true,
					show_line = false,
					layout_config = { horizontal = { preview_width = { 0.7, min = 30 } } },
				},
				lsp_type_definitions = {
					prompt_title = "󰜁 LSP type definitions",
					trim_text = true,
					show_line = false,
					layout_config = { horizontal = { preview_width = { 0.7, min = 30 } } },
				},
				lsp_document_symbols = {
					prompt_title = "󰒕 LSP document symbols",
				},
				treesitter = {
					prompt_title = " Treesitter symbols",
					symbols = { "function", "method" },
					show_line = false,
					symbol_highlights = { ["function"] = "Function", method = "Method" }, -- FIX broken colors
				},
				lsp_dynamic_workspace_symbols = { -- `dynamic` = updates results on typing
					prompt_title = "󰒕 LSP workspace symbols",
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
				colorscheme = {
					prompt_title = " Colorschemes",
					enable_preview = true,
					ignore_builtins = true,
					layout_config = {
						horizontal = {
							height = 0.4,
							width = 0.3,
							anchor = "SE",
							preview_width = 1, -- needs previewer for live preview of the theme
						},
					},
				},
				spell_suggest = {
					prompt_title = "󰓆 Spell suggest",
					theme = "cursor",
					layout_config = { cursor = { width = 0.3 } },
				},
				help = {
					prompt_title = " Vim help",
				},
			},
		}
	end,
	keys = {
		{ "<leader>ik", function() vim.cmd.Telescope("keymaps") end, desc = "⌨️ Keymaps (global)" },
		{ "<leader>iv", function() vim.cmd.Telescope("help_tags") end, desc = " Vim help" },
		{ "g.", function() vim.cmd.Telescope("resume") end, desc = "󰭎 Resume" },
		{ "gf", function() vim.cmd.Telescope("lsp_references") end, desc = "󰈿 References" },
		{ "gd", function() vim.cmd.Telescope("lsp_definitions") end, desc = "󰈿 Definitions" },
		-- stylua: ignore start
		{ "gD", function() vim.cmd.Telescope("lsp_type_definitions") end, desc = "󰜁 Type definitions" },
		{ "<leader>ih", function() vim.cmd.Telescope("highlights") end, desc = " Highlights" },
		-- stylua: ignore end
		{ "<leader>gs", function() vim.cmd.Telescope("git_status") end, desc = "󰭎 Status" },
		{ "<leader>gl", function() vim.cmd.Telescope("git_commits") end, desc = "󰭎 Log" },
		{ "<leader>gb", function() vim.cmd.Telescope("git_branches") end, desc = "󰭎 Branches" },
		{ "gr", function() vim.cmd.Telescope("oldfiles") end, desc = "󰭎 Recent files" },
		{ "zl", function() vim.cmd.Telescope("spell_suggest") end, desc = "󰓆 Spell suggest" },

		{ "gl", function() vim.cmd.Telescope("live_grep") end, desc = "󰭎 Live grep" },
		{
			"gL",
			function()
				require("telescope.builtin").live_grep { default_text = vim.fn.expand("<cword>") }
			end,
			desc = "󰭎 Live grep cword",
		},

		{
			"<leader>pc",
			-- `noautocmds` to leave out the backdrop, so the colorscheme is previewable
			function() vim.cmd("noautocmd Telescope colorscheme") end,
			desc = " Preview colorschemes",
		},
		{
			"g!",
			function()
				-- open all files in cwd of same ft, ensures workspace
				-- diagnostics are exhaustive
				local currentFile = vim.api.nvim_buf_get_name(0)
				local ext = currentFile:match("%w+$")
				vim.cmd.args("**/*." .. ext) -- opens files matching glob
				vim.cmd.buffer(currentFile) -- stay at original buffer
				local msg = ("Opened %d %s files."):format(vim.fn.argc(), ext)
				vim.notify(msg, nil, { title = "Workspace diagnostics", icon = "󰋽" })

				vim.cmd.Telescope("diagnostics")
			end,
			desc = "󰋼 Workspace diagnostics",
		},
		{
			"gw",
			function()
				-- Due to `lazydev`, the whole nvim runtime is added to the
				-- workspace, making this picker much too crowded.
				-- `file_ignore_patterns` is thus set to ignore symbols from plugins
				-- and nvim core. However, the nvim config itself should only be
				-- ignored when not in the nvim config directory (e.g., in a plugin
				-- dir). To achieve that, we have to dynamically decide here whether
				-- to ignore it.
				local isInNvimConfig = vim.uv.cwd() == vim.fn.stdpath("config")
				local ignore = nil
				if not isInNvimConfig then
					local pickerIgnore =
						require("telescope.config").pickers.lsp_dynamic_workspace_symbols.file_ignore_patterns
					ignore = vim.deepcopy(pickerIgnore or {})
					table.insert(ignore, vim.fn.stdpath("config"))
				end
				require("telescope.builtin").lsp_dynamic_workspace_symbols {
					file_ignore_patterns = ignore,
				}
			end,
			desc = "󰒕 Workspace symbols",
		},
		{
			"go",
			function()
				-- ignore current file, since using the `rg` workaround puts it on top
				local ignore =
					vim.deepcopy(require("telescope.config").values.file_ignore_patterns or {})
				local cwd = vim.uv.cwd() or ""
				local relPathCurrent = "^"
					.. vim.pesc(vim.api.nvim_buf_get_name(0):sub(#cwd + 2))
					.. "$"
				table.insert(ignore, relPathCurrent)

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
					file_ignore_patterns = ignore,
					path_display = function(_, path)
						local tail = vim.fs.basename(path)
						local parent = vim.fs.dirname(path) == "." and "" or vim.fs.dirname(path)
						local out = tail .. "  " .. parent
						local highlights = {
							{ { #tail, #out }, "TelescopeResultsComment" },
						}
						if vim.tbl_contains(changedFilesInCwd, path) then
							table.insert(highlights, { { 0, #tail }, "diffChanged" })
						end
						return out, highlights
					end,
				}
			end,
			desc = "󰭎 Open file",
		},
		{
			"gs",
			function()
				-- using treesitter symbols instead, since the LSP symbols are crowded
				-- with anonymous functions
				if vim.bo.filetype == "lua" then
					vim.cmd.Telescope("treesitter")
					return
				end
				local symbolFilter = {
					yaml = { "object", "array" },
					json = "module",
					toml = "object",
					markdown = "string", -- string -> markdown headings
				}
				-- stylua: ignore
				local ignoreSymbols = { "variable", "constant", "number", "package", "string", "object", "array", "boolean", "property" }
				local filter = symbolFilter[vim.bo.filetype]
				local opts = filter and { symbols = filter } or { ignore_symbols = ignoreSymbols }
				require("telescope.builtin").lsp_document_symbols(opts)
			end,
			desc = "󰒕 Symbols",
		},
	},
}
