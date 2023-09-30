-- INFO Checks when the outside temperature passes the inside temperature or vice versa.
--------------------------------------------------------------------------------
local env = require("lua.environment-vars")
local u = require("lua.utils")

--------------------------------------------------------------------------------

-- CONFIG
-- INFO right-click on a location in Google Maps to get the latitude/longitude
-- roughly Berlin-Tegel (no precise location due to pricacy)
local latitude = 52
local longitude = 13
local insideTemp = 25
local checkIntervalMins = 30

-- only run in the summer  & at home
local month = tostring(os.date("%B")):sub(1, 3)
local isSummer = (month == "Aug" or month == "Jul" or month == "Sep")
if not isSummer or not env.isAtHome then return end

--------------------------------------------------------------------------------

-- DOCS: https://brightsky.dev/docs/#get-/current_weather
local callUrl = ("https://api.brightsky.dev/current_weather?lat=%s&lon=%s"):format(latitude, longitude)

local function getOutsideTemp()
	if not (u.betweenTime(18, 1) or u.betweenTime(8, 13)) then return end
	hs.http.asyncGet(callUrl, nil, function(status, body, _)
		if status ~= 200 then
			print("⚠️🌡️ Could not get weather data: " .. status)
			return
		end
		---@diagnostic disable-next-line: undefined-field
		local outTemp = hs.json.decode(body).weather.temperature
		if not outTemp then return end

		-- first run has no value yet
		if not PrevOutTemp then
			PrevOutTemp = outTemp
			return
		end
		local outsideNowCoolerThanInside = outTemp < insideTemp and not (PrevOutTemp < insideTemp)
		local outsideNowHotterThanInside = outTemp > insideTemp and not (PrevOutTemp > insideTemp)
		PrevOutTemp = outTemp

		if outsideNowCoolerThanInside then
			hs.alert.show("🌡️🔵 Outside now cooler than inside.")
			u.sound("Funk")
		elseif outsideNowHotterThanInside then
			hs.alert.show("🌡️🔴 Outside now hotter than inside.")
			u.sound("Funk")
		end
	end)
end

--------------------------------------------------------------------------------

-- run once on startup
if u.isSystemStart() then getOutsideTemp() end

-- run on timer
WeatherReminder = hs.timer.doEvery(60 * checkIntervalMins, getOutsideTemp):start()
