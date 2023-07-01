local function dapConfig()
	-- Lua (one-step-for-vimkind plugin)
	require("dap").configurations.lua = {
		{ type = "nlua", request = "attach", name = "Attach to running Neovim instance" },
	}

	require("dap").adapters.nlua = function(callback, config)
		callback { type = "server", host = config.host or "127.0.0.1", port = config.port or 8086 }
	end

	-- SIGN-COLUMN ICONS
	local sign = vim.fn.sign_define
	sign("DapBreakpoint", { text = "", texthl = "DiagnosticHint" })
	sign("DapBreakpointCondition", { text = "", texthl = "DiagnosticHint" })
	sign("DapLogPoint", { text = "󰍨", texthl = "DiagnosticHint" })
	sign("DapStopped", { text = "", texthl = "DiagnosticInfo" })
	sign("DapBreakpointRejected", { text = "", texthl = "DiagnosticError" })
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
			return "  " .. tostring(breakpointSum)
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

	},
	dependencies = {
		{ "jayp0521/mason-nvim-dap.nvim", config = true },
		{ "theHamsta/nvim-dap-virtual-text", config = true },
		{ "rcarriga/nvim-dap-ui", config = true },
		"jbyuki/one-small-step-for-vimkind", -- lua debugger specifically for neovim config
	},
	lazy = true, -- loaded via keymaps
	config = function()
		dapConfig()
		dapLualine()
	end,
}
