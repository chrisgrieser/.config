-- FIX / PENDING https://github.com/nvim-telescope/telescope.nvim/issues/3436
local initialWinborder = vim.o.winborder
vim.api.nvim_create_autocmd("User", {
	pattern = "TelescopeFindPre",
	callback = function()
		vim.opt.winborder = "none"
		vim.api.nvim_create_autocmd("WinLeave", {
			once = true,
			callback = function() vim.opt.winborder = initialWinborder end,
		})
	end,
})

--------------------------------------------------------------------------------

local borderChars = { "─", "│", "─", "│", "┌", "┐", "┘", "└" }
if vim.o.winborder == "double" then
	borderChars = { "═", "║", "═", "║", "╔", "╗", "╝", "╚" }
elseif vim.o.winborder == "rounded" then
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
	group = vim.api.nvim_create_augroup("TelescopeFix", {}),
	desc = "User: FIX `sidescrolloff` for Telescope",
	pattern = "TelescopePrompt",
	command = "setlocal sidescrolloff=1",
})


--------------------------------------------------------------------------------

return {
	"nvim-telescope/telescope.nvim",
	cmd = "Telescope",
	dependencies = { "nvim-lua/plenary.nvim", "echasnovski/mini.icons" },
	config = function()
		require("telescope").setup {
			defaults = {
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
						["<D-Up>"] = "move_to_top",
						["<CR>"] = "select_default",
						["<Esc>"] = "close", -- = disables normal mode for Telescope

						["<PageDown>"] = "preview_scrolling_down",
						["<PageUp>"] = "preview_scrolling_up",
						["<Up>"] = "cycle_history_prev",
						["<Down>"] = "cycle_history_next",
						["<D-s>"] = "smart_send_to_qflist",

						["<D-c>"] = function(promptBufnr) -- copy_value
							local value = require("telescope.actions.state").get_selected_entry().value
							require("telescope.actions").close(promptBufnr)
							vim.fn.setreg("+", value)
							vim.notify(value, nil, { title = "Copied", icon = "󰅍" })
						end,
						["<D-l>"] = function(prompt_bufnr) -- reveal_file_in_Finder
							local path = require("telescope.actions.state").get_selected_entry().value
							require("telescope.actions").close(prompt_bufnr)
							if jit.os == "OSX" then vim.system { "open", "-R", path } end
						end,
						-- mapping consistent with fzf-multi-select
						["<M-CR>"] = function(promptBufnr) -- multi-select
							require("telescope.actions").toggle_selection(promptBufnr)
							require("telescope.actions").move_selection_worse(promptBufnr)
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
					"%.zip", "%.pdf", "%.docx", "%.xlsx", "%.pptx",
					unpack(specialDirs), -- needs to be last for complete unpacking
				},
			},
			pickers = {
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

					-- show diffstats instead of diff preview
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

					-- show diffstats instead of simple status in the previewer
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

							-- stylua: ignore
							return { "git", "show", hash, "--color=always", "--stat=" .. statArgs, "--format=" .. format }
						end,
					},
					mappings = {
						i = { ["<C-r>"] = "git_reset_mixed" },
					},
				},
				git_branches = {
					prompt_title = "󰘬 Git branches",
					show_remote_tracking_branches = false,
					previewer = false,
					layout_config = { horizontal = { height = 0.4, width = 0.7 } },
				},
				highlights = {
					prompt_title = " Highlight groups",
					layout_config = { horizontal = { preview_width = { 0.7, min = 20 } } },
					mappings = {
						i = { -- copy highlight values
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
				quickfix = {
					prompt_title = "󰴩 Quickfix",
					trim_text = true,
				},
				quickfixhistory = {
					prompt_title = "󰴩 Quickfix history",
				},
				keymaps = {
					prompt_title = "⌨️ Keymaps",
					modes = { "n", "i", "c", "x", "o", "t" },
					show_plug = false,
				},
				help_tags = {
					prompt_title = " Vim help (search)",
					layout_config = {
						horizontal = { height = 0.8 }, -- bigger for more help
					},
					mappings = {
						i = {
							-- open help in full buffer
							["<CR>"] = function(promptBufnr)
								local entry = require("telescope.actions.state").get_selected_entry().value
								require("telescope.actions").close(promptBufnr)
								vim.cmd("help " .. entry .. " | only")
							end,
						},
					},
				},
			},
		}
	end,
	keys = {
		-- INSPECT
		-- stylua: ignore
		-- stylua: ignore

		-- QUICKFIX

		-- GIT

		-- GREP

		-- FILES
		-- LSP
	},
}
