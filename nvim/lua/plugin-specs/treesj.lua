-- DOCS https://github.com/Wansmer/treesj?tab=readme-ov-file#basic-node
--------------------------------------------------------------------------------

return {
	"Wansmer/treesj",
	keys = {
		{ "<leader>s", function() require("treesj").toggle() end, desc = "󰗈 Split-join lines" },
		{
			"<leader>s",
			"gw}",
			ft = { "markdown", "text", "gitcommit" },
			desc = "󰗈 Reflow rest of paragraph",
		},
	},
	opts = {
		use_default_keymaps = false,
		cursor_behavior = "start",
		max_join_length = math.huge,
	},
	config = function(_, opts)
		local gww = { both = { fallback = function() vim.cmd("normal! gww") end } }
		local joinWithoutCurly = {
			-- remove curly brackets in js when joining if statements https://github.com/Wansmer/treesj/issues/150
			statement_block = {
				join = {
					format_tree = function(tsj)
						if tsj:tsnode():parent():type() == "if_statement" then
							tsj:remove_child { "{", "}" }
							tsj:update_preset({ recursive = false }, "join")
						else
							require("treesj.langs.javascript").statement_block.join.format_tree(tsj)
						end
					end,
				},
			},
			-- one-line if-statement can be split into multi-line https://github.com/Wansmer/treesj/issues/150
			expression_statement = {
				join = { enable = false },
				split = {
					enable = function(tsn) return tsn:parent():type() == "if_statement" end,
					format_tree = function(tsj) tsj:wrap { left = "{", right = "}" } end,
				},
			},
		}
		local swiftConditionNodes = {
			"else", -- for guard statements
			"{",
			"equality_expression",
			"prefix_expression",
			"tuple_expression",
			"navigation_expression",
			"boolean_literal", -- `true` and `false` only, mostly debugging
		}
		local swiftConfig = {
			if_statement = {
				join = { space_in_brackets = true },
				split = { omit = swiftConditionNodes },
			},
			guard_statement = {
				join = { space_in_brackets = true },
				split = { omit = swiftConditionNodes },
			},
		}
		opts.langs = {
			comment = { source = gww, element = gww }, -- comments in any language
			lua = { comment = gww },
			jsdoc = { source = gww, description = gww },
			javascript = joinWithoutCurly,
			typescript = joinWithoutCurly,
			swift = swiftConfig,
		}
		require("treesj").setup(opts)
	end,
}
