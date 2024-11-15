for i = 1, 10 do
	vim.defer_fn(function ()
		vim.notify(("f"):rep(i), nil, { id = "test" })
	end, i * 500)
end


