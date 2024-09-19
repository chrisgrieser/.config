local M = {}
--------------------------------------------------------------------------------

M.insertMode = {
	["?"] = "which_key",
	["<Tab>"] = "move_selection_worse",
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
	["<D-s>"] = "smart_send_to_qflist",

	["<D-c>"] = function(prompt_bufnr) -- copy value
		local value = require("telescope.actions.state").get_selected_entry().value
		require("telescope.actions").close(prompt_bufnr)
		vim.fn.setreg("+", value)
		vim.notify(value, vim.log.levels.INFO, { title = "Copied" })
	end,
	["<M-CR>"] = function(prompt_bufnr) -- mapping consistent with fzf-multi-select
		require("telescope.actions").toggle_selection(prompt_bufnr)
		require("telescope.actions").move_selection_worse(prompt_bufnr)
	end,
}

M.fileActions = {
	["<D-up>"] = function(prompt_bufnr) -- cwd up
		local current_picker = require("telescope.actions.state").get_current_picker(prompt_bufnr)
		local cwd = tostring(current_picker.cwd or vim.uv.cwd()) -- cwd only set if passed as opt
		local parent_dir = vim.fs.dirname(cwd)

		require("telescope.actions").close(prompt_bufnr)
		require("telescope.builtin").find_files {
			prompt_title = vim.fs.basename(parent_dir),
			cwd = parent_dir,
		}
	end,
	["<D-l>"] = function(prompt_bufnr) -- reveal in finder
		local path = require("telescope.actions.state").get_selected_entry().value
		require("telescope.actions").close(prompt_bufnr)
		vim.system { "open", "-R", path }
	end,
	["<C-p>"] = function(prompt_bufnr) -- copy abs. path
		local relPath = require("telescope.actions.state").get_selected_entry().value
		local current_picker = require("telescope.actions.state").get_current_picker(prompt_bufnr)
		local cwd = tostring(current_picker.cwd or vim.uv.cwd()) -- cwd only set if passed as opt
		local fullpath = cwd .. "/" .. relPath
		require("telescope.actions").close(prompt_bufnr)
		vim.fn.setreg("+", fullpath)
		vim.notify(fullpath, vim.log.levels.INFO, { title = "Copied" })
	end,
	["<C-n>"] = function(prompt_bufnr) -- copy name
		local relPath = require("telescope.actions.state").get_selected_entry().value
		local name = vim.fs.basename(relPath)
		require("telescope.actions").close(prompt_bufnr)
		vim.fn.setreg("+", name)
		vim.notify(name, vim.log.levels.INFO, { title = "Copied" })
	end,
	["<C-h>"] = function(prompt_bufnr) -- toggle hidden
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
	end,
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

M.highlightsActions = {
	["<CR>"] = function(prompt_bufnr) -- copy color value
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
			vim.notify(toCopy, vim.log.levels.INFO, { title = "Copied" })
		end
	end,
}

--------------------------------------------------------------------------------
return M
