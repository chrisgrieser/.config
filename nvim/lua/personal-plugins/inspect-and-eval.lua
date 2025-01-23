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
	vim.notify(table.concat(out, "\n"), vim.log.levels.DEBUG, opts)
end

function M.nodeAtCursor()
	local config = { hlDuration = 1500, hlGroup = "Search", maxChildren = 4 }

	local ok, node = pcall(vim.treesitter.get_node)
	if not (ok and node) then
		vim.notify("No node under cursor", vim.log.levels.DEBUG, { icon = "" })
		return
	end

	-- node info
	local parent = node:parent() and node:parent():type() or "."
	local tree = { parent, "└── " .. node:type() .. " (this node)" }
	for childIdx = 1, config.maxChildren do
		local child = node:child(childIdx)
		if not child then break end
		table.insert(tree, ("      ├── %s"):format(child:type()))
	end
	tree[#tree] = tree[#tree]:gsub("├", "└")
	local msg = table.concat(tree, "\n")
	vim.notify(msg, vim.log.levels.DEBUG, { icon = "", title = "Node at cursor" })

	-- highlight the full node
	local startRow, startCol = node:start()
	local endRow, endCol = node:end_()
	local ns = vim.api.nvim_create_namespace("node-highlight")
	if startRow == endRow then
		vim.api.nvim_buf_add_highlight(0, ns, config.hlGroup, startRow, startCol, endCol)
	else
		vim.api.nvim_buf_add_highlight(0, ns, config.hlGroup, startRow, startCol, -1)
		local lnum = startRow + 1
		while lnum < endRow do
			vim.api.nvim_buf_add_highlight(0, ns, config.hlGroup, lnum, 0, -1)
			lnum = lnum + 1
		end
		vim.api.nvim_buf_add_highlight(0, ns, config.hlGroup, endRow, 0, endCol)
	end
	vim.defer_fn(function() vim.api.nvim_buf_clear_namespace(0, ns, 0, -1) end, config.hlDuration)

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
		vim.ui.input({ prompt = " Eval: ", win = { ft = "lua" } }, eval)
	else
		vim.cmd.normal { '"zy', bang = true }
		eval(vim.fn.getreg("z"))
	end
end

function M.runFile()
	vim.cmd("silent update")
	local filepath = vim.api.nvim_buf_get_name(0)
	local ft = vim.bo.filetype
	if ft == "lua" and filepath:find("nvim") then
		vim.cmd.source()
		return
	end

	local cmd
	if ft == "zsh" or ft == "bash" or ft == "sh" then
		cmd = ft
	else
		local msg = ("Filetype %q not supported."):format(ft)
		vim.notify(msg, vim.log.levels.WARN, { title = "Run", icon = "󰜎" })
		return
	end

	vim.system({ cmd, filepath }, {}, function(out)
		local msg = vim.trim(out.stdout .. "\n" .. out.stderr)
		local lvl = out.code == 0 and "INFO" or "ERROR"
		vim.notify(msg, vim.log.levels[lvl], { title = "Run", icon = "󰜎" })
	end)
end

--------------------------------------------------------------------------------
return M
