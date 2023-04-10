local M = {}
--------------------------------------------------------------------------------

Capabilities = {
  codeActionProvider = {
    codeActionKinds = { "", "quickfix", "refactor.rewrite", "refactor.extract" },
    resolveProvider = false
  },
  codeLensProvider = {
    resolveProvider = true
  },
  colorProvider = true,
  completionProvider = {
    resolveProvider = true,
    triggerCharacters = { "\t", "\n", ".", ":", "(", "'", '"', "[", ",", "#", "*", "@", "|", "=", "-", "{", " ", "+", "?" }
  },
  definitionProvider = true,
  documentFormattingProvider = true,
  documentHighlightProvider = true,
  documentOnTypeFormattingProvider = {
    firstTriggerCharacter = "\n"
  },
  documentRangeFormattingProvider = true,
  documentSymbolProvider = true,
  executeCommandProvider = {
    commands = { "lua.removeSpace", "lua.solve", "lua.jsonToLua", "lua.setConfig", "lua.getConfig", "lua.autoRequire" }
  },
  foldingRangeProvider = true,
  hoverProvider = true,
  inlayHintProvider = {
    resolveProvider = true
  },
  offsetEncoding = "utf-16",
  referencesProvider = true,
  renameProvider = {
    prepareProvider = true
  },
  semanticTokensProvider = {
    full = true,
    legend = {
      tokenModifiers = { "declaration", "definition", "readonly", "static", "deprecated", "abstract", "async", "modification", "documentation", "defaultLibrary", "global" },
      tokenTypes = { "namespace", "type", "class", "enum", "interface", "struct", "typeParameter", "parameter", "variable", "property", "enumMember", "event", "function", "method", "macro", "keyword", "modifier", "comment", "string", "number", "regexp", "operator", "decorator" }
    },
    range = true
  },
  signatureHelpProvider = {
    triggerCharacters = { "(", "," }
  },
  textDocumentSync = {
    change = 2,
    openClose = true,
    save = {
      includeText = false
    }
  },
  typeDefinitionProvider = true,
  workspace = {
    fileOperations = {
      didRename = {
        filters = { {
            pattern = {
              glob = "/Users/chrisgrieser/.config/nvim/**",
              options = {
                ignoreCase = true
              }
            }
          } }
      }
    },
    workspaceFolders = {
      changeNotifications = true,
      supported = true
    }
  },
  workspaceSymbolProvider = true
}

--------------------------------------------------------------------------------
return M

