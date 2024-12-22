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
	if opts.unique == nil then opts.unique = true end -- allows to disable with `unique=false`

	-- violating `unique=true` throws an error; using `pcall` so other mappings
	-- are still loaded
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

--------------------------------------------------------------------------------
return M
