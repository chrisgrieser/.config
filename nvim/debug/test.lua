local a = vim.api

local altBufnr = 1
local altPath = a.nvim_buf_get_name(altBufnr)
local curPath = a.nvim_buf_get_name(0)
local valid = a.nvim_buf_is_valid(altBufnr)
local nonSpecial = a.nvim_buf_get_option(altBufnr, "buftype") ~= ""
local exists = vim.loop.fs_stat(altPath) ~= nil
local moreThanOneBuffer = (altPath ~= curPath)
local hasAlt = valid and nonSpecial and exists and moreThanOneBuffer
