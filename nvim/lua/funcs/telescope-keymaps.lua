local M = {}
local u = require("config.utils")
--------------------------------------------------------------------------------

local function copyValue(prompt_bufnr)
	local value = require("telescope.actions.state").get_selected_entry().value
	require("telescope.actions").close(prompt_bufnr)
	u.copyAndNotify(value)
end

M.insertMode = {
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
	["<D-c>"] = { copyValue, type = "action", opts = { desc = "󰅍 Copy value" } },
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
M.normalMode = vim.tbl_extend("force", M.insertMode, {
	["j"] = "move_selection_worse",
	["k"] = "move_selection_better",
	["q"] = {
		-- extra stuff needed to be able to set `nowait` for `q`
		function(prompt_bufnr) require("telescope.actions").close(prompt_bufnr) end,
		type = "action",
		opts = { nowait = true, desc = "close" },
	},
})

function M.toggleHidden(prompt_bufnr)
	local current_picker = require("telescope.actions.state").get_current_picker(prompt_bufnr)
	local cwd = tostring(current_picker.cwd or vim.uv.cwd()) -- cwd only set if passed as opt

	-- hidden status not stored, but title is, so we determine the previous state via title
	local prevTitle = current_picker.prompt_title
	local ignoreHidden = not prevTitle:find("hidden")

	local title = "Find Files: " .. vim.fs.basename(cwd)
	if ignoreHidden then title = title .. " (--hidden --no-ignore)" end
	local currentQuery = require("telescope.actions.state").get_current_line()

	require("telescope.actions").close(prompt_bufnr)
	require("telescope.builtin").find_files {
		default_text = currentQuery,
		prompt_title = title,
		hidden = ignoreHidden,
		no_ignore = ignoreHidden,
		cwd = cwd,
	}
end

function M.copyColorValue(prompt_bufnr)
	local hlName = require("telescope.actions.state").get_selected_entry().value
	require("telescope.actions").close(prompt_bufnr)
	local value = vim.api.nvim_get_hl(0, { name = hlName })
	local out = {}
	if value.fg then table.insert(out, ("#%06x"):format(value.fg)) end
	if value.bg then table.insert(out, ("#%06x"):format(value.bg)) end
	u.copyAndNotify(table.concat(out, "\n"))
end

--------------------------------------------------------------------------------

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
return M