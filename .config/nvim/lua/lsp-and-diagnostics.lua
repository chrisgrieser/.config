require("utils")
-- INFO: required order of setup() calls is mason, mason-config, nvim-dev, lspconfig
-- https://github.com/williamboman/mason-lspconfig.nvim#setup
--------------------------------------------------------------------------------

-- INFO: Server names are LSP names, not Mason names
-- https://github.com/williamboman/mason-lspconfig.nvim#available-lsp-servers
local lsp_servers = {
	"sumneko_lua",
	"yamlls",
	"tsserver", -- ts/js
	"jsonls",
	"cssls",
	"marksman", -- markdown
	"ltex", -- markdown
}

--------------------------------------------------------------------------------
-- DIAGNOTICS (also applies to null-ls)
keymap("n", "ge", function() vim.diagnostic.goto_next {wrap = true, float = false} end, {silent = true})
keymap("n", "gE", function() vim.diagnostic.goto_prev {wrap = true, float = false} end, {silent = true})
keymap("n", "<leader>d", function() vim.diagnostic.open_float {focusable = false} end)
-- toggle diagnostics
local diagnosticToggled = true;
keymap("n", "<leader>D", function()
	if diagnosticToggled then
		vim.diagnostic.disable(0)
	else
		vim.diagnostic.enable(0)
	end
	diagnosticToggled = not (diagnosticToggled)
end)

function diagnosticFormat(diagnostic, mode)
	local msg = trim(diagnostic.message)
	local source = diagnostic.source:gsub("%.$", "")
	local code = tostring(diagnostic.code)
	local out

	if source == "stylelint" or code == "nil" then -- stylelint already includes the code in the message, write-good has no codes
		out = msg
	else
		out = msg .. " (" .. code .. ")"
	end
	if diagnostic.source and mode == "float" then
		out = out .. " [" .. source .. "]"
	end
	return out
end

vim.diagnostic.config {
	virtual_text = {
		format = function(diagnostic) return diagnosticFormat(diagnostic, "virtual_text") end,
		severity = {min = vim.diagnostic.severity.WARN},
	},
	float = {
		border = borderStyle,
		max_width = 50,
		format = function(diagnostic) return diagnosticFormat(diagnostic, "float") end,
	}
}


--------------------------------------------------------------------------------
-- Mason Config
require("mason").setup {
	ui = {
		border = borderStyle,
		icons = {package_installed = "✓", package_pending = "羽", package_uninstalled = "✗"}
	}
}
require("mason-update-all").setup()

require("mason-lspconfig").setup {
	-- mason-lspconfig uses the lspconfig servernames, not mason servernames
	-- https://github.com/williamboman/mason-lspconfig.nvim/blob/main/doc/server-mapping.md
	ensure_installed = lsp_servers,
}

--------------------------------------------------------------------------------
-- LSP PLUGINS
require("lsp_signature").setup {
	floating_window = false,
	hint_prefix = "﬍ ",
	hint_scheme = "GhostText", -- highlight group
}

require("lsp-inlayhints").setup {
	inlay_hints = {
		parameter_hints = {
			show = true,
			prefix = "<- ",
			remove_colon_start = true,
			remove_colon_end = true,
		},
		type_hints = {
			show = true,
			prefix = " ", -- 
			remove_colon_start = true,
			remove_colon_end = true,
		},
		only_current_line = true,
		highlight = "GhostText", -- highlight group
	},
}

-- INFO: this block must come before lua LSP setup
require("neodev").setup {
	library = { plugins = false }
}

--------------------------------------------------------------------------------
-- LSP KEYBINDINGS

-- fallback for languages without an action LSP
keymap("n", "gs", telescope.treesitter)

-- actions defined globally so null-ls can use them without LSP being present
keymap({"n", "x"}, "<leader>a", vim.lsp.buf.code_action)

-- Use an on_attach function to only map the following keys
-- after the language server attaches to the current buffer
local function on_attach(client, bufnr) 
	require("lsp-inlayhints").on_attach(client, bufnr) ---@diagnostic disable-line: missing-parameter

	local bufopts = {silent = true, buffer = true}
	keymap("n", "gd", telescope.lsp_definitions, bufopts)
	keymap("n", "gD", telescope.lsp_references, bufopts)
	keymap("n", "gy", telescope.lsp_type_definitions, bufopts)
	keymap("n", "<leader>R", vim.lsp.buf.rename, bufopts)
	keymap({"n", "i", "x"}, "<C-s>", vim.lsp.buf.signature_help)

	-- format on manual saving, except for json
	-- if client.name ~= "jsonls" then
	-- 	keymap("n", "<D-s>", function()
	-- 		vim.lsp.buf.format {async = true}
	-- 		cmd [[write!]]
	-- 	end, bufopts)
	-- end

	if client.name ~= "cssls" then -- don't override navigation marker search for css files
		keymap("n", "gs", telescope.lsp_document_symbols, bufopts) -- overrides treesitter symbols browsing
	end
end

--------------------------------------------------------------------------------
-- Add borders to various lsp windows
require("lspconfig.ui.windows").default_options.border = borderStyle

vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(
	vim.lsp.handlers.hover, {border = borderStyle}
)

vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(
	vim.lsp.handlers.signature_help, {border = borderStyle}
)
--------------------------------------------------------------------------------
-- LSP-SERVER-SPECIFIC SETUP

-- https://github.com/sumneko/lua-language-server/wiki/Annotations#annotations
-- https://github.com/sumneko/lua-language-server/wiki/Settings
local luaSettings = {
	Lua = {
		runtime = {version = "LuaJIT"}, -- used by neovim
		format = {
			enable = true,
			defaultConfig = {
				-- https://github.com/CppCXY/EmmyLuaCodeStyle/blob/master/docs/format_config_EN.md
				-- https://github.com/sumneko/lua-language-server/wiki/Formatter
				quote_style = "double",
				call_arg_parentheses = "remove_table_only",
				-- yes, all these must be strings
				keep_one_space_between_table_and_bracket = "false",
				keep_one_space_between_namedef_and_attribute = "false",
				continuous_assign_table_field_align_to_equal_sign = "false",
				continuation_indent_size = tostring(opt.tabstop:get()),
			},
		},
		completion = {
			callSnippet = "Replace",
			keywordSnippet = "Replace",
			displayContext = 0,
			showWord = "Enable",
		},
		diagnostics = {
			globals = {"vim", "use", "martax"},
			disable = {
				"trailing-space",
				"lowercase-global",
			},
		},
		workspace = {
			library = {home .. ".hammerspoon/Spoons/EmmyLua.spoon/annotations"}
		},
		hint = {
			enable = true,
			setType = true,
			paramName = "All",
			paramType = true,
			arrayIndex = "Disable",
		},
		telemetry = {enable = false},
	}
}

local cssSettings = {
	css = {
		lint = {
			vendorPrefix = "ignore",
			-- since it would be duplication with stylelint
			duplicateProperties = "ignore",
			emptyRules = "ignore",
		},
		colorDecorators = {enable = true}, -- not supported yet
	}
}

-- Enable snippet capability for completion (nvim_cmp)
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities.textDocument.completion.completionItem.snippetSupport = true

-- configure all lsp servers
for _, lsp in pairs(lsp_servers) do
	local config = {on_attach = on_attach, capabilities = capabilities}
	if lsp == "sumneko_lua" then
		config = {
			on_attach = on_attach,
			capabilities = capabilities,
			settings = luaSettings,
		}
	elseif lsp == "cssls" then
		config = {
			on_attach = on_attach,
			capabilities = capabilities,
			settings = cssSettings,
		}
	end
	require("lspconfig")[lsp].setup(config)
end
