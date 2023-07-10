-- Checks when the outside temperature passes the inside temperature or vice
-- versa.
local u = require("lua.utils")

--------------------------------------------------------------------------------
local insideTemp = 24
local outsideTemp = 20

-- LOCATION
-- INFO right-click on a location in Google Maps to get the latitude/longitude
-- roughly Berlin-Tegel (no precise location due to pricacy)
local latitude = 52
local longitude = 13
local callUrl = ("https://api.brightsky.dev/current_weather?lat=%s&lon=%s"):format(latitude, longitude)

hs.http.asyncGet(callUrl, nil, function(
	status,
	body,
	_
) end)
