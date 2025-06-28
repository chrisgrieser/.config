-- INFO Checks when the outside temperature passes the inside temperature or vice versa.
--------------------------------------------------------------------------------

local config = {
	activeInMonths = { "Jun", "Jul", "Aug", "Sep" },
	checkIntervalMins = 30,
	insideTemp = 25,

	-- INFO right-click on a location in Google Maps to get the latitude/longitude
	-- roughly Berlin-Tegel (WARN no precise location as this dotfile repo is public)
	latitude = 52,
	longitude = 13,
}

--------------------------------------------------------------------------------

local M = {} -- persist from garbage collector

local env = require("meta.environment")
local u = require("meta.utils")
-- GUARD only run in the summer & at home
local curMonth = tostring(os.date("%b"))
if not hs.fnutils.contains(config.activeInMonths, curMonth) or not env.isAtHome then return end

-- DOCS https://brightsky.dev/docs/#get-/current_weather
local callUrl = ("https://api.brightsky.dev/current_weather?lat=%s&lon=%s"):format(
	config.latitude,
	config.longitude
)

local function getOutsideTemp()
	if not (u.betweenTime(18, 1) or u.betweenTime(8, 13)) then return end
	M.task_getWeather = hs.http.asyncGet(callUrl, nil, function(status, body, _)
		if status ~= 200 then
			print("⚠️🌡️ Could not get weather data: " .. status)
			return
		end

		local weatherData = hs.json.decode(body) ---@type table|nil
		if not weatherData then return end
		local outTemp = weatherData.weather.temperature
		if not outTemp then return end

		-- first run has no value yet
		if not M.prevOutTemp then
			M.prevOutTemp = outTemp
			return
		end
		local outsideNowCoolerThanInside = outTemp < config.insideTemp
			and not (M.prevOutTemp < config.insideTemp)
		local outsideNowHotterThanInside = outTemp > config.insideTemp
			and not (M.prevOutTemp > config.insideTemp)
		M.prevOutTemp = outTemp

		if outsideNowCoolerThanInside then
			hs.alert("🌡️🔵 Outside now cooler than inside.")
			hs.sound.getByName("Funk"):play() ---@diagnostic disable-line: undefined-field
		elseif outsideNowHotterThanInside then
			hs.alert("🌡️🔴 Outside now hotter than inside.")
			hs.sound.getByName("Funk"):play() ---@diagnostic disable-line: undefined-field
		end
	end)
end

--------------------------------------------------------------------------------
-- TRIGGERS
-- 1. systemstart
if u.isSystemStart() then getOutsideTemp() end

-- 2. every x minutes
M.timer_weatherReminder = hs.timer.doEvery(60 * config.checkIntervalMins, getOutsideTemp):start()

--------------------------------------------------------------------------------
return M
