-- DOCS https://github.com/Wansmer/treesj#basic-node
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
		local reflow = { both = { fallback = function() vim.cmd("normal! gww") end } }
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
			comment = { source = reflow, element = reflow }, -- comments in any language
			lua = { comment = reflow },
			jsdoc = { source = reflow, description = reflow },
			javascript = joinWithoutCurly,
			typescript = joinWithoutCurly,
			swift = swiftConfig,
		}
		require("treesj").setup(opts)
	end,
}
