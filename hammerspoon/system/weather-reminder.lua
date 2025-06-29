-- INFO This module will notify when the outside temperature passes the inside
-- temperature or vice versa.
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

-- GUARD
local curMonth = tostring(os.date("%b"))
local enabledForThisMonth = hs.fnutils.contains(config.activeInMonths, curMonth)
local isAtHome = require("meta.environment").isAtHome
if not enabledForThisMonth or not isAtHome then return end

--------------------------------------------------------------------------------

local M = {} -- persist from garbage collector
local u = require("meta.utils")

local function soundNotify(msg)
	msg = "🌡" .. msg
	hs.alert(msg)
	print(msg)
	hs.sound.getByName("Funk"):volume(0.5):play() ---@diagnostic disable-line: undefined-field
end

--------------------------------------------------------------------------------

-- DOCS https://brightsky.dev/docs/#get-/current_weather
local callUrl = ("https://api.brightsky.dev/current_weather?lat=%d&lon=%d"):format(
	config.latitude,
	config.longitude
)

local function getOutsideTemp()
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
			soundNotify("🔵 Outside now cooler than inside.")
		elseif outsideNowHotterThanInside then
			soundNotify("🔴 Outside now hotter than inside.")
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
