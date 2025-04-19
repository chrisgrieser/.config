-- INFO This snippet redirects cmdline messages to `vim.notify`, silencing
-- `Press Enter to continue` prompts, even with `cmdheight=0`.

-- REQUIRED a plugin that shows `vim.notify` outside of the cmdline, such as
-- `nvim-notify`, `snacks.notifier`, or `mini.notify`.
--------------------------------------------------------------------------------

local config = {
	msgKind = { -- existing kinds: https://neovim.io/doc/user/ui.html#ui-messages
		ignore = {
			"search_cmd",
			"return_prompt",
		},
		mini = { -- more minimal style when `snacks.notifier` is used
			"bufwrite",
			"undo",
		},
	},
	notification = {
		icon = "󰍩",
	},
}

--------------------------------------------------------------------------------

local ns = vim.api.nvim_create_namespace("ui-hack")

local function attach()
	---@diagnostic disable-next-line: redundant-parameter incomplete annotation from nvim core
	vim.ui_attach(ns, { ext_messages = true }, function(event, ...)
		-- only affect `msg_show` events
		if event == "msg_history_show" then
			local msg = "`:messages` is not, supported but t is also not needed anymore. "
				.. "Simply use the history command of your notification plugin to see past messages."
			vim.notify(msg, vim.log.levels.WARN)
		end
		if event ~= "msg_show" then return end

		-- ignore & deal with "press enter to continue" prompts
		local kind, content, _replace, _history = ... -- for `msg_show` only https://neovim.io/doc/user/ui.html#ui-messages
		if kind == "return_prompt" then -- we're still being blocked, so we need to feedkey `<CR>`
			local esc = vim.api.nvim_replace_termcodes("<CR>", true, true, true)
			vim.api.nvim_feedkeys(esc, "n", false)
		end
		if vim.list_contains(config.msgKind.ignore, kind) then return end

		-- notification text and options
		local text = vim.iter(content):fold("", function(acc, chunk) return acc .. chunk[2] end)
		text = vim.trim(text):gsub("^(E%d+):", "[%1]") -- colorize error code when using `snacks`

		local level = vim.log.levels.INFO
		if kind == "emsg" or vim.endswith(kind, "error") or vim.endswith(kind, "err") then
			level = vim.log.levels.ERROR
		elseif kind == "wmsg" then
			level = vim.log.levels.WARN
		end

		local opts = { title = kind, icon = config.notification.icon }
		if vim.list_contains(config.msgKind.mini, kind) and package.loaded["snacks"] then
			opts.style = "minimal"
			if opts.icon then opts.icon = " " .. opts.icon .. " " end
		end
		if vim.startswith(kind, "lua_") then opts.ft = "lua" end

		vim.schedule(function() vim.notify(text, level, opts) end)
	end)
end

local function detach() vim.ui_detach(ns) end

--------------------------------------------------------------------------------

attach() -- initialize
local group = vim.api.nvim_create_augroup("ui-hack", { clear = true })
vim.api.nvim_create_autocmd("CmdlineEnter", { group = group, callback = detach })
vim.api.nvim_create_autocmd("CmdlineLeave", { group = group, callback = attach })
