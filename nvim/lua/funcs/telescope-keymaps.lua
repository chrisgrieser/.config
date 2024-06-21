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

	local ignore = vim.deepcopy(require("telescope.config").values.file_ignore_patterns or {})
	local findCommand = vim.deepcopy(require("telescope.config").pickers.find_files.find_command)
	if ignoreHidden then
		vim.list_extend(ignore, { "node_modules", ".venv", "typings", "%.DS_Store$", "%.git/" })
		-- cannot simply toggle `hidden` since we are using `rg` as custom find command
		vim.list_extend(findCommand, { "--hidden", "--no-ignore", "--no-ignore-file" })
		vim.notify("👾 findCommand: " .. vim.inspect(findCommand))
	end

	require("telescope.actions").close(prompt_bufnr)
	require("telescope.builtin").find_files {
		default_text = currentQuery,
		prompt_title = title,
		find_command = findCommand,
		cwd = cwd,
		file_ignore_patterns = ignore,
	}
end

function M.copyColorValue(prompt_bufnr)
	local hlName = require("telescope.actions.state").get_selected_entry().value
	require("telescope.actions").close(prompt_bufnr)
	local value = vim.api.nvim_get_hl(0, { name = hlName })
	local out = {}
	if value.fg then table.insert(out, ("#%06x"):format(value.fg)) end
	if value.bg then table.insert(out, ("#%06x"):format(value.bg)) end
	if value.link then table.insert(out, "link: " .. value.link) end
	if #out > 0 then u.copyAndNotify(table.concat(out, "\n")) end
end

--------------------------------------------------------------------------------
return M
