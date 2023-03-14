local function indentation()
	local out = ""
	local usesSpaces = vim.bo.expandtab
	local ft = vim.bo.filetype
	local spaceFiletypes = {"python", "yaml"}
	local ignoredFiletypes = { "css", "markdown", "lazy", "" }
	if
		vim.tbl_contains(ignoredFiletypes, ft)
		or vim.fn.mode() == "i"
		or vim.bo.buftype ~= ""
	then
		return ""
	end

	-- non-default indentation
	if usesSpaces and not vim.tbl_contains(spaceFiletypes, ft) then 
		out = out .. tostring(bo.tabstop) .." spaces"
	elseif not usesSpaces and vim.tbl_contains(spaceFiletypes, ft) then 
		out = out .. "tabs"
	end

	-- mixed indentation
	local hasTabs = vim.fn.search("^\t", "nw") > 0
	local hasSpaces = vim.fn.search("^ ", "nw") > 0
	local mixed = vim.fn.search([[^\(\t\+ \| \+\t\)]], "nw") ~= 0

	if (hasSpaces and hasTabs) or mixed then
		out = out .. "  st!"
	elseif hasSpaces and not usesSpaces then
		out = out .. "s!"
	elseif hasTabs and usesSpaces then
		out = out .. "t!"
	end
	if out ~= "" then out = " " .. out end
	return out
end

-- show branch info only when *not* on main/master
vim.api.nvim_create_augroup("branchChange", {})
vim.api.nvim_create_autocmd({ "BufEnter", "FocusGained", "WinEnter", "TabEnter" }, {
	group = "branchChange",
	callback = function()
		vim.g.cur_branch = vim.fn.system("git --no-optional-locks branch --show-current"):gsub("\n$", "")
	end,
})

local function isStandardBranch() -- not checking for branch here, since running the condition check too often results in lock files and also makes the cursor glitch for whatever reason…
	local branch = vim.g.cur_branch
	local notMainBranch = branch ~= "main" and branch ~= "master"
	local validFiletype = vim.bo.filetype ~= "help" -- vim help files are located in a git repo
	return notMainBranch and validFiletype
end

local function selectionCount()
	local isVisualMode = vim.fn.mode():find("[Vv]")
	if not isVisualMode then return "" end
	local starts = vim.fn.line("v")
	local ends = vim.fn.line(".")
	local lines = starts <= ends and ends - starts + 1 or starts - ends + 1
	return " " .. tostring(lines) .. "L " .. tostring(vim.fn.wordcount().visual_chars) .. "C"
end

local function searchCounter()
	if vim.fn.mode() ~= "n" or vim.v.hlsearch == 0 then return "" end
	local total = vim.fn.searchcount().total
	local current = vim.fn.searchcount().current
	local searchTerm = vim.fn.getreg("/")
	local isStarSearch = searchTerm:find([[^\<.*\>$]])
	if isStarSearch then searchTerm = "*" .. searchTerm:sub(3, -3) end
	if total == 0 then return " 0 " .. searchTerm end
	return " " .. current .. "/" .. total .. " " .. searchTerm
end

local function clock()
	if vim.opt.columns:get() < 120 then return "" end -- only show the clock when it covers my menubar clock
	local time = tostring(os.date()):sub(12, 16)

	-- make the `:` blink
	if os.time() % 2 == 1 then time = time:gsub(":", " ") end

	return time
end

---returns a harpoon icon if the current file is marked in Harpoon. Does not
---`require` itself, so won't load Harpoon (for when lazyloading Harpoon)
---@return string empty string when not marked
local function harpoonIndicator()
	local harpoonJsonPath = vim.fn.stdpath("data") .. "/harpoon.json"
	local harpoonJson = ReadFile(harpoonJsonPath)
	if not harpoonJson then
		vim.notify("harpoon.json not valid", logWarn)
		return ""
	end
	local harpoonData = vim.json.decode(harpoonJson)
	local pwd = vim.loop.cwd()
	local currentProject = harpoonData.projects[pwd]
	local markedFiles = currentProject.mark.marks
	local currentFile = expand("%")

	for _, file in pairs(markedFiles) do
		if file.filename == currentFile then return "ﯠ" end
	end
	return ""
end

--------------------------------------------------------------------------------
-- LSP-RELATED STATUS COMPONENTS

local navic = require("nvim-navic")

local function showNavic() return navic.is_available() and not (bo.filetype == "css") end

-- simple alternative to fidget.nvim
-- via https://www.reddit.com/r/neovim/comments/o4bguk/comment/h2kcjxa/
local function lsp_progress()
	local messages = vim.lsp.util.get_progress_messages()
	if #messages == 0 then return "" end
	local client = messages[1].name and messages[1].name .. ": " or ""
	if client:find("null%-ls") then return "" end
	local progress = messages[1].percentage or 0
	local task = messages[1].title or ""
	task = task:gsub("^(%w+).*", "%1") -- only first word
	return client .. progress .. "%% " .. task
end

-- show number of references for entity under cursor
local lspCount = {}
local function requestLspRefCount()
	if vim.fn.mode() ~= "n" then
		lspCount = {}
		return
	end
	local params = vim.lsp.util.make_position_params(0) ---@diagnostic disable-line: missing-parameter
	params.context = { includeDeclaration = false }
	local thisFileUri = vim.uri_from_fname(expand("%:p"))

	vim.lsp.buf_request(0, "textDocument/references", params, function(error, refs)
		if not error and refs then
			lspCount.refWorkspace = #refs
			lspCount.refFile = 0
			for _, ref in pairs(refs) do
				if thisFileUri == ref.uri then lspCount.refFile = lspCount.refFile + 1 end
			end
		else
			lspCount.refWorkspace = nil
			lspCount.refFile = nil
		end
	end)
	vim.lsp.buf_request(0, "textDocument/definition", params, function(error, defs)
		if not error and defs then
			lspCount.defWorkspace = #defs
			lspCount.defFile = 0
			for _, def in pairs(defs) do
				if thisFileUri == def.targetUri then lspCount.defFile = lspCount.defFile + 1 end
			end
		else
			lspCount.defWorkspace = nil
			lspCount.defFile = nil
		end
	end)
end

local function lspCountStatusline()
	-- abort when lsp loading or not capable of references
	local currentBufNr = vim.fn.bufnr()
	local bufClients = vim.lsp.get_active_clients { bufnr = currentBufNr }
	local lspCapable = false
	for _, client in pairs(bufClients) do
		local capable = client.server_capabilities
		if capable.referencesProvider and capable.definitionProvider then lspCapable = true end
	end
	local lspLoading = #(vim.lsp.util.get_progress_messages()) > 0
	if lspLoading or not lspCapable then return "" end
	requestLspRefCount() -- needs to be separated due to lsp calls being async

	-- abort when no count
	if
		not (lspCount.refWorkspace and lspCount.defWorkspace)
		or (lspCount.refWorkspace == 0 and lspCount.defWorkspace == 0)
	then
		return ""
	end

	-- display the count
	local defs = tostring(lspCount.defFile)
	if lspCount.defFile ~= lspCount.defWorkspace then
		defs = defs .. "(" .. tostring(lspCount.defWorkspace) .. ")"
	end
	local refs = tostring(lspCount.refFile)
	if lspCount.refFile ~= lspCount.refWorkspace then
		refs = refs .. "(" .. tostring(lspCount.refWorkspace) .. ")"
	end
	return " " .. defs .. "  " .. refs
end

--------------------------------------------------------------------------------

-- nerdfont: icons with prefix 'ple-'
-- stylua: ignore start
local bottomSeparators = vim.g.neovide and { left = " ", right = " " } or { left = "", right = "" }
local topSeparators = vim.g.neovide and { left = " ", right = "" } or { left = "", right = "" }
-- stylua: ignore end

local lualineConfig = {
	sections = {
		lualine_a = {
			{ harpoonIndicator, padding = { left = 1, right = 0 } },
			{
				"filetype",
				colored = false,
				padding = { left = 1, right = 0 },
				icon_only = true,
			},
			{
				"filename",
				file_status = false,
				fmt = function(str) return str:gsub("%w+;#toggleterm#.*", "Toggleterm") end,
			},
		},
		lualine_b = { { require("funcs.alt-alt").altFileStatusline } },
		lualine_c = {
			{ searchCounter },
			{ require("funcs.quickfix").counter },
		},
		lualine_x = {
			{
				"diagnostics",
				symbols = { error = " ", warn = " ", info = " ", hint = "ﬤ " },
			},
			{ indentation },
			{ lspCountStatusline, color = { fg = "grey" } },
			{ lsp_progress },
		},
		lualine_y = {
			"diff",
			{ "branch", cond = isStandardBranch },
		},
		lualine_z = {
			"location",
			{ selectionCount, padding = { left = 0, right = 1 } },
		},
	},
	winbar = {
		lualine_a = {
			{ clock },
		},
		lualine_b = {
			{ navic.get_location, cond = showNavic, section_separators = topSeparators },
		},
		lualine_c = {
			{ function() return " " end, cond = showNavic }, -- dummy to avoid bar flickering
		},
		lualine_x = {
			{
				require("lazy.status").updates,
				cond = function()
					if not require("lazy.status").has_updates() then return false end
					local numberOfUpdates = tonumber(require("lazy.status").updates():match("%d+"))
					return numberOfUpdates >= UpdateCounterThreshhold
				end,
				color = "NonText",
			},
		},
		-- INFO dap and recording status defined in the respective plugin configs
		-- for lualine_y and lualine_z
	},
	options = {
		refresh = { statusline = 1000 },
		ignore_focus = {
			"TelescopePrompt",
			"DressingInput",
			"DressingSelect",
			"Mason",
			"harpoon",
			"ccc-ui",
			"",
		},
		globalstatus = true,
		component_separators = { left = "", right = "" },
		section_separators = bottomSeparators,
		disabled_filetypes = {
			statusline = {},
			winbar = {
				"toggleterm",
				"gitcommit",
			},
		},
	},
}

--------------------------------------------------------------------------------

return {
	"nvim-lualine/lualine.nvim",
	event = "VimEnter",
	config = function() require("lualine").setup(lualineConfig) end,
}
