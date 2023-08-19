-- Checks when the outside temperature passes the inside temperature or vice versa.

-- only run in the summer
local month = tostring(os.date("%B")):sub(1, 3)
if month ~= "Aug" or month ~= "Jul" or month ~= "Sep" then return end

--------------------------------------------------------------------------------

-- CONFIG
-- INFO right-click on a location in Google Maps to get the latitude/longitude
-- roughly Berlin-Tegel (no precise location due to pricacy)
local latitude = 52
local longitude = 13
local inTemp = 24.5
local checkIntervalMins = 30

--------------------------------------------------------------------------------

local env = require("lua.environment-vars")
local u = require("lua.utils")

local callUrl = ("https://api.brightsky.dev/current_weather?lat=%s&lon=%s"):format(latitude, longitude)
PrevOutTemp = nil -- no value on first run

local function getOutsideTemp()
	if not (u.betweenTime(18, 1) or u.betweenTime(8, 13)) then return end
	hs.http.asyncGet(callUrl, nil, function(status, body, _)
		if status ~= 200 then
			print("Could not get weather data: " .. status)
			return
		end
		local outTemp = hs.json.decode(body).weather.temperature
		if not outTemp then return end

		-- first run has no value yet
		if not PrevOutTemp then
			PrevOutTemp = outTemp
			return
		end
		local outsideNowCoolerThanInside = outTemp < inTemp and not (PrevOutTemp < inTemp)
		local outsideNowHotterThanInside = outTemp > inTemp and not (PrevOutTemp > inTemp)
		PrevOutTemp = outTemp

		if outsideNowCoolerThanInside then
			hs.alert.show("🌡️🔵 Outside now cooler than inside.")
			u.sound("Funk")
		elseif outsideNowHotterThanInside then
			hs.alert.show("🌡️🔴 Outside now hotter than inside.")
			u.sound("Funk")
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
