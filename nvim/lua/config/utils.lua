---@class MyConfig.Keymap : vim.keymap.set.Opts
---@field [1] string -- lhs
---@field [2] string|function -- rhs
---@field mode? string|string[] -- defaults to "n"
---@field ft? string|string[] keymap only for these filetypes

---Warn when there are conflicting keymaps & use API similar to lazy.nvim keymaps
---@param map MyConfig.Keymap
_G.Keymap = function(map)
	local mode = map.mode or "n"
	local lhs, rhs = map[1], map[2]
	local opts = vim.deepcopy(map)
	opts.ft, opts.mode, opts[1], opts[2] = nil, nil, nil, nil

	local caller = debug.getinfo(2, "Sl") -- S: source, l: currentline
	local source = vim.fs.basename(caller.source) .. ":" .. caller.currentline

	if map[3] then
		vim.defer_fn(function()
			local msg = ("%s  **%s**"):format(lhs, source)
			vim.notify(msg, vim.log.levels.WARN, { title = "Keymap with 3 args", timeout = false })
		end, 1000)
		return
	end

	if not map.ft then
		-- GLOBAL keymap
		-- 1. allow to disable with `unique=false` to overwrite nvim defaults
		-- 2. do not set `unique` for buffer-specific maps, since they are supposed
		--    to overwrite global ones
		if opts.unique == nil and opts.buf == nil then opts.unique = true end

		-- violating `unique=true` throws an error; using `pcall` to still load other mappings
		local success, _ = pcall(vim.keymap.set, mode, lhs, rhs, opts)
		if success then return end

		local modes = type(mode) == "table" and table.concat(mode, ", ") or mode
		local msg = ("`(%s)`  %s  **%s**"):format(modes, lhs, source)

		vim.defer_fn(function() -- defer for notification plugin
			vim.notify(msg, vim.log.levels.WARN, { title = "Duplicate keymap", timeout = false })
		end, 1000)
	else
		-- FILETYPE keymap
		vim.api.nvim_create_autocmd("FileType", {
			desc = "User: plugin filetype-keymap",
			pattern = map.ft,
			callback = function(ctx)
				opts.buf = ctx.buf
				vim.keymap.set(mode, lhs, rhs, opts)
			end,
		})
	end
end

---@param map MyConfig.Keymap
_G.Bufmap = function(map)
	map.buf = 0
	Keymap(map)
end

---@param text string
---@param replace string
_G.BufAbbr = function(text, replace) vim.keymap.set("ia", text, replace, { buf = 0 }) end

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
