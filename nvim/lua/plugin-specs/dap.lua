return {
	"mfussenegger/nvim-dap",
	dependencies = { "rcarriga/nvim-dap-ui", "theHamsta/nvim-dap-virtual-text" },
	keys = {
		{ "7", function() require("dap").continue() end, desc = " Continue" },
		{ "8", function() require("dap").toggle_breakpoint() end, desc = " Toggle breakpoint" },
		{
			"<leader>dc",
			function() require("dap").clear_breakpoints() end,
			desc = " Clear breakpoints",
		},
		{ "<leader>dr", function() require("dap").restart() end, desc = " Restart" },
		{ "<leader>dt", function() require("dap").terminate() end, desc = " Terminate" },
	},
	init = function() vim.g.whichkeyAddSpec { "<leader>d", group = "󰃤 Debugger" } end,
	config = function()
		-- SIGN-ICONS & HIGHLIGHTS
		vim.fn.sign_define("DapBreakpoint", { text = "", texthl = "DiagnosticInfo" })
		vim.fn.sign_define("DapStopped", {
			text = "",
			texthl = "DiagnosticHint",
			linehl = "DiagnosticVirtualTextHint",
			numhl = "DiagnosticVirtualTextHint",
		})

		-- LUALINE COMPONENTS
		vim.g.lualineAdd("sections", "lualine_y", {
			color = vim.fn.sign_getdefined("DapBreakpoint")[1].texthl,
			function()
				local breakpoints = require("dap.breakpoints").get()
				local breakpointSum = 0
				for buf, _ in pairs(breakpoints) do
					breakpointSum = breakpointSum + #breakpoints[buf]
				end
				if breakpointSum == 0 then return "" end
				local breakpointIcon = vim.fn.sign_getdefined("DapBreakpoint")[1].text
				return breakpointIcon .. tostring(breakpointSum)
			end,
		}, "before")
		vim.g.lualineAdd("tabline", "lualine_z", function()
			local dapStatus = require("dap").status()
			if dapStatus == "" then return "" end
			return "󰃤 " .. dapStatus
		end)
	end,
}
