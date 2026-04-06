---Warn when there are conflicting keymaps & use API similar to lazy.nvim keymaps
---@param map vim.keymap.set.Opts|{mode: string|string[], ft: string|string[], [1]: string, [2]: string|function}
_G.Keymap = function(map)
	local mode = map.mode or "n"
	local lhs, rhs = map[1], map[2]
	local opts = {
		desc = map.desc,
		nowait = map.nowait,
		remap = map.remap,
		unique = map.unique,
		expr = map.expr,
	}
	local globalMap = not map.ft

	if globalMap then
		-- allow to disable with `unique=false` to overwrite nvim defaults: https://neovim.io/doc/user/vim_diff.html#default-mappings
		if opts.unique == nil then opts.unique = true end

		-- violating `unique=true` throws an error; using `pcall` to still load other mappings
		local success, _ = pcall(vim.keymap.set, mode, lhs, rhs, opts)
		if success then return end

		local modes = type(mode) == "table" and table.concat(mode, ", ") or mode
		local caller = debug.getinfo(2, "Sl") -- S: source, l: currentline
		local source = vim.fs.basename(caller.source)
		local msg = ("`(%s)`  %s  **%s:%d**"):format(modes, lhs, source, caller.currentline)

		vim.defer_fn(function() -- defer for notification plugin
			vim.notify(msg, vim.log.levels.WARN, { title = "Duplicate keymap", timeout = false })
		end, 1000)
	else
		vim.api.nvim_create_autocmd("FileType", {
			desc = "User: plugin filetype-keymap",
			pattern = map.ft,
			callback = function(ctx)
				opts.buffer = ctx.buf
				opts.nowait = true
				vim.keymap.set(mode, lhs, rhs, opts)
			end,
		})
		return
	end
end

---@param map vim.keymap.set.Opts|{mode: string|string[], ft: string|string[], [1]: string, [2]: string|function}
---@param bufnr? number
_G.Bufmap = function(map, bufnr)
	map.buf = bufnr or 0
	map.unique = false -- usually overwriting a global keymap
	Keymap(map)
end

---@param text string
---@param replace string
_G.BufAbbr = function(text, replace) vim.keymap.set("ia", text, replace, { buffer = true }) end

--------------------------------------------------------------------------------
local M = {}

---Try to require the module, but do not throw an error when one of them cannot
---be loaded. Without this, any error in one config file would result in the
---remaining config files not being loaded.
---@param module string
function M.safeRequire(module)
	local success, errmsg = pcall(require, module)
	if success then return end

	local msg = ("Error loading `%s`: %s"):format(module, errmsg)
	vim.defer_fn(function() -- defer for notification plugin
		vim.notify(msg, vim.log.levels.ERROR, { title = "User config", timeout = false })
	end, 1000)
end

function M.loadGhToken()
	if vim.env.GITHUB_TOKEN then return end
	local tokenPath = os.getenv("HOME")
		.. "/Library/Mobile Documents/com~apple~CloudDocs/Tech/api-keys/github-token.txt"
	local file = io.open(tokenPath, "r")
	if not file then
		vim.notify("Could not find file for `GITHUB_TOKEN`.", vim.log.levels.ERROR)
		return
	end
	vim.env.GITHUB_TOKEN = file:read("*l") -- read first line
	file:close()
end

--------------------------------------------------------------------------------
return M
