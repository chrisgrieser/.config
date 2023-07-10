-- Checks when the outside temperature passes the inside temperature or vice
-- versa.
local env = require("lua.environment-vars")
local u = require("lua.utils")
--------------------------------------------------------------------------------

-- CONFIG
-- INFO right-click on a location in Google Maps to get the latitude/longitude
-- roughly Berlin-Tegel (no precise location due to pricacy)
local latitude = 52
local longitude = 13
local insideTemp = 24
local checkIntervalMins = 30

--------------------------------------------------------------------------------

local callUrl = ("https://api.brightsky.dev/current_weather?lat=%s&lon=%s"):format(latitude, longitude)
PreviousOutsideTemp = nil

local function getOutsideTemp()
	hs.http.asyncGet(callUrl, nil, function(status, body, _)
		if status ~= 200 then
			print("Could not get weather data: " .. status)
			return
		end
		local outsideTemp = hs.json.decode(body).weather.temperature
		local outsideNowCoolerThanInside = outsideTemp < insideTemp
			and not (PreviousOutsideTemp < insideTemp)
		PreviousOutsideTemp = outsideTemp -- save for next run

		if outsideNowCoolerThanInside then
			u.notify("🌡️ Outside now cooler than inside.")
		else
			print("🌡️ No Temperature Change.")
		end
	end)
end

--------------------------------------------------------------------------------

if env.isAtHome then
	-- run once on startup
	if not u.isReloading() then getOutsideTemp() end

	-- run on timer
	WeatherReminder = hs.timer.doEvery(60 * checkIntervalMins, getOutsideTemp):start()
end
