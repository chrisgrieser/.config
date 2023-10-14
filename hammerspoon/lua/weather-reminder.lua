-- INFO Checks when the outside temperature passes the inside temperature or vice versa.
--------------------------------------------------------------------------------
local env = require("lua.environment-vars")
local u = require("lua.utils")

local g = {} -- persist from garbage collector
--------------------------------------------------------------------------------

local config = {
	-- INFO right-click on a location in Google Maps to get the latitude/longitude
	-- roughly Berlin-Tegel (no precise location due to pricacy)
	latitude = 52,
	longitude = 13,
	insideTemp = 25,
	checkIntervalMins = 30,
	activeInMonths = { "Aug", "Jul", "Sep" },
}

-- only run in the summer  & at home
local curMonth = tostring(os.date("%b"))
if not u.tbl_contains(config.activeInMonths, curMonth) or not env.isAtHome then return end

--------------------------------------------------------------------------------

-- DOCS: https://brightsky.dev/docs/#get-/current_weather
local callUrl = ("https://api.brightsky.dev/current_weather?lat=%s&lon=%s"):format(
	config.latitude,
	config.longitude
)

local function getOutsideTemp()
	if not (u.betweenTime(18, 1) or u.betweenTime(8, 13)) then return end
	g.task_getWeather = hs.http.asyncGet(callUrl, nil, function(status, body, _)
		if status ~= 200 then
			print("⚠️🌡️ Could not get weather data: " .. status)
			return
		end

		local weatherData = hs.json.decode(body) ---@type table|nil
		if not weatherData then return end
		local outTemp = weatherData.weather.temperature

		-- first run has no value yet
		if not g.prevOutTemp then
			g.prevOutTemp = outTemp
			return
		end
		local outsideNowCoolerThanInside = outTemp < config.insideTemp
			and not (g.prevOutTemp < config.insideTemp)
		local outsideNowHotterThanInside = outTemp > config.insideTemp
			and not (g.PrevOutTemp > config.insideTemp)
		g.prevOutTemp = outTemp

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
-- TRIGGERS

if u.isSystemStart() then getOutsideTemp() end

g.timer_weatherReminder = hs.timer.doEvery(60 * config.checkIntervalMins, getOutsideTemp):start()

--------------------------------------------------------------------------------
return nil, g
