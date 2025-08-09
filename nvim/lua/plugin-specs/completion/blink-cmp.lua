-- vim: foldlevel=3
-- DOCS https://cmp.saghen.dev/configuration/reference
--------------------------------------------------------------------------------

---PENDING https://github.com/Saghen/blink.cmp/issues/743
---Choice snippets[^1] work with blink, but leave you with a completion via
---vim's popupmenu, for which blink does not provide mappings, thus requiring
---this function
---[^1]: https://code.visualstudio.com/docs/editing/userdefinedsnippets#_choice
---@param action "next"|"prev"|"select"|"select_and_snippet_forward"
---@return boolean success (popupmenu was open)
local function vimPopupmenu(action)
	if vim.fn.pumvisible() == 0 then return false end

	-- https://neovim.io/doc/user/insert.html#_insert-completion-popup-menu
	local key
	if action == "next" then key = "<C-n>" end
	if action == "prev" then key = "<C-p>" end
	if action:find("select") then key = "<C-y>" end
	-- `feedkey` needed to send keys from insert mode
	local feedkey = vim.api.nvim_replace_termcodes(key, true, false, true)
	vim.api.nvim_feedkeys(feedkey, "n", false)

	if action:find("snippet_forward") then vim.schedule(function() vim.snippet.jump(1) end) end

	return true -- `true` -> do not attempts the next command in blink.cmp
end

--------------------------------------------------------------------------------

---@module "lazy.types"
---@type LazyPluginSpec
return {
	"saghen/blink.cmp",
	event = { "InsertEnter", "CmdlineEnter" },
	version = "*", -- REQUIRED to download pre-built binary

	---@module "blink.cmp"
	---@type blink.cmp.Config
	opts = {
		sources = {
			providers = {
				lsp = {
					fallbacks = {}, -- do not use `buffer` as fallback
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
				},
				snippets = {
					-- don't show when triggered manually (= length 0), useful
					-- when manually showing completions to see available fields
					min_keyword_length = 1,
					score_offset = 3,
					opts = { clipboard_register = "+" }, -- register to use for `$CLIPBOARD`
				},
				path = {
					opts = { get_cwd = vim.uv.cwd },
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
							local mins = 15
							local allOpenBuffers = vim.fn.getbufinfo { buflisted = 1, bufloaded = 1 }
							local recentBufs = vim.iter(allOpenBuffers)
								:filter(function(buf)
									local recentlyUsed = os.time() - buf.lastused < (60 * mins)
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
			["<CR>"] = {
				function() return vimPopupmenu("select_and_snippet_forward") end,
				"select_and_accept",
				"fallback",
			},
			["<Tab>"] = {
				function() return vimPopupmenu("next") end,
				"snippet_forward",
				"select_next",
				"fallback",
			},
			["<S-Tab>"] = {
				function() return vimPopupmenu("prev") end,
				"snippet_backward",
				"select_prev",
				"fallback",
			},
			["<S-CR>"] = { "hide" },
			["<D-c>"] = { "show" },
			["<PageDown>"] = { "scroll_documentation_down", "fallback" },
			["<PageUp>"] = { "scroll_documentation_up", "fallback" },
			["<D-g>"] = { "hide_signature", "fallback" }, -- fallback shows full signature
		},
		-- BUG https://github.com/Saghen/blink.cmp/issues/1670
		-- signature disabled and using `lsp-signature` in the meantime
		signature = {
			enabled = false,
			trigger = {
				show_on_insert = true,
				show_on_insert_on_trigger_character = true,
				show_on_accept = true,
				show_on_accept_on_trigger_character = true,
			},
			window = {
				max_width = 60,
				max_height = 4,
				direction_priority = { "s", "n" }, -- south first, to not block existing code
				show_documentation = false, -- show larger documentation regular signature help
				winhighlight = "Normal:ColorColumn", -- usually darker, so more contrast
				border = "none", -- should be small since it appears so often
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
				window = {
					max_width = 50,
					max_height = 20,
				},
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
						label = { width = { max = 45 } },
						label_description = { width = { max = 15 } },
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
