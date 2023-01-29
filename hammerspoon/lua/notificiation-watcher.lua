require("lua.utils")
--------------------------------------------------------------------------------
-- learn which objects do stuff here
learn = hs.distributednotifications.new(
	function(name, object, userInfo)
		notify("name:", name)
		print("object:", object)
		print("userInfo: ", hs.inspect(userInfo))
	end
):start()
