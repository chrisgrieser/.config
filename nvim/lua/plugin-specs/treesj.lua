-- vim: foldlevel=4
-- DOCS https://github.com/Wansmer/treesj#basic-node
--------------------------------------------------------------------------------

local reflow = { both = { fallback = function() vim.cmd("normal! gww") end } }
--------------------------------------------------------------------------------

return {
	"Wansmer/treesj",
	keys = {
		{ "<leader>s", function() require("treesj").toggle() end, desc = "󰗈 Split-join lines" },
		-- stylua: ignore
		{ "<leader>s", "gw}", ft = { "markdown", "text", "gitcommit" }, desc = "󰗈 Reflow rest of paragraph" },
	},
	opts = {
		use_default_keymaps = false,
		cursor_behavior = "start",
		max_join_length = math.huge,
		langs = {
			javascript = {
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
			},
			swift = {
				if_statement = {
					join = { space_in_brackets = true },
					split = {
						-- stylua: ignore
						omit = { "else", "{", "equality_expression", "prefix_expression", "tuple_expression", "navigation_expression", "boolean_literal" },
					},
				},
			},
			zsh = {
				pipeline = {
					both = { omit = { "|" } },
					join = {
						format_tree = function(tsj)
							local children = tsj:children()
							local lastChild = children[#children]
							lastChild:update_text(" " .. lastChild:text())
							tsj:update_children(children)
						end,
					},
					split = {
						format_tree = function(tsj)
							local children = tsj:children()
							local lastChild = children[#children]
							lastChild:update_text("\t" .. lastChild:text())
							tsj:update_children(children)
						end,
					},
				},
			},
			comment = { source = reflow, element = reflow }, -- comments in any language
			jsdoc = { source = reflow, description = reflow },
		},
	},
	config = function(_, opts)
		-- local zsh inherit from bash PENDING https://github.com/Wansmer/treesj/pull/195
		opts.langs.zsh =
			require("treesj.langs.utils").merge_preset(require("treesj.langs.bash"), opts.langs.zsh)

		opts.langs.swift.guard_statement = opts.langs.swift.if_statement
		opts.langs.typescript = opts.langs.javascript
		require("treesj").setup(opts)
	end,
}
