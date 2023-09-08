return {
	{ -- comment
		"numToStr/Comment.nvim",
		keys = {
			-- mnemonic: [q]uiet text
			{ "q", mode = { "n", "x" }, desc = " Comment Operator" },
			{ "Q", desc = " Append Comment at EoL" },
			{ "qo", desc = " Comment below" },
			{ "qO", desc = " Comment above" },
		},
		opts = {
			opleader = { line = "q", block = "<Nop>" },
			toggler = { line = "qq", block = "<Nop>" },
			extra = { eol = "Q", above = "qO", below = "qo" },
		},
	},
	{
		"heavenshell/vim-pydocstring",
		lazy = false,
		build = "make install",
		cmd = "Pydocstring",
		keys = {
			{ "<localleader>d", "<cmd>Pydocstring<CR>", desc = "󱪝 Python docstring" },
		},
		init = function() vim.g.pydocstring_formatter = "numpy" end,
	},
	{ -- add docstrings / annotation comments
		"danymat/neogen",
		keys = {
			{
				"qf",
				function() require("neogen").generate { type = "func" } end,
				desc = " Generate Annotations",
			},
		},
		opts = {
			languages = {
				-- https://github.com/danymat/neogen#supported-languages
				python = {
					template = {
						annotation_convention = "reST",
					},
				},
			},
		},
	},
	{ -- substitute, evaluate, exchange, sort, duplicate
		"echasnovski/mini.operators",
		keys = {
			{ "s", mode = { "n", "x" }, desc = "󰅪 Substitute Operator" },
			{ "w", mode = { "n", "x" }, desc = "󰅪 Multiply Operator" },
			{ "#", mode = { "n", "x" }, desc = "󰅪 Evaluate Operator" },
			{ "sy", mode = { "n", "x" }, desc = "󰅪 Sort Operator" },
			{ "sx", mode = { "n", "x" }, desc = "󰅪 Exchange Operator" },
			{ "S", "s$", desc = "󰅪 Substitute to EoL", remap = true },
			{ "W", "w$", desc = "󰅪 Multiply to EoL", remap = true },
			{ "'", "#$", desc = "󰅪 Evaluate to EoL", remap = true },
			{ "sX", "sx$", desc = "󰅪 Exchange to EoL", remap = true },
			{ "sY", "sy$", desc = "󰅪 Sort to EoL", remap = true },
		},
		opts = {
			replace = { prefix = "s", reindent_linewise = true },
			multiply = { prefix = "w" },
			exchange = { prefix = "sx", reindent_linewise = true },
			sort = { prefix = "sy" },
			evaluate = { prefix = "#", func = require("funcs.mini-operator-extras").luaEval },
		},
		init = function()
			require("funcs.mini-operator-extras").filetypeSpecificMultiply()
			require("funcs.mini-operator-extras").filetypeSpecificEval()
		end,
	},
	{ -- surround
		"kylechui/nvim-surround",
		keys = {
			{ "ys", desc = "󰅪 Add Surround Operator" },
			{ "yS", desc = "󰅪 Surround to EoL" },
			{ "ds", desc = "󰅪 Delete Surround Operator" },
			{ "cs", desc = "󰅪 Change Surround Operator" },
			{ "s", mode = "x", desc = "󰅪 Add Surround Operator" },
		},
		config = function()
			local u = require("config.utils")

			local textobjRemaps = vim.deepcopy(require("config.utils").textobjectRemaps)
			textobjRemaps.a = "*" -- markdown italics
			textobjRemaps.u = "__" -- markdown bold

			-- requires unmapping yS from normal_line below
			vim.keymap.set("n", "yS", "ys$", { desc = "󰅪 Surround to EoL", remap = true })

			-- https://github.com/kylechui/nvim-surround/blob/main/doc/nvim-surround.txt#L483
			local config = require("nvim-surround.config")
			require("nvim-surround").setup {
				move_cursor = false,
				aliases = textobjRemaps,
				keymaps = {
					visual = "s",
					normal_line = false,
					normal_cur_line = false,
					visual_line = false,
					insert_line = false,
					insert = false,
				},
				surrounds = {
					invalid_key_behavior = { add = false, find = false, delete = false, change = false },
					[u.textobjectMaps.doubleSquareBracket] = {
						find = "%[%[.-%]%]",
						add = { "[[", "]]" },
						delete = "(%[%[)().-(%]%])()",
						change = {
							target = "(%[%[)().-(%]%])()",
						},
					},
					["__"] = {
						find = "__.-__",
						add = { "__", "__" },
						delete = "(__)().-(__)()",
						change = {
							target = "(__)().-(__)()",
						},
					},
					["/"] = {
						find = "/.-/",
						add = { "/", "/" },
						delete = "(/)().-(/)()",
						change = {
							target = "(/)().-(/)()",
						},
					},
					["*"] = {
						find = "%*.-%*",
						add = { "*", "*" },
						delete = "(%*)().-(%*)()",
						change = {
							target = "(%*)().-(%*)()",
						},
					},
					[u.textobjectMaps["function"]] = {
						find = function()
							return config.get_selection { motion = "a" .. u.textobjectMaps["function"] }
						end,
						delete = function()
							local ft = vim.bo.filetype
							local patt
							if ft == "lua" then
								patt = "^(.-function.-%b() ?)().-( ?end)()$"
							elseif
								ft == "javascript"
								or ft == "typescript"
								or ft == "bash"
								or ft == "zsh"
								or ft == "sh"
							then
								patt = "^(.-function.-%b() ?{)().*(})()$"
							else
								u.notify("Surround", "No function-surround defined for " .. ft)
								patt = "()()()()"
							end
							return config.get_selections {
								char = u.textobjectMaps["function"],
								pattern = patt,
							}
						end,
						add = function()
							local ft = vim.bo.filetype
							if ft == "lua" then
								-- function as one line
								return { { "function() " }, { " end" } }
							elseif
								ft == "typescript"
								or ft == "javascript"
								or ft == "bash"
								or ft == "zsh"
								or ft == "sh"
							then
								-- function on surrounding lines
								return {
									{ "function () {", "\t" },
									{ "", "}" },
								}
							end
							u.notify("Surround", "No function-surround defined for " .. ft)
							return { { "" }, { "" } }
						end,
					},
					[u.textobjectMaps["call"]] = {
						find = function()
							return config.get_selection { motion = "a" .. u.textobjectMaps["call"] }
						end,
						delete = "^([^=%s]+%()().-(%))()$", -- https://github.com/kylechui/nvim-surround/blob/main/doc/nvim-surround.txt#L357
					},
					[u.textobjectMaps["conditional"]] = {
						find = function()
							return config.get_selection { motion = "a" .. u.textobjectMaps["conditional"] }
						end,
						delete = function()
							local ft = vim.bo.filetype
							local patt
							if ft == "lua" then
								patt = "^(if .- then)().-( ?end)()$"
							elseif ft == "javascript" or ft == "typescript" then
								patt = "^(if %b() ?{?)().-( ?}?)()$"
							else
								u.notify("Surround", "No conditional-surround defined for " .. ft)
								patt = "()()()()"
							end
							return config.get_selections {
								char = u.textobjectMaps["conditional"],
								pattern = patt,
							}
						end,
						add = function()
							local ft = vim.bo.filetype
							if ft == "lua" then
								return {
									{ "if true then", "\t" },
									{ "", "end" },
								}
							elseif ft == "typescript" or ft == "javascript" then
								return {
									{ "if (true) {", "\t" },
									{ "", "}" },
								}
							end
							u.notify("Surround", "No if-surround defined for " .. ft)
							return { { "" }, { "" } }
						end,
					},
				},
			}
		end,
	},
}
