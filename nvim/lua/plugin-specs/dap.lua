---@param dir "next"|"prev"
local function gotoBreakpoint(dir)
	local breakpoints = require("dap.breakpoints").get()
	local noBreakpoints = #vim.iter(breakpoints):totable() == 0 -- vim.iter needed for sparse array
	if noBreakpoints == 0 then
		vim.notify("No breakpoints set", vim.log.levels.WARN, { icon = "󰃤", "dap" })
		return
	end
	local points = {}
	for bufnr, buffer in pairs(breakpoints) do
		for _, point in ipairs(buffer) do
			table.insert(points, { bufnr = bufnr, line = point.line })
		end
	end

	local current = {
		bufnr = vim.api.nvim_get_current_buf(),
		line = vim.api.nvim_win_get_cursor(0)[1],
	}

	local nextPoint
	for i = 1, #points do
		local isAtBreakpointI = points[i].bufnr == current.bufnr and points[i].line == current.line
		if isAtBreakpointI then
			local nextIdx = dir == "next" and i + 1 or i - 1
			if nextIdx > #points then nextIdx = 1 end
			if nextIdx == 0 then nextIdx = #points end
			nextPoint = points[nextIdx]
			break
		end
	end
	if not nextPoint then nextPoint = points[1] end

	vim.cmd(("buffer +%d %d"):format(nextPoint.line, nextPoint.bufnr))
end

---@param type? "scopes"|"frames"|"threads"|"expression"|"sessions"
local function toggleDapSidebar(type)
	local relWidth = 0.4

	local function toggle(widget)
		if not widget then return end
		if not (vim.g.dap_sidebar and vim.g.dap_sidebar_type == widget) then
			if vim.g.dap_sidebar then vim.g.dap_sidebar.close() end
			local widgets = require("dap.ui.widgets")
			local width = math.floor(vim.o.columns * relWidth)
			vim.g.dap_sidebar = widgets.sidebar(widgets[widget], { width = width })
			vim.g.dap_sidebar.open()
			vim.g.dap_sidebar_type = widget
		else
			vim.g.dap_sidebar.close()
			vim.g.dap_sidebar = nil
			vim.g.dap_sidebar_type = nil
		end
	end

	if type then
		toggle(type)
	else
		local widgets = { "scopes", "frames", "threads", "expression", "sessions" }
		vim.ui.select(widgets, { prompt = " Select widget: " }, toggle)
	end
end

--------------------------------------------------------------------------------

return {
	"mfussenegger/nvim-dap",
	init = function() vim.g.whichkeyAddSpec { "<leader>d", group = "󰃤 Debugger" } end,
	keys = {
		{ "7", function() require("dap").continue() end, desc = " Continue" },
		{ "8", function() require("dap").toggle_breakpoint() end, desc = " Toggle breakpoint" },
		{
			"<leader>dc",
			function()
				vim.ui.input({ prompt = " Breakpoint condition" }, function(input)
					if input then require("dap").set_breakpoint(input) end
				end)
			end,
			desc = " Conditional breakpoint",
		},
		{ "<leader>dd", function() require("dap").run_to_cursor() end, desc = "󰆿 Run to cursor" },

		{ "gb", function() gotoBreakpoint("next") end, desc = " Goto next breakpoint" },
		{ "gB", function() gotoBreakpoint("prev") end, desc = " Goto previous breakpoint" },

		{ "<leader>di", function() require("dap").step_in() end, desc = "󰆹 Step in" },
		{ "<leader>dI", function() require("dap").step_out() end, desc = "󰆸 Step out" },
		{ "<leader>do", function() require("dap").step_over() end, desc = " Step over" },

		{ "<leader>dR", function() require("dap").restart() end, desc = " Restart" },
		{ "<leader>dq", function() require("dap").terminate() end, desc = " Quit" },

		-- stylua: ignore
		{ "<leader>dr", function() require("dap").clear_breakpoints() end, desc = "󰅗 Remove all breakpoints" },

		-- stylua: ignore
		{ "<leader>dh", function() require("dap.ui.widgets").hover() end, desc = "󰫧 Hover variable" },
		{ "q", vim.cmd.close, ft = "dap-float", nowait = true },
		{ "<leader>ds", function() toggleDapSidebar("scopes") end, desc = " Scopes sidebar" },
		{ "<leader>dS", toggleDapSidebar, desc = " Select sidebar widget" },
		{ "<leader>dt", function() require("dap").repl.toggle() end, desc = " Terminal" },
	},
	config = function()
		-- SIGNS & HIGHLIGHTS
		vim.fn.sign_define("DapBreakpoint", { text = "", texthl = "DiagnosticInfo" })
		vim.fn.sign_define("DapBreakpointCondition", { text = "", texthl = "DiagnosticInfo" })
		vim.fn.sign_define("DapBreakpointRejected", { text = "", texthl = "DiagnosticInfo" })
		vim.fn.sign_define("DapLogPoint", { text = "", texthl = "DiagnosticInfo" })
		-- stylua: ignore
		vim.fn.sign_define("DapStopped", { text = "", texthl = "DiagnosticHint", linehl = "DiagnosticVirtualTextHint" })

		-- ADAPTERS – load from `dap` directory
		local adaptersDir = vim.fn.stdpath("config") .. "/dap"
		for name, _ in vim.fs.dir(adaptersDir) do
			-- `dofile` allows loading lua files based on an absolute path 
			-- (but without a return value, which we do not need here anyway.)
			if name:sub(-4) == ".lua" then dofile(adaptersDir .. "/" .. name) end
		end

		-- DAP-VIRTUAL-TEXT – autostart
		pcall(require, "nvim-dap-virtual-text")

		-- LISTENERS – auto-close widgets
		local listeners = require("dap").listeners.after
		vim.g.dap_dismount = function() -- as `vim.g` to be for `one-small-step-for-vimkind`
			if vim.g.dap_sidebar then vim.g.dap_sidebar.close() end
			require("dap").repl.close()
		end
		listeners.event_terminated["dap"] = vim.g.dap_dismount
		listeners.event_exited["dap"] = vim.g.dap_dismount

		-- LUALINE COMPONENTS
		-- breakpoint count
		vim.g.lualineAdd("sections", "lualine_y", {
			color = vim.fn.sign_getdefined("DapBreakpoint")[1].texthl,
			function()
				local breakpoints = require("dap.breakpoints").get()
				local noBreakpoints = #vim.iter(breakpoints):totable() == 0 -- vim.iter needed for sparse array
				if noBreakpoints == 0 then return "" end
				local allBufs = 0
				for _, bp in pairs(breakpoints) do
					allBufs = allBufs + #bp
				end
				local thisBuf = #(breakpoints[vim.api.nvim_get_current_buf()] or {})
				local countStr = (thisBuf == allBufs) and thisBuf or thisBuf .. "/" .. allBufs
				local icon = vim.fn.sign_getdefined("DapBreakpoint")[1].text
				return icon .. countStr
			end,
		}, "before")

		-- status
		vim.g.lualineAdd("tabline", "lualine_z", { require("dap").status, icon = "󰃤" })
	end,
}
