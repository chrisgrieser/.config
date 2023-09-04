--------------------------------------------------------------------------------

return {
	{ -- REPL
		"Vigemus/iron.nvim",
		keys = {
			{ "<leader>i", vim.cmd.IronRepl, desc = "󱠤 Toggle REPL" },
			{ "<leader>I", vim.cmd.IronRestart, desc = "󱠤 Restart REPL" },
			{ "++", desc = "󱠤 Send Line to REPL" },
			{ "+", mode = { "n", "x" }, desc = "󱠤 Send-to-REPL Operator" },
		},
		main = "iron.core",
		opts = {
			keymaps = {
				send_line = "++",
				visual_send = "+",
				send_motion = "+",
			},
			config = {
				repl_open_cmd = "horizontal bot 10 split",
				repl_definition = {
					sh = { command = { "zsh" } },
					typescript = { command = { "node" } },
					javascript = { command = { "osascript", "-i", "-l", "JavaScript" } },
					applescript = { command = { "osascript", "-i", "-l", "AppleScript" } },
					-- automatically uses the ipython from the virtual env, if one is active
					python = { command = { "ipython" } },
				},
			},
		},
	},
	{ -- HTTP requester (e.g., test APIs)
		"rest-nvim/rest.nvim",
		ft = "http",
		dependencies = "nvim-lua/plenary.nvim",
		init = function()
			local a = vim.api
			local keymap = vim.keymap.set

			a.nvim_create_user_command("Rest", function()
				vim.cmd.tabnew()
				a.nvim_buf_set_option(0, "filetype", "http")
				a.nvim_buf_set_option(0, "buftype", "nofile")
				a.nvim_buf_set_name(0, "HTTP Request")
				-- stylua: ignore start
				keymap("n", "<localleader>r", "<Plug>RestNvim", { desc = "󰴚 Run Request under cursor", buffer = true })
				keymap("n", "<localleader>a", "<Plug>RestNvimLast", { desc = "󰴚 Re-run the last request", buffer = true })
				keymap( "n", "<localleader>e", function() 
					vim.fn.system { "open", "https://github.com/rest-nvim/rest.nvim/tree/main/tests" }
				end, { desc = "󰴚 Show example requests", buffer = true })
				-- stylua: ignore end
			end, {})
		end,
		opts = {
			result_split_horizontal = true,
			encode_url = true, -- Encode URL before making request
			result = {
				show_url = false,
				show_http_info = true,
				show_headers = false,
				formatters = {
					json = function(body)
						-- stylua: ignore
						return vim.fn.system { "biome", "format", "--stdin", "--stdin-file-path", "foo.json", body }
					end,
					-- prettier already needed since it's the only proper yaml formatter
					html = function(body) return vim.fn.system { "prettier", "--parser=html", body } end,
				},
			},
		},
	},
}
