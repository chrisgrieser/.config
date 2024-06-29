local cc = require("tinygit.config").config.commitMsg.conventionalCommits.keywords
local regex = [[\v(]] .. table.concat(cc, "|") .. [[)(\(.{-}\))?\ze: ]]
vim.notify("👾 regex: " .. tostring(regex))
vim.fn.matchadd("Title", regex)

-- fix: blaaaa
