-- INFO
-- These functions all use the log level `DEBUG`. To be able to see them with
-- `nvim-notify`, you need to set the minimum level in the nvim-notify config:
-- `require("notify").setup { level = "2" }`.
--------------------------------------------------------------------------------
local M = {}
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
	vim.notify(table.concat(out, "\n"), vim.log.levels.DEBUG, opts)
end

function M.nodeUnderCursor()
	local ok, node = pcall(vim.treesitter.get_node)
	if not (ok and node) then
		vim.notify("No node under cursor", vim.log.levels.DEBUG, { icon = "" })
		return
	end
	vim.notify(node:type(), vim.log.levels.DEBUG, { icon = "", title = "Node under cursor" })

	-- highlight the full node
	local duration, hlgroup = 1500, "Search" -- CONFIG
	local startRow, startCol = node:start()
	local endRow, endCol = node:end_()
	local ns = vim.api.nvim_create_namespace("node-highlight")
	if startRow == endRow then
		vim.api.nvim_buf_add_highlight(0, ns, hlgroup, startRow, startCol, endCol)
	else
		vim.api.nvim_buf_add_highlight(0, ns, hlgroup, startRow, startCol, -1)
		local lnum = startRow + 1
		while lnum < endRow do
			vim.api.nvim_buf_add_highlight(0, ns, hlgroup, lnum, 0, -1)
			lnum = lnum + 1
		end
		vim.api.nvim_buf_add_highlight(0, ns, hlgroup, endRow, 0, endCol)
	end
	vim.defer_fn(function() vim.api.nvim_buf_clear_namespace(0, ns, 0, -1) end, duration)

	-- FIX on_key being triggered by `n` key (only needed for my personal config)
	-- see https://www.reddit.com/r/neovim/comments/1h051ht/comment/m01r7ju/?utm_source=share&utm_medium=web3x&utm_name=web3xcss&utm_term=1
	vim.defer_fn(function()
		local countNs = vim.api.nvim_create_namespace("searchCounter")
		vim.api.nvim_buf_clear_namespace(0, countNs, 0, -1)
	end, 1)
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
		vim.notify(text, vim.log.levels.DEBUG, opts)
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
		vim.notify(vim.inspect(out), vim.log.levels.DEBUG, opts)
	end

	if vim.fn.mode() == "n" then
		vim.api.nvim_create_autocmd("FileType", {
			desc = "User(once): Add lua highlighting to `DressingInput` for Eval command",
			once = true,
			pattern = "DressingInput",
			command = "set filetype=lua",
		})
		vim.ui.input({ prompt = " Eval: " }, eval)
	else
		vim.cmd.normal { '"zy', bang = true }
		eval(vim.fn.getreg("z"))
	end
end

function M.runFile()
	vim.cmd("silent update")
	local hasShebang = vim.api.nvim_buf_get_lines(0, 0, 1, false)[1]:find("^#!")
	local filepath = vim.api.nvim_buf_get_name(0)
	if vim.bo.filetype == "lua" and filepath:find("nvim") then
		vim.cmd.source()
	elseif hasShebang then
		vim.cmd("! chmod +x %")
		vim.cmd("! %")
	else
		vim.notify("File has no shebang.", vim.log.levels.WARN, { title = "Run", icon = "󰜎" })
	end
end

--------------------------------------------------------------------------------
return M
