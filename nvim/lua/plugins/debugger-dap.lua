local function dapConfig()
end

local function dapLualine()
	local topSeparators = { left = "", right = "" }

	-- INFO inserting needed, to not disrupt existing lualine-segment set by nvim-recorder
	local lualineY = require("lualine").get_config().tabline.lualine_y or {}
	local lualineZ = require("lualine").get_config().tabline.lualine_z or {}
	table.insert(lualineY, {
		function()
			local breakpoints = require("dap.breakpoints").get()
			local breakpointSum = 0
			for buf, _ in pairs(breakpoints) do
				breakpointSum = breakpointSum + #breakpoints[buf]
			end
			if breakpointSum == 0 then return "" end
			return "   " .. tostring(breakpointSum)
		end,
		section_separators = topSeparators,
	})
	table.insert(lualineZ, {
		function()
			local dapStatus = require("dap").status()
			if dapStatus ~= "" then dapStatus = "  " .. dapStatus end
			return dapStatus
		end,
		section_separators = topSeparators,
	})

	require("lualine").setup {
		tabline = {
			lualine_y = lualineY,
			lualine_z = lualineZ,
		},
	}
end
--------------------------------------------------------------------------------

return {
	"mfussenegger/nvim-dap",
	keys = {
		-- stylua: ignore start
		-- INFO toggling breakpoints done via nvim-recorder
		{ "<leader>b" .. "u", function() require("dapui").toggle() end, desc = " Toggle DAP-UI" },
		{ "<leader>bv", function() require("dap").step_over() end, desc = " Step Over" },
		{ "<leader>bo", function() require("dap").step_out() end, desc = " Step Out" },
		{ "<leader>bi", function() require("dap").step_into() end, desc = " Step Into" },
		{ "<leader>bc", function() require("dap").run_to_cursor() end, desc = " Run to Cursor" },
		{ "<leader>br", function() require("dap").clear_breakpoints() end, desc = "  Remove Breakpoints" },
		{ "<leader>bq", function() require("dap").list_breakpoints() end, desc = "  Breakpoints to QuickFix" },
		{ "<leader>bt", function() require("dap").list_breakpoints() end, desc = "  Breakpoints to QuickFix" },

vim.keymap.set("n", "<leader>bt", function()
	vim.opt_local.number = false
	require("dapui").close()
	require("dap").terminate()
end, { desc = "  Terminate" })
		-- stylua: ignore end
	},
	dependencies = {
		{ "jayp0521/mason-nvim-dap.nvim", config = true },
		{ "theHamsta/nvim-dap-virtual-text", config = true },
		{ "rcarriga/nvim-dap-ui", config = true },
	},
	init = function()

		local ok, whichKey = pcall(require, "which-key")
		if ok then whichKey.register { ["<leader>b"] = { name = "  Debugger" } } end
	end,
	config = function()
		dapLualine()

		-- SIGN-COLUMN ICONS
		local sign = vim.fn.sign_define
		sign("DapBreakpoint", { text = "", texthl = "DiagnosticHint" })
		sign("DapBreakpointCondition", { text = "", texthl = "DiagnosticHint" })
		sign("DapLogPoint", { text = "󰍨", texthl = "DiagnosticHint" })
		sign("DapStopped", { text = "", texthl = "DiagnosticInfo" })
		sign("DapBreakpointRejected", { text = "", texthl = "DiagnosticError" })
	end,
}
