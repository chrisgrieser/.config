return {
	"mfussenegger/nvim-dap",

	-- as dependency, since this one we want to auto-load via listeners
	dependencies = "theHamsta/nvim-dap-virtual-text",

	keys = {
		{ "7", function() require("dap").continue() end, desc = " Continue" },
		{ "8", function() require("dap").toggle_breakpoint() end, desc = " Toggle breakpoint" },
		-- stylua: ignore
		{ "<leader>dc", function() require("dap").clear_breakpoints() end, desc = " Clear breakpoints" },
		{ "<leader>dr", function() require("dap").restart() end, desc = " Restart" },
		{ "<leader>dt", function() require("dap").terminate() end, desc = " Terminate" },
	},
	init = function() vim.g.whichkeyAddSpec { "<leader>d", group = "󰃤 Debugger" } end,
	config = function()
		-- auto-disable line numbers
		local stop = function() vim.opt.number = false end
		local listeners = require("dap").listeners.after
		listeners.disconnect.dapItself = stop
		listeners.event_terminated.dapItself = stop
		listeners.event_exited.dapItself = stop

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
