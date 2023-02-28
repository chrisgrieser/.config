require("config.utils")
-- INFO: required order of setup() calls is mason, mason-config, nvim-dev, lspconfig
-- https://github.com/williamboman/mason-lspconfig.nvim#setup
--------------------------------------------------------------------------------

-- INFO: Server names are LSP names, not Mason names
-- https://github.com/williamboman/mason-lspconfig.nvim#available-lsp-servers
local lsp_servers = {
	"lua_ls",
	"yamlls",
	"jsonls",
	"cssls",
	"emmet_ls", -- css & html completion
	"pyright", -- python
	"marksman", -- markdown
	"tsserver", -- ts/js
	"eslint", -- ts/js
	"bashls", -- also used for zsh
	"taplo", -- toml
}

--------------------------------------------------------------------------------

-- SIGN-COLUMN ICONS
local signIcons = {
	Error = "",
	Warn = "▲",
	Info = "",
	Hint = "",
}
for type, icon in pairs(signIcons) do
	local hl = "DiagnosticSign" .. type
	fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
end

-- BORDERS
require("lspconfig.ui.windows").default_options.border = BorderStyle
vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, { border = BorderStyle })
-- stylua: ignore
vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, { border = BorderStyle })

--------------------------------------------------------------------------------
-- DIAGNOSTICS (also applies to null-ls)
-- stylua: ignore start
keymap("n", "ge", function() vim.diagnostic.goto_next { wrap = true, float = true } end, { desc = "璉Next Diagnostic" })
keymap("n", "gE", function() vim.diagnostic.goto_prev { wrap = true, float = true } end, { desc = "璉Previous Diagnostic" })
-- stylua: ignore end

-- LSP lines
vim.keymap.set( "n", "<leader>d", function ()
	require("lsp_lines").toggle()
	vim.diagnostic.config.virtual_text = not vim.diagnostic.config.virtual_text

	vim.diagnostic.disable(0)
	vim.diagnostic.enable(0)
end, { desc = "璉 Show More Diagnostics" })
-- keymap("n", "<leader>d", vim.diagnostic.open_float, { desc = "璉Show Diagnostic" })

local function diagnosticFormat(diagnostic, mode)
	local msg = diagnostic.message:gsub("^%s*", ""):gsub("%s*$", "")
	local source = diagnostic.source and diagnostic.source:gsub("%.$", "") or ""
	local code = tostring(diagnostic.code)
	local out = msg .. " (" .. code .. ")"

	-- stylelint and already includes the code in the message, some linters without code
	if source == "stylelint" then out = msg end
	if diagnostic.source and mode == "float" then out = out .. " [" .. source .. "]" end
	return out
end

vim.diagnostic.config {
	virtual_text = {
		format = function(diagnostic) return diagnosticFormat(diagnostic, "virtual_text") end,
		severity = { min = vim.diagnostic.severity.WARN },
	},
	float = {
		focusable = false,
		border = BorderStyle,
		max_width = 50,
		header = "", -- remove "Diagnostics:" heading
		format = function(diagnostic) return diagnosticFormat(diagnostic, "float") end,
	},
}

--------------------------------------------------------------------------------
-- Mason Config
require("mason").setup {
	ui = {
		border = BorderStyle,
		icons = { package_installed = "✓", package_pending = "羽", package_uninstalled = "✗" },
	},
}
require("mason-lspconfig").setup {
	ensure_installed = lsp_servers,
}

--------------------------------------------------------------------------------
-- LSP PLUGINS
require("lsp_signature").setup {
	floating_window = false,
	hint_prefix = "﬍ ",
	hint_scheme = "NonText", -- highlight group
}

require("lsp-inlayhints").setup {
	inlay_hints = {
		parameter_hints = {
			show = true,
			prefix = " ",
			remove_colon_start = true,
			remove_colon_end = true,
		},
		type_hints = {
			show = true,
			prefix = "   ",
			remove_colon_start = true,
			remove_colon_end = true,
		},
		only_current_line = true,
		highlight = "NonText", -- highlight group
	},
}

-- INFO: this block must come before lua LSP setup
require("neodev").setup {
	library = { plugins = false },
}

--------------------------------------------------------------------------------
-- LSP KEYBINDINGS

-- fallback for languages without an action LSP
keymap("n", "gs", function() cmd.Telescope("treesitter") end, { desc = " Document Symbol" })

-- actions defined globally so null-ls can use them without LSP
keymap({ "n", "x" }, "<leader>c", vim.lsp.buf.code_action, { desc = "璉Code Action" })

augroup("LSP", {})
autocmd("LspAttach", {
	group = "LSP",
	callback = function(args)
		local bufnr = args.buf
		local client = vim.lsp.get_client_by_id(args.data.client_id)
		local capabilities = client.server_capabilities

		require("lsp-inlayhints").on_attach(client, bufnr)

		if capabilities.renameProvider then
			-- overrides treesitter-refactor's rename
			keymap("n", "<leader>R", vim.lsp.buf.rename, { desc = "璉Var Rename", buffer = true })
		end

		-- stylua: ignore start
		if capabilities.documentSymbolProvider and client.name ~= "cssls" then
			require("nvim-navic").attach(client, bufnr)
			keymap("n", "gs", function() cmd.Telescope("lsp_document_symbols") end, { desc = "璉Document Symbols", buffer = true }) -- overrides treesitter symbols browsing
			keymap("n", "gS", function() cmd.Telescope("lsp_workspace_symbols") end, { desc = "璉Workspace Symbols", buffer = true })
		end
		keymap("n", "gd", function() cmd.Telescope("lsp_definitions") end, { desc = "璉Goto definition", buffer = true })
		keymap("n", "gf", function() cmd.Telescope("lsp_references") end, { desc = "璉Goto Re[f]erence", buffer = true })
		keymap("n", "gy", function() cmd.Telescope("lsp_type_definitions") end, { desc = "璉Goto T[y]pe Definition", buffer = true })
		keymap({ "n", "i", "x" }, "<C-s>", vim.lsp.buf.signature_help, {desc = "璉Signature", buffer = true})
		keymap("n", "<leader>h", vim.lsp.buf.hover, {desc = "璉Hover", buffer = true})

		-- Formatters

		-- avoid conflict of tsserver with prettier
		if client.name == "tsserver" then capabilities.documentFormattingProvider = false end

		keymap({ "n", "i" }, "<D-s>", function()
			if bo.filetype == "applescript" then
				cmd.mkview(2)
				normal("gg=G") -- poor man's formatting
				vim.lsp.buf.format { async = false } -- still used for null-ls-codespell
				cmd.loadview(2)
			else
				vim.lsp.buf.format { async = true }
			end
			cmd.write()
		end, {buffer = true, desc = "璉 Save & Format"})
		-- stylua: ignore end
	end,
})

-- copy breadcrumbs (nvim navic)
keymap("n", "<D-b>", function()
	if require("nvim-navic").is_available() then
		local rawdata = require("nvim-navic").get_data()
		local breadcrumbs = ""
		for _, v in pairs(rawdata) do
			breadcrumbs = breadcrumbs .. v.name .. "."
		end
		breadcrumbs = breadcrumbs:sub(1, -2)
		fn.setreg("+", breadcrumbs)
		vim.notify("COPIED\n" .. breadcrumbs)
	else
		vim.notify("No Breadcrumbs available.", logWarn)
	end
end, { desc = "璉Copy Breadcrumbs" })

--------------------------------------------------------------------------------
-- LSP-SERVER-SPECIFIC SETUP

local lspSettings = {}
local lspFileTypes = {}

-- https://github.com/LuaLS/lua-language-server/wiki/Annotations#annotations
-- https://github.com/LuaLS/lua-language-server/wiki/Settings
lspSettings.lua_ls = {
	Lua = {
		format = { enable = false }, -- using stylua instead. Also, sumneko-lsp-formatting has this weird bug where all folds are opened
		completion = {
			callSnippet = "Replace",
			keywordSnippet = "Replace",
			displayContext = 2,
		},
		-- libraries defined per-project via luarc.json location: https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md#sumneko_lua
		diagnostics = {
			disable = { "trailing-space" },
		},
		workspace = { checkThirdParty = false }, -- HACK https://github.com/sumneko/lua-language-server/issues/679#issuecomment-925524834
		hint = {
			enable = true,
			setType = true,
			paramName = "All",
			paramType = true,
			arrayIndex = "Disable",
		},
		telemetry = { enable = false },
	},
}

-- https://github.com/sublimelsp/LSP-css/blob/master/LSP-css.sublime-settings
lspSettings.cssls = {
	css = {
		lint = {
			vendorPrefix = "ignore",
			propertyIgnoredDueToDisplay = "error",
			universalSelector = "ignore",
			float = "ignore",
			boxModel = "ignore",
			-- since these would be duplication with stylelint
			duplicateProperties = "ignore",
			emptyRules = "warning",
		},
		colorDecorators = { enable = true }, -- not supported yet
	},
}

local jsAndTsSettings = {
	-- https://github.com/typescript-language-server/typescript-language-server#workspacedidchangeconfiguration
	format = {}, -- not used, since taken care of by prettier
	inlayHints = {
		includeInlayEnumMemberValueHints = true,
		includeInlayFunctionLikeReturnTypeHints = true,
		includeInlayFunctionParameterTypeHints = true,
		includeInlayParameterNameHints = "all", -- none | literals | all
		includeInlayParameterNameHintsWhenArgumentMatchesName = true,
		includeInlayPropertyDeclarationTypeHints = true,
		includeInlayVariableTypeHints = true,
		includeInlayVariableTypeHintsWhenTypeMatchesName = true,
	},
}

lspSettings.tsserver = {
	completions = { completeFunctionCalls = true },
	diagnostics = {
		-- https://github.com/microsoft/TypeScript/blob/master/src/compiler/diagnosticMessages.json
		ignoredCode = {},
	},
	typescript = jsAndTsSettings,
	javascript = jsAndTsSettings,
}

-- https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md#eslint
lspSettings.eslint = {
	quiet = false, -- = include warnings
	codeAction = {
		disableRuleComment = { location = "sameLine" }, -- add ignore-comments on the same line
	},
}

-- https://github.com/sublimelsp/LSP-json/blob/master/LSP-json.sublime-settings
lspSettings.jsonls = {
	json = {
		validate = { enable = true },
		format = { enable = true },
		schemas = require("schemastore").json.schemas(),
	},
}

--------------------------------------------------------------------------------

lspFileTypes.bashls = { "sh", "zsh", "bash" } -- force lsp to work with zsh
lspFileTypes.emmet_ls = { "css", "scss", "html" }

-- Enable snippet capability for completion (nvim_cmp)
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities.textDocument.completion.completionItem.snippetSupport = true

--------------------------------------------------------------------------------

-- configure all lsp servers
for _, lsp in pairs(lsp_servers) do
	local config = { capabilities = capabilities }
	if lspSettings[lsp] then config.settings = lspSettings[lsp] end
	if lspFileTypes[lsp] then config.filetypes = lspFileTypes[lsp] end

	-- FIX missing root-directory detection for eslint LSP
	if lsp == "eslint" then config.root_dir = require("lspconfig.util").find_git_ancestor end

	require("lspconfig")[lsp].setup(config)
end
