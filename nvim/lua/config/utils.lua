local M = {}
--------------------------------------------------------------------------------

---Warn when there are conflicting keymaps
---@param mode string|string[]
---@param lhs string
---@param rhs string|function
---@param opts? vim.keymap.set.Opts
function M.uniqueKeymap(mode, lhs, rhs, opts)
	if not opts then opts = {} end

	-- allow to disable with `unique=false` to overwrite nvim defaults: https://neovim.io/doc/user/vim_diff.html#default-mappings
	if opts.unique == nil then opts.unique = true end

	-- violating `unique=true` throws an error; using `pcall` to still load other mappings
	local success, _ = pcall(vim.keymap.set, mode, lhs, rhs, opts)
	if not success then
		local modes = type(mode) == "table" and table.concat(mode, ", ") or mode
		local msg = ("**Duplicate keymap**\n[[%s]] %s"):format(modes, lhs)
		vim.defer_fn(function() -- defer for notification plugin
			vim.notify(msg, vim.log.levels.WARN, { title = "User keybindings", timeout = false })
		end, 1000)
	end
end

---sets `buffer`, `silent` and `nowait` to true
---@param mode string|string[]
---@param lhs string
---@param rhs string|function
---@param opts? vim.keymap.set.Opts
function M.bufKeymap(mode, lhs, rhs, opts)
	opts = vim.tbl_extend("force", { buffer = true, silent = true, nowait = true }, opts or {})
	vim.keymap.set(mode, lhs, rhs, opts)
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

---@param bufnr integer
---@param filepath string
---@return boolean -- return `false` to disable on this buffer
function M.allowBufferForAi(bufnr, filepath)
	-- INFO plugins are disabled when using `pass` via `$USING_PASS`, for safety
	-- adding redundant safeguards to disable AI for those buffers nonetheless

	if not filepath then filepath = vim.api.nvim_buf_get_name(bufnr) end
	if vim.fn.reg_recording() ~= "" then return false end -- disable when recording
	if vim.bo[bufnr].buftype ~= "" then return false end
	if vim.bo[bufnr].filetype == "text" then return false end -- disable, since `txt` used by `pass` and others
	if vim.bo[bufnr].filetype == "bib" then return false end -- too large and not useful
	if vim.bo[bufnr].filetype == "csv" then return false end -- too large / sensitive data
	if not vim.fs.basename(filepath):find("%.") then return false end -- extensionless file

	local pathsToIgnore = {
		"security",
		"leetcode/", -- should do leetcode problems on my own
		"/private/var/", -- path when editing in `pass` (extra safeguard)
		"api-key",
		".env",
		"recovery", -- e.g., password recovery files
	}
	local ignorePath = vim.iter(pathsToIgnore)
		:any(function(ignored) return filepath:lower():find(ignored, 1, true) ~= nil end)

	if ignorePath then
		vim.notify_once("Disabled AI on this buffer.")
		return false --> return `false` to disable
	else
		return true
	end
end

--------------------------------------------------------------------------------
return M
