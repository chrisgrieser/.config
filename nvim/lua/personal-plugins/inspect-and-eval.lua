local M = {}

-- INFO by default, `nvim-notify` does not display notifications of the level `DEBUG`
local lvl = "DEBUG"

--------------------------------------------------------------------------------

function M.bufferInfo()
	local pseudoTilde = "∼" -- HACK `U+223C` instead of real `~` to prevent md-strikethrough

	local clients = vim.lsp.get_clients { bufnr = 0 }
	local longestName = vim.iter(clients)
		:fold(0, function(acc, client) return math.max(acc, #client.name) end)
	local lsps = vim.tbl_map(function(client)
		local pad = (" "):rep(math.min(longestName - #client.name)) .. " "
		local root = client.root_dir and client.root_dir:gsub("/Users/%w+", pseudoTilde)
			or "*Single file mode*"
		return ("[%s]%s%s"):format(client.name, pad, root)
	end, clients)

	local indentType = vim.bo.expandtab and "spaces" or "tabs"
	local indentAmount = vim.bo.expandtab and vim.bo.tabstop or vim.bo.shiftwidth

	local out = {
		"[bufnr]     " .. vim.api.nvim_get_current_buf(),
		"[winid]     " .. vim.api.nvim_get_current_win(),
		"[filetype]  " .. (vim.bo.filetype == "" and '""' or vim.bo.filetype),
		"[buftype]   " .. (vim.bo.buftype == "" and '""' or vim.bo.buftype),
		("[indent]    %s (%s)"):format(indentType, indentAmount),
		"[cwd]       " .. (vim.uv.cwd() or "nil"):gsub("/Users/%w+", pseudoTilde),
		"",
	}
	if #lsps > 0 then
		vim.list_extend(out, { "**Attached LSPs with root**", unpack(lsps) })
	else
		vim.list_extend(out, { "*No LSPs attached.*" })
	end
	local opts = { title = "Inspect buffer", icon = "󰽙", timeout = 10000 }
	vim.notify(table.concat(out, "\n"), vim.log.levels[lvl], opts)
end

function M.lspCapabilities()
	local clients = vim.lsp.get_clients { bufnr = 0 }
	if #clients == 0 then
		vim.notify("No LSPs attached.", vim.log.levels.WARN, { icon = "󱈄" })
		return
	end
	vim.ui.select(clients, {
		prompt = "󱈄 Select LSP:",
		kind = "plain",
		format_item = function(client) return client.name end,
	}, function(client)
		if not client then return end
		local info = {
			capabilities = client.capabilities,
			server_capabilities = client.server_capabilities,
			config = client.config,
		}
		local opts = { icon = "󱈄", title = client.name .. " capabilities", ft = "lua" }
		local header = "-- for a full view, open in notification history\n"
		local text = header .. vim.inspect(info)
		vim.notify(text, vim.log.levels[lvl], opts)
	end)
end

-- compared to `:lua=`, this use `vim.ui.input` as proper input field with vim
-- motions and highlighting instead of the vim cmdline, and `vim.notify` for
-- nicer output
function M.evalNvimLua()
	local function eval(input)
		if not input or input == "" then return end
		local out = vim.fn.luaeval(input)
		local opts = { title = "Eval", icon = "", ft = "lua" }
		vim.notify(vim.inspect(out), vim.log.levels[lvl], opts)
	end

	if vim.fn.mode() == "n" then
		vim.ui.input({ prompt = " Eval: ", win = { ft = "lua" } }, eval)
	else
		vim.cmd.normal { '"zy', bang = true }
		eval(vim.fn.getreg("z"))
	end
end

--------------------------------------------------------------------------------
return M
