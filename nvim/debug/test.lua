local M = {}
--------------------------------------------------------------------------------

setmetatable(M, {
	__index = function(_, key)
		return function(...)
			local moduleToRedirectTo = "tinygit.commands"
			require(moduleToRedirectTo)[key](...)
		end
	end,
})

--------------------------------------------------------------------------------
return M
