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
		-- auto-disable line numbers
		local stop = function() vim.opt.number = false end
		local listeners = require("dap").listeners.after
		listeners.disconnect.dapvt = stop
		listeners.event_terminated.dapvt = stop
		listeners.event_exited.dapvt = stop

		-- sign-icons & highlights
		vim.fn.sign_define("DapBreakpoint", { text = "", texthl = "DiagnosticInfo" })
		vim.fn.sign_define("DapStopped", {
			text = "",
			texthl = "DiagnosticHint",
			linehl = "DiagnosticVirtualTextHint",
			numhl = "DiagnosticVirtualTextHint",
		})

		-- LUALINE COMPONENTS
		-- breakpoint count
		vim.g.lualineAdd("sections", "lualine_y", {
			color = vim.fn.sign_getdefined("DapBreakpoint")[1].texthl,
			function()
				local allBufs = 0
				for _, bp in pairs(require("dap.breakpoints").get()) do
					allBufs = allBufs + #bp
				end
				if allBufs == 0 then return "" end
				local icon = vim.fn.sign_getdefined("DapBreakpoint")[1].text
				return icon .. tostring(allBufs)
			end,
		}, "before")
		-- status
		vim.g.lualineAdd("tabline", "lualine_z", function()
			local dapStatus = require("dap").status()
			if dapStatus == "" then return "" end
			return "󰃤 " .. dapStatus
		end)
	end,
}
