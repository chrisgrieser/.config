local M = {}
--------------------------------------------------------------------------------

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

---Warn when there are conflicting keymaps
---@param mode string|string[]
---@param lhs string
---@param rhs string|function
---@param opts? vim.keymap.set.Opts
function M.uniqKeymap(mode, lhs, rhs, opts)
	if not opts then opts = {} end

	-- allow to disable with `unique=false` to overwrite nvim defaults: https://neovim.io/doc/user/vim_diff.html#default-mappings
	if opts.unique == nil then opts.unique = true end

	-- violating `unique=true` throws an error; using `pcall` to still load other mappings
	local success, _ = pcall(vim.keymap.set, mode, lhs, rhs, opts)
	if success then return end
	local modes = type(mode) == "table" and table.concat(mode, ", ") or mode
	local msg = ("**Duplicate keymap**\n[[%s]] %s"):format(modes, lhs)
	vim.defer_fn(function() -- defer for notification plugin
		vim.notify(msg, vim.log.levels.WARN, { title = "User keybindings", timeout = false })
	end, 1000)
end

---sets `buffer`, `silent` and `nowait` to true
---@param mode string|string[]
---@param lhs string
---@param rhs string|function
---@param opts? vim.keymap.set.Opts
function M.bufKeymap(mode, lhs, rhs, opts)
	opts = vim.tbl_extend("force", { buffer = true, nowait = true }, opts or {})
	vim.keymap.set(mode, lhs, rhs, opts)
end

---@param maps {[1]: string, [2]: string|function, mode?: string|string[], desc?: string, nowait?: boolean, ft?: string|string[], remap?: boolean, unique?: boolean, expr?: boolean}[]
function M.pluginKeymaps(maps)
	for _, map in ipairs(maps) do
		local opts = {
			desc = map.desc,
			nowait = map.nowait,
			remap = map.remap,
			unique = map.unique,
			expr = map.expr,
		}
		if not map.ft then
			M.uniqKeymap(map.mode or "n", map[1], map[2], opts)
		else
			local filetypes = type(map.ft) == "string" and { map.ft } or map.ft ---@cast filetypes string[]
			vim.api.nvim_create_autocmd("FileType", {
				desc = "User: plugin ft-keymap",
				callback = function(ctx)
					if not vim.tbl_contains(filetypes, ctx.match) then return end
					M.bufKeymap(map.mode or "n", map[1], map[2], opts)
				end,
			})
		end
	end
end

---@param text string
---@param replace string
function M.bufAbbrev(text, replace) vim.keymap.set("ia", text, replace, { buffer = true }) end

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
