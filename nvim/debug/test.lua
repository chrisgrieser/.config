local cc = require("tinygit.config").config.commitMsg.conventionalCommits.keywords
local ccRegex = [[\v(]] .. table.concat(cc, "|") .. [[)(\(.{-}\))?!?\ze: ]]
vim.fn.matchadd("Title", ccRegex)

-- fix: ffffff
-- fix(scope): fffffff
-- fix(scope)!: ffffff
-- fix!: ffffff
