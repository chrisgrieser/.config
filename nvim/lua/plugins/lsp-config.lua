local u = require("config.utils")

--------------------------------------------------------------------------------

local lspsToAutoinstall = {
	"lua_ls",
	"yamlls",
	"jsonls",
	"cssls",
	"emmet_ls", -- css & html completion
	"pyright", -- python LSP
	"jedi_language_server", -- python (has refactor code actions & better hovers)
	"ruff_lsp", -- python
	"marksman", -- markdown
	"biome", -- ts/js/json
	"tsserver", -- ts/js
	"bashls", -- used for zsh
	"taplo", -- toml
	"html",
	"ltex", -- latex/languagetool (requires `openjdk`)
}

--------------------------------------------------------------------------------

---@class lspConfiguration see :h lspconfig-setup
---@field settings? table <string, table>
---@field root_dir? function(filename, bufnr)
---@field filetypes? string[]
---@field init_options? table <string, string|table|boolean>
---@field on_attach? function(client, bufnr)
---@field capabilities? table <string, string|table|boolean|function>
---@field cmd? string[]
---@field autostart? boolean

---@type table<string, lspConfiguration>
local lspServers = {}

for _, lsp in pairs(lspsToAutoinstall) do
	lspServers[lsp] = {}
end

--------------------------------------------------------------------------------
-- LUA

lspServers.lua_ls = {
	-- DOCS https://github.com/LuaLS/lua-language-server/wiki/Settings
	settings = {
		Lua = {
			completion = {
				callSnippet = "Replace",
				keywordSnippet = "Replace",
				postfix = ".", -- useful for `table.insert` and the like
			},
			diagnostics = {
				disable = { "trailing-space" }, -- formatter already does that
				severity = { -- https://github.com/LuaLS/lua-language-server/wiki/Settings#diagnosticsseverity
					["return-type-mismatch"] = "Error",
				},
			},
			hint = {
				enable = true,
				setType = true,
				arrayIndex = "Disable",
			},
			workspace = { checkThirdParty = false }, -- FIX https://github.com/sumneko/lua-language-server/issues/679#issuecomment-925524834
			format = { enable = false }, -- using stylua instead
		},
	},
}

--------------------------------------------------------------------------------
-- PYTHON

lspServers.ruff_lsp = {
	-- DOCS https://github.com/astral-sh/ruff-lsp#settings
	init_options = {
		-- disable, since already included in FixAll when ruff-rules include "I"
		settings = { organizeImports = false },
	},
	-- Disable hover in favor of jedi
	on_attach = function(client) client.server_capabilities.hoverProvider = false end,
}

-- add fix-all code actions to formatting
-- https://github.com/astral-sh/ruff-lsp/issues/119#issuecomment-1595628355
vim.api.nvim_create_autocmd("FileType", {
	pattern = "python",
	callback = function()
		vim.keymap.set("n", "<D-s>", function()
			require("conform").format()
			vim.lsp.buf.code_action { apply = true, context = { only = { "source.fixAll.ruff" } } }
			vim.cmd.update()
		end, { buffer = true, desc = "󰒕 Format & RuffFixAll & Save" })
	end,
})

lspServers.pyright = {
	-- DOCS https://github.com/microsoft/pyright/blob/main/docs/configuration.md
	settings = {
		python = {
			analysis = { diagnosticMode = "workspace" },
		},
	},
	-- Disable hover in favor of jedi
	on_attach = function(client) client.server_capabilities.hoverProvider = false end,
}

lspServers.jedi_language_server = {
	init_options = {
		diagnostics = { enable = true },
	},
}

--------------------------------------------------------------------------------
-- JS/TS/CSS

lspServers.emmet_ls = {
	-- don't pollute completions for js and ts with stuff I don't need
	filetypes = { "html", "css" },
}

-- DOCS https://github.com/microsoft/vscode-css-languageservice/blob/main/src/services/lintRules.ts
lspServers.cssls = {
	settings = {
		css = {
			colorDecorators = { enable = true }, -- not supported yet
			lint = {
				compatibleVendorPrefixes = "ignore",
				vendorPrefix = "ignore",
				unknownVendorSpecificProperties = "ignore",

				unknownProperties = "ignore", -- duplicate with stylelint

				duplicateProperties = "warning",
				emptyRules = "warning",
				importStatement = "warning",
				zeroUnits = "warning",
				fontFaceProperties = "warning",
				hexColorLength = "warning",
				argumentsInColorFunction = "warning",
				unknownAtRules = "warning",
				ieHack = "warning",
				propertyIgnoredDueToDisplay = "warning",
			},
		},
	},
}

lspServers.tsserver = {
	-- DOCS https://github.com/typescript-language-server/typescript-language-server#workspacedidchangeconfiguration
	settings = {
		completions = { completeFunctionCalls = true },
		-- "cannot redeclare block-scoped variable" -> not useful when applied to JXA
		diagnostics = { ignoredCodes = { 2451 } },
		-- enable all the inlay hints
		typescript = {
			inlayHints = {
				includeInlayEnumMemberValueHints = true,
				includeInlayFunctionLikeReturnTypeHints = true,
				includeInlayFunctionParameterTypeHints = true,
				includeInlayParameterNameHints = "all",
				includeInlayParameterNameHintsWhenArgumentMatchesName = true,
				includeInlayPropertyDeclarationTypeHints = true,
				includeInlayVariableTypeHints = true,
				includeInlayVariableTypeHintsWhenTypeMatchesName = true,
			},
		},
		javascript = {
			inlayHints = {
				includeInlayEnumMemberValueHints = true,
				includeInlayFunctionLikeReturnTypeHints = true,
				includeInlayFunctionParameterTypeHints = true,
				includeInlayParameterNameHints = "all",
				includeInlayParameterNameHintsWhenArgumentMatchesName = true,
				includeInlayPropertyDeclarationTypeHints = true,
				includeInlayVariableTypeHints = true,
				includeInlayVariableTypeHintsWhenTypeMatchesName = true,
			},
		},
	},
	-- disable formatting, since taken care of by biome
	on_attach = function(client)
		client.server_capabilities.documentFormattingProvider = false
		client.server_capabilities.documentRangeFormattingProvider = false
	end,
}

--------------------------------------------------------------------------------
-- JSON/YAML

lspServers.jsonls = {
	-- DOCS https://github.com/Microsoft/vscode/tree/main/extensions/json-language-features/server#configuration
	init_options = {
		-- disable formatting, since taken care of by biome
		provideFormatter = false,
	},
}

lspServers.yamlls = {
	settings = {
		-- disable formatting, since taken care of by prettier
		yaml = { format = { enable = false } },
	},
}

--------------------------------------------------------------------------------
-- LTEX

-- HACK since reading external file with the method described in the ltex docs
-- does not work
local function getDictWords(dictfile)
	local fileDoesNotExist = vim.loop.fs_stat(dictfile) == nil
	if fileDoesNotExist then return {} end
	local words = {}
	for word in io.lines(dictfile) do
		table.insert(words, word)
	end
	return words
end

-- INFO path to java runtime engine (the builtin from ltex does not seem to work)
-- here: using `openjdk`, w/ default M1 mac installation path (`brew install openjdk`)
-- HACK set need to set $JAVA_HOME, since `ltex.java.path` does not seem to work
local brewPrefix = vim.trim(vim.fn.system("brew --prefix"))
vim.env.JAVA_HOME = brewPrefix .. "/opt/openjdk/libexec/openjdk.jdk/Contents/Home"

lspServers.ltex = {
	-- DOCS https://valentjn.github.io/ltex/settings.html
	filetypes = { "gitcommit", "markdown" }, -- disable for bibtex and text files
	settings = {
		ltex = {
			completionEnabled = false,
			language = "en-US", -- default language, can be set per-file via markdown yaml header
			dictionary = { ["en-US"] = getDictWords(u.linterConfigFolder .. "/spellfile-vim-ltex.add") },
			disabledRules = {
				["en-US"] = {
					"EN_QUOTES", -- don't expect smart quotes
					"WHITESPACE_RULE", -- too many false positives
					"PUNCTUATION_PARAGRAPH_END", -- too many false positives
					"CURRENCY",
				},
			},
			diagnosticSeverity = {
				default = "hint",
				MORFOLOGIK_RULE_EN_US = "warning", -- spelling
			},
			additionalRules = { enablePickyRules = true },
			markdown = {
				-- ignore links https://valentjn.github.io/ltex/settings.html#ltexmarkdownnodes
				nodes = { Link = "dummy" },
			},
		},
	},
}

--------------------------------------------------------------------------------

local function setupAllLsps()
	-- Enable snippets-completion (nvim_cmp) and folding (nvim-ufo)
	local lspCapabilities = vim.lsp.protocol.make_client_capabilities()
	lspCapabilities.textDocument.completion.completionItem.snippetSupport = true
	lspCapabilities.textDocument.foldingRange = { dynamicRegistration = false, lineFoldingOnly = true }

	for lsp, config in pairs(lspServers) do
		config.capabilities = lspCapabilities
		require("lspconfig")[lsp].setup(config)
	end
end

local function lspCurrentTokenHighlight()
	u.colorschemeMod("LspReferenceWrite", { underdashed = true }) -- i.e. definition
	u.colorschemeMod("LspReferenceRead", { underdotted = true }) -- i.e. reference
	u.colorschemeMod("LspReferenceText", {}) -- too much noise, as is underlines e.g. strings
	vim.api.nvim_create_autocmd("LspAttach", {
		callback = function(args)
			local bufnr = args.buf
			local capabilities = vim.lsp.get_client_by_id(args.data.client_id).server_capabilities
			if not capabilities.documentHighlightProvider then return end

			vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
				callback = vim.lsp.buf.document_highlight,
				buffer = bufnr,
			})
			vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
				callback = vim.lsp.buf.clear_references,
				buffer = bufnr,
			})
		end,
	})
end

--------------------------------------------------------------------------------

return {
	{ -- package manager
		"williamboman/mason.nvim",
		keys = {
			{ "<leader>pm", vim.cmd.Mason, desc = " Mason Overview" },
		},
		opts = {
			ui = {
				border = u.borderStyle,
				height = 0.8, -- so it won't cover the statusline
				icons = { package_installed = "✓", package_pending = "󰔟", package_uninstalled = "✗" },
			},
		},
	},
	{ -- auto-install lsp servers
		"williamboman/mason-lspconfig.nvim",
		event = "VeryLazy",
		dependencies = { "williamboman/mason.nvim", "neovim/nvim-lspconfig" },
		opts = { ensure_installed = lspsToAutoinstall },
	},
	{ -- configure LSPs
		"neovim/nvim-lspconfig",
		dependencies = "folke/neodev.nvim",
		init = function()
			setupAllLsps()
			lspCurrentTokenHighlight()
		end,
		config = function() require("lspconfig.ui.windows").default_options.border = u.borderStyle end,
	},
}
