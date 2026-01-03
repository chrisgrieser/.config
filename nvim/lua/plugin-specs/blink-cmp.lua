-- vim: foldlevel=3
-- DOCS https://cmp.saghen.dev/configuration/reference
--------------------------------------------------------------------------------

return {
	"saghen/blink.cmp",
	event = { "InsertEnter", "CmdlineEnter" },
	version = "*", -- REQUIRED to download pre-built binary

	opts = {
		sources = {
			providers = {
				lsp = {
					fallbacks = {}, -- do not use `buffer` as fallback

					-- CHANGES FOR `LUA_LS`
					enabled = function()
						if vim.bo.ft ~= "lua" then return true end

						-- prevent useless suggestions when typing `--` in lua, but
						-- keep the useful `---@param;@return` suggestion
						local col = vim.api.nvim_win_get_cursor(0)[2]
						local charsBefore = vim.api.nvim_get_current_line():sub(col - 2, col)
						local luadocButNotComment = not charsBefore:find("^%-%-?$")
							and not charsBefore:find("%s%-%-?")
						return luadocButNotComment
					end,

					-- CHANGES FOR `MARKDOWN_OXIDE`
					transform_items = function(_ctx, items)
						return vim.iter(items)
							:filter(function(item)
								-- filter aliases, PENDING https://github.com/Feel-ix-343/markdown-oxide/issues/330
								if item.client_name ~= "markdown_oxide" then return true end
								if item.textEdit.newText:find(">") then return false end
								return true
							end)
							:map(function(item)
								if item.client_name ~= "markdown_oxide" then return item end
								if item.labelDetails and item.labelDetails.details then
									item.labelDetails.details = " "
										.. item.labelDetails.details:gsub("%.md$", "")
								end
								return item
							end)
							:totable()
					end,
				},
				snippets = {
					-- don't show when triggered manually (= length 0), useful
					-- when manually showing completions to see available fields
					min_keyword_length = 1,
					score_offset = 3,
					opts = { clipboard_register = "+" }, -- register to use for `$CLIPBOARD`
				},
				path = {
					opts = {
						get_cwd = vim.uv.cwd,
						show_hidden_files_by_default = true,
						ignore_root_slash = true, -- `/path` as cwd, not system root (useful in markdown)
					},
				},
				buffer = {
					max_items = 4,
					min_keyword_length = 4,
					-- with `-7`, typing `then` in lua prioritizes the `then .. end`
					-- snippet, effectively acting as `nvim-endwise`
					score_offset = -7,
					opts = {
						-- show completions from all buffers used within the last x minutes
						get_bufnrs = function()
							local lastXmins = 15
							local allOpenBuffers = vim.fn.getbufinfo { buflisted = 1, bufloaded = 1 }
							local recentBufs = vim.iter(allOpenBuffers)
								:filter(function(buf)
									local recentlyUsed = os.time() - buf.lastused < (60 * lastXmins)
									local nonSpecial = vim.bo[buf.bufnr].buftype == ""
									return recentlyUsed and nonSpecial
								end)
								:map(function(buf) return buf.bufnr end)
								:totable()
							return recentBufs
						end,
					},
				},
			},
		},
		keymap = {
			-- https://cmp.saghen.dev/configuration/keymap.html
			preset = "none",
			["<CR>"] = { "select_and_accept", "fallback" },
			["<Tab>"] = { "snippet_forward", "select_next", "fallback" },
			["<S-Tab>"] = { "snippet_backward", "select_prev", "fallback" },
			["<D-g>"] = { "show_signature", "hide_signature" },
			["<PageDown>"] = { "scroll_signature_down", "scroll_documentation_down", "fallback" },
			["<PageUp>"] = { "scroll_signature_up", "scroll_documentation_up", "fallback" },
			["<D-c>"] = { "show", "hide" },
		},
		signature = {
			enabled = true,
			trigger = {
				show_on_accept = true,
				show_on_accept_on_trigger_character = true,

				-- BUG https://github.com/Saghen/blink.cmp/issues/1670
				show_on_insert = false,
				show_on_insert_on_trigger_character = false,
			},
			window = {
				max_width = 65,
				max_height = 12,
				direction_priority = { "s", "n" }, -- south first, to not block existing code
				show_documentation = true,
				winhighlight = "Normal:ColorColumn", -- usually darker, so more contrast
			},
		},
		completion = {
			trigger = {
				show_in_snippet = false, -- since we overload `<Tab>` with jumping & selection
			},
			list = {
				cycle = { from_top = false }, -- cycle at bottom, but not at the top
			},
			documentation = {
				auto_show = true,
				auto_show_delay_ms = 250,
				window = { max_width = 50, max_height = 20 },
			},
			menu = {
				max_height = 12,
				draw = {
					align_to = "none", -- keep in place
					treesitter = { "lsp" },
					columns = {
						{ "label", "label_description", "kind_icon", gap = 1 },
					},
					components = {
						label = {
							width = { max = 45 },
							text = function(ctx)
								return ctx.label .. " " .. ctx.label_detail:gsub("%.md$", "")
							end,
						},
						label_description = { width = { max = 20 } },
						kind_icon = {
							text = function(ctx)
								local source, client =
									ctx.item.source_id, vim.lsp.get_client_by_id(ctx.item.client_id)
								local clientName = client and client.name

								if source == "cmdline" then return "" end
								if source == "snippets" then return "󰩫" end
								if source == "buffer" then return "﬘" end
								if source == "path" then return "" end
								if clientName == "emmet_language_server" then return "" end
								return ctx.kind_icon
							end,
						},
					},
				},
			},
		},
		appearance = {
			-- make lsp icons different from the corresponding similar blink sources
			kind_icons = {
				Text = "󰉿", -- `buffer`
				Snippet = "󰞘", -- `snippets`
				File = "", -- `path`
				Module = "", -- prettier braces
			},
		},
	},
}
