require("lua.utils")
--------------------------------------------------------------------------------
-- learn which objects do stuff here
Learn = hs.distributednotifications.new(
	function(name, object, userInfo)
		Notify("name:", name)
		print("object:", object)
		print("userInfo: ", hs.inspect(userInfo))
	end
):start()
