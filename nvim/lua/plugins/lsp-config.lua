local u = require("config.utils")
--------------------------------------------------------------------------------
-- DOCS https://github.com/neovim/nvim-lspconfig/tree/master/lua/lspconfig/server_configurations
--------------------------------------------------------------------------------

---since nvim-lspconfig and mason.nvim use different package names
---mappings from https://github.com/williamboman/mason-lspconfig.nvim/blob/main/lua/mason-lspconfig/mappings/server.lua

---@type table<string, string>
local lspToMasonMap = {
	basedpyright = "basedpyright", -- python lsp (fork of pyright)
	bashls = "bash-language-server", -- also used for zsh
	biome = "biome", -- ts/js/json/css linter/formatter
	css_variables = "css-variables-language-server",
	cssls = "css-lsp",
	efm = "efm", -- linter integration (only used for shellcheck & just)
	emmet_language_server = "emmet-language-server", -- css/html snippets
	jsonls = "json-lsp",
	ltex = "ltex-ls", -- languagetool (natural language linter)
	lua_ls = "lua-language-server",
	marksman = "marksman", -- markdown lsp
	ruff = "ruff", -- python linter & formatter
	stylelint_lsp = "stylelint-lsp", -- css linter
	taplo = "taplo", -- toml lsp
	tsserver = "typescript-language-server",
	typos_lsp = "typos-lsp", -- spellchecker for code
	vale_ls = "vale-ls", -- natural language linter, used for markdown
	yamlls = "yaml-language-server",
}

---@type table<string, lspconfig.Config>
local serverConfigs = {}
for lspName, _ in pairs(lspToMasonMap) do
	serverConfigs[lspName] = {}
end

--------------------------------------------------------------------------------
-- BASH / ZSH

local extraDependencies = {
	"shfmt", -- used by bashls for formatting
	"shellcheck", -- used by bashls/efm for diagnostics, PENDING https://github.com/bash-lsp/bash-language-server/issues/663
	"actionlint",
}

-- DOCS https://github.com/bash-lsp/bash-language-server/blob/main/server/src/config.ts
serverConfigs.bashls = {
	filetypes = { "sh", "zsh", "bash" }, -- for to work in other shells
	settings = {
		bashIde = {
			shellcheckPath = "", -- disable while using efm
			shellcheckArguments = "--shell=bash", -- PENDING https://github.com/bash-lsp/bash-language-server/issues/1064
			shfmt = { spaceRedirects = true },
		},
	},
}

-- HACK use efm to force shellcheck to work with zsh files via `--shell=bash`,
-- since doing so with bash-lsp does not work
-- DOCS https://github.com/mattn/efm-langserver#configuration-for-neovim-builtin-lsp-with-nvim-lspconfig
-- DOCS https://github.com/creativenull/efmls-configs-nvim/tree/main/lua/efmls-configs/linters
local efmTools = {
	zsh = {
		{
			lintSource = "shellcheck",
			lintCommand = "shellcheck --format=gcc --external-sources --shell=bash -",
			lintStdin = true,
			lintFormats = {
				"-:%l:%c: %trror: %m [SC%n]",
				"-:%l:%c: %tarning: %m [SC%n]",
				"-:%l:%c: %tote: %m [SC%n]",
			},
			rootMarkers = { ".git" },
		},
	},
	just = {
		{
			lintSource = "just",
			lintCommand = 'just --summary --justfile="${INPUT}"',
			lintStdin = false,
			lintFormats = { "%Aerror: %m", "%C  ——▶ %f:%l:%c%Z" }, -- multiline format
			rootMarkers = { "Justfile", ".justfile" },
		},
	},
	yaml = {
		{
			lintSource = "actionlint",
			-- condition ensures that issue templates are not linted
			lintCommand = '[[ ${INPUT} =~ ".github/workflows/" ]] && actionlint -no-color -oneline -stdin-filename ${INPUT} -',
			lintStdin = true,
			lintFormats = {
				-- actionlint integrates shellcheck, which are the following three
				-- (they must come before the actionlint's own errors)
				"%f:%l:%c: %.%#: SC%n:%trror:%m",
				"%f:%l:%c: %.%#: SC%n:%tarning:%m",
				"%f:%l:%c: %.%#: SC%n:%tnfo:%m",
				-- actionlint's own errors
				"%f:%l:%c: %m",
			},
			requireMarker = true,
			rootMarkers = { ".github/" },
		},
	},
}

serverConfigs.efm = {
	root_dir = function()
		local markers = vim.iter(vim.tbl_values(efmTools))
			:map(function(lang) return lang[1].rootMarkers end)
			:flatten()
			:totable()
		return vim.fs.root(0, markers)
	end,

	filetypes = vim.tbl_keys(efmTools),
	settings = { languages = efmTools },

	-- cleanup useless empty folder efm creates on startup
	on_attach = function() os.remove(vim.fs.normalize("~/.config/efm-langserver")) end,
}

--------------------------------------------------------------------------------
-- LUA

-- DOCS https://luals.github.io/wiki/settings/
serverConfigs.lua_ls = {
	settings = {
		Lua = {
			completion = {
				callSnippet = "Replace",
				keywordSnippet = "Replace",
				showWord = "Disable", -- don't suggest common words as fallback
				workspaceWord = false, -- already done by cmp-buffer
				postfix = "..", -- useful for `table.insert` and the like
			},
			diagnostics = {
				disable = { "trailing-space" }, -- formatter already handles that
			},
			hint = { -- inlay hints
				enable = true,
				setType = true,
				arrayIndex = "Disable", -- too noisy
				semicolon = "Disable", -- mostly wrong on invalid code
			},
			-- FIX https://github.com/sumneko/lua-language-server/issues/679#issuecomment-925524834
			workspace = { checkThirdParty = "Disable" },
		},
	},
}

--------------------------------------------------------------------------------
-- PYTHON

-- DOCS https://docs.astral.sh/ruff/editors/settings/
serverConfigs.ruff = {
	init_options = {
		settings = {
			organizeImports = false, -- if "I" ruleset is added, already included in "fixAll"
			codeAction = { disableRuleComment = { enable = false } }, -- using nvim-rulebook instead
		},
	},
	-- disable in favor of pyright's hover info
	on_attach = function(ruff) ruff.server_capabilities.hoverProvider = false end,
}

--------------------------------------------------------------------------------
-- CSS

-- DOCS
-- https://github.com/sublimelsp/LSP-css/blob/master/LSP-css.sublime-settings
-- https://github.com/microsoft/vscode-css-languageservice/blob/main/src/services/lintRules.ts
serverConfigs.cssls = {
	-- using `biome` instead (this key overrides `settings.format.enable = true`)
	init_options = { provideFormatter = false },

	settings = {
		css = {
			lint = {
				vendorPrefix = "ignore", -- needed for scrollbars
				duplicateProperties = "warning",
				zeroUnits = "warning",
			},
		},
	},
}

serverConfigs.css_variables = {
	root_dir = function()
		-- Add custom root markers for Obsidian snippet folders.
		local markers = { ".project-root", ".git" }
		return vim.fs.root(0, markers)
	end,
}

-- DOCS https://github.com/bmatcuk/stylelint-lsp#settings
serverConfigs.stylelint_lsp = {
	filetypes = { "css", "scss" }, -- don't enable on js/ts, since I don't need it there
	settings = {
		stylelintplus = { autoFixOnFormat = true },
	},
}

-- DOCS https://github.com/olrtg/emmet-language-server#neovim
serverConfigs.emmet_language_server = {
	filetypes = { "html", "css", "scss" },
	init_options = {
		showSuggestionsAsSnippets = true,
	},
}

--------------------------------------------------------------------------------
-- JS/TS

-- DOCS https://github.com/typescript-language-server/typescript-language-server/blob/master/docs/configuration.md
serverConfigs.tsserver = {
	settings = {
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
			-- even formatting disabled still relevant for `organizeImports` code action
			format = { convertTabsToSpaces = false },
		},

		-- enable checking javascript without a `jsconfig.json`
		-- DOCS https://www.typescriptlang.org/tsconfig
		implicitProjectConfiguration = { checkJs = true, target = "ES2022" },
	},
	on_attach = function(client)
		-- disable formatting in favor of biome
		client.server_capabilities.documentFormattingProvider = false
		client.server_capabilities.documentRangeFormattingProvider = false
	end,
}
serverConfigs.tsserver.settings.javascript = serverConfigs.tsserver.settings.typescript

--------------------------------------------------------------------------------

-- DOCS https://github.com/Microsoft/vscode/tree/main/extensions/json-language-features/server#configuration
serverConfigs.jsonls = {
	-- Disable formatting in favor of biome
	init_options = {
		provideFormatter = false,
		documentRangeFormattingProvider = false,
	},
}

-- DOCS https://github.com/redhat-developer/yaml-language-server/tree/main#language-server-settings
serverConfigs.yamlls = {
	settings = {
		yaml = {
			format = {
				enable = true,
				printWidth = 100,
				proseWrap = "always",
			},
		},
	},
}

--------------------------------------------------------------------------------
-- LTEX (LanguageTool LSP)

---necessary helper function, as ltex, vale, etc lack ignore files.
---This is to be used as `on_attach` function, as returning nil as root prevents
---the LSP from attaching.
---@param client vim.lsp.Client
---@param bufnr number
local function detachIfObsidianOrIcloud(client, bufnr)
	local path = vim.api.nvim_buf_get_name(bufnr)
	local obsiDir = #vim.fs.find(".obsidian", { path = path, upward = true, type = "directory" }) > 0
	local iCloudDocs = vim.startswith(path, os.getenv("HOME") .. "/Documents/")
	if obsiDir or iCloudDocs then
		-- delay, so it's ensured the client is attached
		vim.defer_fn(function() vim.lsp.buf_detach_client(bufnr, client.id) end, 500)
		vim.diagnostic.enable(false, { bufnr = 0 })
	end
end

-- DOCS https://valentjn.github.io/ltex/settings.html
serverConfigs.ltex = {
	filetypes = { "markdown" }, -- not in .txt files, as those are used by `pass`
	settings = {
		ltex = {
			language = "en-US", -- can also be set per file via markdown yaml header (e.g. `de-DE`)
			dictionary = {
				-- HACK since reading external file with the method described in ltex-docs[^1] does not work
				-- [1]: https://valentjn.github.io/ltex/vscode-ltex/setting-scopes-files.html#external-setting-files
				["en-US"] = (function()
					if not vim.uv.fs_stat(vim.o.spellfile) then
						u.notify("ltex", "Spellfile not found: " .. vim.o.spellfile, "warn")
						return {}
					end
					local words = {}
					for word in io.lines(vim.o.spellfile) do
						table.insert(words, word)
					end
					return words
				end)(),
			},
			disabledRules = {
				["en-US"] = {
					"EN_QUOTES", -- don't expect smart quotes
					"WHITESPACE_RULE", -- too many false positives
				},
			},
			diagnosticSeverity = {
				default = "info",
				MORFOLOGIK_RULE_EN_US = "hint",
			},
			additionalRules = {
				enablePickyRules = true,
				mothersTongue = "de-DE",
			},
			markdown = {
				nodes = { Link = "dummy" }, -- don't check link text
			},
		},
	},
	on_attach = function(ltex, bufnr)
		-- have `zg` update ltex' dictionary file as well as vim's spellfile
		vim.keymap.set({ "n", "x" }, "zg", function()
			local word
			if vim.fn.mode() == "n" then
				word = vim.fn.expand("<cword>")
				u.normal("zg")
			else
				u.normal('zggv"zy')
				word = vim.fn.getreg("z")
			end
			local ltexSettings = ltex.config.settings
			table.insert(ltex.config.settings.ltex.dictionary["en-US"], word)
			vim.lsp.buf_notify(0, "workspace/didChangeConfiguration", { settings = ltexSettings })
		end, { desc = "󰓆 Add Word", buffer = bufnr })

		detachIfObsidianOrIcloud(ltex, bufnr)
	end,
}

-- TYPOS
-- DOCS https://github.com/tekumara/typos-lsp/blob/main/docs/neovim-lsp-config.md
serverConfigs.typos_lsp = {
	init_options = { diagnosticSeverity = "Information" }, -- Information|Warning|Hint|Error
}

-- VALE
-- DOCS https://vale.sh/docs/integrations/guide/#vale-ls
-- DOCS https://vale.sh/docs/topics/config#search-process
serverConfigs.vale_ls = {
	filetypes = { "markdown" }, -- not in txt files, as those are used by `pass`

	init_options = {
		configPath = vim.g.linterConfigs .. "/vale/vale.ini",
		installVale = true,
		syncOnStartup = false,
	},

	-- FIX https://github.com/errata-ai/vale-ls/issues/4
	cmd_env = { VALE_CONFIG_PATH = vim.g.linterConfigs .. "/vale/vale.ini" },

	on_attach = detachIfObsidianOrIcloud,
}

--------------------------------------------------------------------------------

return {
	{
		"neovim/nvim-lspconfig",
		event = "BufReadPre",
		mason_dependencies = vim.list_extend(extraDependencies, vim.tbl_values(lspToMasonMap)),
		config = function()
			require("lspconfig.ui.windows").default_options.border = vim.g.borderStyle

			-- Enable completion (nvim-cmp) and folding (nvim-ufo)
			local capabilities = vim.lsp.protocol.make_client_capabilities()
			capabilities.textDocument.completion.completionItem.snippetSupport = true
			capabilities.textDocument.foldingRange =
				{ dynamicRegistration = false, lineFoldingOnly = true }

			for lspName, serverConfig in pairs(serverConfigs) do
				serverConfig.capabilities = capabilities
				require("lspconfig")[lspName].setup(serverConfig)
			end
		end,
	},
}
