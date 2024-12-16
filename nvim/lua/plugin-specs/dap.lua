return {
	"mfussenegger/nvim-dap",
	keys = {
		{ "7", function() require("dap").continue() end, desc = " Continue" },
		{ "8", function() require("dap").toggle_breakpoint() end, desc = " Toggle breakpoint" },
		-- stylua: ignore
		{ "<leader>dc", function() require("dap").clear_breakpoints() end, desc = "󰅗 Clear breakpoints" },
		{ "<leader>dr", function() require("dap").restart() end, desc = " Restart" },
		{ "<leader>dt", function() require("dap").terminate() end, desc = " Terminate" },
	},
	init = function() vim.g.whichkeyAddSpec { "<leader>d", group = "󰃤 Debugger" } end,
	config = function()
		local listeners = require("dap").listeners.after

		-- auto-enable nvim-dap-virtual-text
		local installed, dapVirtText = pcall(require, "nvim-dap-virtual-text")
		if installed then
			listeners.attach.dapVirtText = dapVirtText.enable
			listeners.launch.dapVirtText = dapVirtText.enable
		else
			vim.notify("dap-virtual-text not installed", vim.log.levels.WARN, { title = "nvim-dap" })
		end

		-- auto-disable line numbers
		local noLineNumbers = function() vim.opt.number = false end
		listeners.disconnect.dapItself = noLineNumbers
		listeners.event_terminated.dapItself = noLineNumbers
		listeners.event_exited.dapItself = noLineNumbers

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
