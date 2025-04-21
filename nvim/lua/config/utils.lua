local M = {}
--------------------------------------------------------------------------------

M.extraTextobjMaps = {
	func = "f",
	call = "l",
	condition = "o",
	wikilink = "R",
}

---ensures unique keymaps https://www.reddit.com/r/neovim/comments/16h2lla/can_you_make_neovim_warn_you_if_your_config_maps/
---@param mode string|string[]
---@param lhs string
---@param rhs string|function
---@param opts? {desc?: string, unique?: boolean, buffer?: number|boolean, remap?: boolean, silent?:boolean, nowait?: boolean}
function M.uniqueKeymap(mode, lhs, rhs, opts)
	if not opts then opts = {} end

	-- allow to disable with `unique=false` to overwrites nvim defaults: https://neovim.io/doc/user/vim_diff.html#default-mappings
	if opts.unique == nil then opts.unique = true end

	-- violating `unique=true` throws error; using `pcall` to still load other mappings
	pcall(vim.keymap.set, mode, lhs, rhs, opts)
end

---sets `buffer`, `silent` and `nowait` to true
---@param mode string|string[]
---@param lhs string
---@param rhs string|function
---@param opts? {desc?: string, unique?: boolean, buffer?: number|boolean, remap?: boolean, silent?:boolean, nowait?: boolean}
function M.bufKeymap(mode, lhs, rhs, opts)
	opts = vim.tbl_extend("force", { buffer = true, silent = true, nowait = true }, opts or {})
	vim.keymap.set(mode, lhs, rhs, opts)
end

---@param text string
---@param replace string
function M.bufAbbrev(text, replace) vim.keymap.set("ia", text, replace, { buffer = true }) end

---Helper function, as ltex etc lack ignore files
---@param client vim.lsp.Client
---@param bufnr integer
function M.detachIfObsidianOrIcloud(client, bufnr)
	local path = vim.api.nvim_buf_get_name(bufnr)
	local obsiDir = #vim.fs.find(".obsidian", { path = path, upward = true, type = "directory" }) > 0
	local iCloudDocs = vim.startswith(path, os.getenv("HOME") .. "/Library/Mobile Documents/")
	if obsiDir or (iCloudDocs and client.name ~= "ltex_plus") then
		-- defer to ensure client is already attached
		vim.defer_fn(function() vim.lsp.buf_detach_client(bufnr, client.id) end, 500)
	end
end

--------------------------------------------------------------------------------
return M
