return {
	"mfussenegger/nvim-dap",
	keys = {
		{ "6", function() require("dap").step_over() end, desc = " Step over" },
		{ "7", function() require("dap").continue() end, desc = " Continue" },
		{ "8", function() require("dap").toggle_breakpoint() end, desc = " Toggle breakpoint" },

		{ "<leader>do", function() require("dap").step_out() end, desc = "󰆸 Step out" },
		{ "<leader>di", function() require("dap").step_in() end, desc = "󰆹 Step in" },
		{ "<leader>dc", function() require("dap").run_to_cursor() end, desc = "󰆿 Run to cursor" },
		{ "<leader>dr", function() require("dap").restart() end, desc = " Restart" },
		{ "<leader>dt", function() require("dap").terminate() end, desc = " Terminate" },
		-- stylua: ignore
		{ "<leader>dd", function() require("dap").clear_breakpoints() end, desc = "󰅗 Delete breakpoints" },
		-- stylua: ignore
		{ "<leader>dh", function() require("dap.ui.widgets").hover() end, desc = "󰫧 Hover variable" },
	},
	init = function() vim.g.whichkeyAddSpec { "<leader>d", group = "󰃤 Debugger" } end,
	config = function()
		-- ICONS & HIGHLIGHTS
		vim.fn.sign_define("DapBreakpoint", { text = "", texthl = "DiagnosticInfo" })
		vim.fn.sign_define("DapBreakpointCondition", { text = "󰇽", texthl = "DiagnosticInfo" })
		vim.fn.sign_define("DapLogPoint", { text = "󰍩", texthl = "DiagnosticInfo" })
		vim.fn.sign_define("DapLogRejected", { text = "", texthl = "DiagnosticInfo" })
		vim.fn.sign_define("DapStopped", {
			text = "󰳟",
			texthl = "DiagnosticHint",
			linehl = "DiagnosticVirtualTextHint",
			numhl = "DiagnosticVirtualTextHint",
		})

		-- LISTENERS
		local listeners = require("dap").listeners.after
		-- start nvim-dap-virtual-text
		listeners.attach["dapVirtText"] = function()
			local installed, dapVirtText = pcall(require, "nvim-dap-virtual-text")
			if installed then dapVirtText.enable() end
		end
		-- enable/disable diagnostics & line numbers
		listeners.attach."dapItself" = function()
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
				if #vim.iter(breakpoints):totable() == 0 then return "" end -- needs iter-wrap since sparse list
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
