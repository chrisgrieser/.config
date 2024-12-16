---@param dir "next"|"prev"
local function gotoBreakpoint(dir)
	local breakpoints = require("dap.breakpoints").get()
	if #breakpoints == 0 then
		vim.notify("No breakpoints set", vim.log.levels.WARN)
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

return {
	"mfussenegger/nvim-dap",
	keys = {
		{ "7", function() require("dap").continue() end, desc = " Continue" },
		{ "8", function() require("dap").toggle_breakpoint() end, desc = " Toggle breakpoint" },

		{ "gb", function() gotoBreakpoint("next") end, desc = " Goto next breakpoint" },
		{ "gB", function() gotoBreakpoint("prev") end, desc = " Goto previous breakpoint" },

		-- stylua: ignore
		{ "<leader>dc", function() require("dap").clear_breakpoints() end, desc = "󰅗 Clear breakpoints" },
		{ "<leader>dr", function() require("dap").restart() end, desc = " Restart" },
		{ "<leader>dt", function() require("dap").terminate() end, desc = " Terminate" },
	},
	init = function() vim.g.whichkeyAddSpec { "<leader>d", group = "󰃤 Debugger" } end,
	config = function()
		-- ICONS & HIGHLIGHTS
		vim.fn.sign_define("DapBreakpoint", { text = "", texthl = "DiagnosticInfo" })
		vim.fn.sign_define("DapStopped", {
			text = "",
			texthl = "DiagnosticHint",
			linehl = "DiagnosticVirtualTextHint",
			numhl = "DiagnosticVirtualTextHint",
		})

		-- LISTENERS
		local listeners = require("dap").listeners.after
		-- start nvim-dap-virtual-text
		listeners.attach.dapVirtText = function()
			local installed, dapVirtText = pcall(require, "nvim-dap-virtual-text")
			if installed then dapVirtText.enable() end
		end
		-- enable/disable diagnostics & line numbers
		listeners.attach.dapItself = function()
			vim.opt.number = true
			vim.diagnostic.enable(false)
		end
		listeners.disconnect.dapItself = function()
			vim.opt.number = false
			vim.diagnostic.enable(true)
		end

		-- LUALINE COMPONENTS
		-- breakpoint count
		vim.g.lualineAdd("sections", "lualine_y", {
			color = vim.fn.sign_getdefined("DapBreakpoint")[1].texthl,
			function()
				local breakpoints = require("dap.breakpoints").get()
				if #breakpoints == 0 then return "" end
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
		vim.g.lualineAdd("tabline", "lualine_z", function()
			local status = require("dap").status()
			if status == "" then return "" end
			return "󰃤 " .. status
		end)
	end,
}
