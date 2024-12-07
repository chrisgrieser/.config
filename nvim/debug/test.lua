local ns = vim.api.nvim_create_namespace("conflictMrkers")

vim.api.nvim_buf_set_extmark(0, ns, 0, 0, { end_row = 10, sign_text = "1" })
-- 1
-- 1
-- ffsffsf

-- some some

-- some some

-- 1
-- ffsfsfsfffffffffffffffff
-- 1
-- 1
-- 3034u3fffffffffffffffff
-- 1
-- 1
-- 1
