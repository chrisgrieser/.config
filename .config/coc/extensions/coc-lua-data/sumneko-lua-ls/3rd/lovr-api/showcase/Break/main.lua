local Board = require 'board'
local led = require 'led'
local shader = require 'shader'

local DEBUG_backBumper = false -- Set this to "true" and the ball will bounce back instead of dying

-- Oculus Go uses a fixed camera position, so we have to change where things are drawn
local fixedCamera = lovr.headset.getName() == "Oculus Go"

local tim = 0 -- Accumulated time

-- -- -- Constants -- -- --

-- Board constants
local bWidth = 8  -- Cell-size width and height of board
local bHeight = 5
local bDistanceAway = 6 -- Distance from paddle to blocks
local bBackBuffer = 1   -- Space between blocks and back wall
local bKill = -3        -- Distance from paddle to kill plane

-- Constants for drawing cubes
local uWidth = 0.25  -- One "unit"-- one cell in the board
local uHeight = 0.25
local cubeWidth = uWidth - 0.025 -- A cube should be the size of a board cell minus a margin
local cubeHeight = uHeight - 0.025
local gRight =    lovr.math.newVec3(1, 0, 0)   -- The vector basis for coordinates on the board
local gDown =     lovr.math.newVec3(0, 0, -1)
local gCloser =   lovr.math.newVec3(0, 1, 0)
local uRight =    lovr.math.newVec3( gRight*uWidth ) -- Vector basis for coordinates on the board, in units
local uDown =     lovr.math.newVec3( gDown*uHeight )

-- The upper left corner of the board:
local bUlCorner = lovr.math.newVec3( uDown * (bDistanceAway + bHeight) + gRight * -(uWidth * bWidth/2) )
local function bCenter(x,y) -- The center of a specific cell on the board, for drawing
	return bUlCorner + uRight * ( (x-1) + 0.5) + uDown * ( -(y-1) - 0.5)
end
local function bCornerGrid(x, y) -- The corner of a specific cell on the board, for math
	return x - bWidth/2, bDistanceAway + bHeight - y
end
local function bCornerGridReverse(x,y) -- Given a world position, what cell is it?
	x = x + bWidth/2
	y = bDistanceAway + bHeight - y
	return math.floor(x) + 1, math.floor(y) + 1
end

-- Constants for paddle
local pWidth = 2
local pHeight = 1/3
local pSize = lovr.math.newVec3( (gRight*pWidth + gDown*pHeight + gCloser)*cubeHeight )
local function pGrid(x) -- Get paddle center position in world coordinates, given a 0..1 placement
	return -bWidth/2 + bWidth * x
end

-- Constants for "LED" score display
local lCube = uWidth -- Currently LED and board cubes are the same size
-- Vector basis for score display screen:
local lUlRoot = lovr.math.newVec3( bUlCorner + (gDown * 4 + gCloser * 2 + gRight) * uHeight + uRight * (bWidth/2) )
local lRight =  lovr.math.newVec3( gRight * lCube )
local lDown =   lovr.math.newVec3( gCloser * -lCube )

-- Ball constants
local ballWidth = 0.25
local ballRoot = lovr.math.newVec3( gRight*(ballWidth*uWidth/2) )

-- "Scripted sequence" constants
local gameStateDeathRollover = {silence=1.5, tone=3, reset = 3 + 1.753469387755102}
local soundsWinStrum = {1,3,6,2}
local soundsWinStrumSpeed = 8164/44100

-- -- -- State -- -- --

local board = nil       -- Current board
local gameState         -- One of: {}, {"dead", start=[death time], substate=[substate]}, or {"win", start=[win time]}
local gameLevel         -- Current level # (affects speed)
local points            -- Current points scored
local remaining         -- Number of blocks remaining on current board

local controllerModel   -- Current loaded controller model, if any
local sounds            -- Audio objects (to be loaded)

local function newVec2(x, y) return lovr.math.newVec3(x, y, 0) end -- For 2D vecs we'll just ignore z
local function vec2(x, y) return lovr.math.vec3(x, y, 0) end       -- For 2D vecs we'll just ignore z

local ballAt = newVec2(0, 1) -- Current ball position
local ballVel = newVec2()    -- Current ball velocity

-- -- -- Game code -- -- --

function lovr.conf(t)
	t.identity = 'Break it'
	t.window.title = t.identity
end

function gameReset() -- Reset state completely, as if after a death
	gameState = {}
	gameLevel = 1
	points = 0
	ballVel:set(vec2(0.0625 * 60, 0.0625 * 60))
end

function boardReset() -- Reset board contents, as for death or new-level start
	board = Board.fill({}, bWidth, bHeight, true)
	remaining = bWidth*bHeight
end

function lovr.load()
	print("Spatializer", lovr.audio.getSpatializer())

	lovr.graphics.setBackgroundColor(.1, .1, .1)
	lovr.headset.setClipDistance(0.1, 3000)

	gameReset()
	boardReset()
	sounds = {}
	if lovr.audio then
		for i=0,5 do
			table.insert(sounds, lovr.audio.newSource(string.format("break-bwomp-song-1-split-%d.ogg", i)))
		end
		sounds.fail = lovr.audio.newSource("break-buzzer.ogg", {effects=false})
		sounds.restart = lovr.audio.newSource("break-countdown.ogg", {effects=false})
	end
end

local function cube(v) -- Draw board block
	local x,y,z = v:unpack()
	lovr.graphics.cube('fill', x,y,z, cubeWidth)
end
local function ledCube(v) -- Draw score display block
	local x,y,z = v:unpack()
	lovr.graphics.cube('fill', x,y,z, lCube)
end
local function paddle(x) -- Draw paddle. Expect 0..1
	local x,y,z = (gRight*((-0.5 + x)*bWidth*uWidth)):unpack()
	local xd, yd, zd = pSize:unpack()
	lovr.graphics.box('fill', x, y, z, xd, yd, zd)
end
local function ballXyz(bv) -- Get the XYZ position of the ball (for drawing or sound)
	local bx, by = bv:unpack()
	return ballRoot + uRight*bx + uDown*by -- Temporary
end
local function ball(bv) -- Draw the ball
	local x,y,z = ballXyz(bv):unpack()
	lovr.graphics.cube('fill', x, y, z, cubeWidth*ballWidth)
end

local function tie(x) -- tie fighter operator <=>
	if x > 0 then return 1
	elseif x < 0 then return -1
	else return 0
	end
end

-- Display state
local paddleAt = 0.5
local screen = {}

-- The sounds table has a list of "notes" that play in rotating fashion when the ball bounces off something.
local lastSound
local pendingSound = 1
local function nextSound(at, forceSound) -- Play a sound at a position. If forceSound is nil, assume the next "note"
	if lastSound then lastSound:stop() end -- Don't let sounds overlap
	lastSound = forceSound or sounds[pendingSound]
	pendingSound = pendingSound + 1
	if pendingSound > #sounds then pendingSound = 1 end
	if lastSound then
		lastSound:setPose(at.x, at.y, at.z)
		lastSound:play()
	end
end

local function score() -- Block consumed, increment score
	points = points + 1
	remaining = remaining - 1
	if remaining == 0 then -- Beat the level
		gameState = {"win", start=tim, strumAt=0}
	end
end

-- "Cheat" handling
-- At the end of the game, the player can get stuck in a state where they are bouncing eternally,
-- hoping to hit a block but always missing. This is boring, so if the player does a roundtrip
-- paddle->back->paddle->back without hitting a block, just delete a block at random.
local function cheatBackWall() -- Back hit
	if gameState.cheat and gameState.cheat.x then -- A block is picked out to delete (Second clause might be unnecessary)
		Board.set(board, gameState.cheat.x, gameState.cheat.y, false)
		gameState.cheat.x = false
		score()
	end
end
local function cheatPaddle() -- Paddle hit
	-- If the cheat is not disarmed (ie: we've hit the back and come back without hitting a block in between),
	-- pick out the block to delete now so it can blink
	if gameState.cheat and remaining > 0 then -- Second clause might be unnecessary
		local cheatSelect = lovr.math.random(remaining) -- We will count up the blocks until we reach this number, then stop
		for x=1,bWidth do -- Iterate over the board space
			if gameState.cheat.x then break end -- Already found a block to delete
			for y=1,bHeight do
				if Board.get(board,x,y) then
					cheatSelect = cheatSelect - 1
					if cheatSelect == 0 then -- Found our target block
						gameState.cheat.x, gameState.cheat.y, gameState.cheat.start = x,y,tim -- Save current time so blink can key off it
						break
					end
				end
			end
		end
	else
		-- Whenever we hit the paddle we "arm" the cheat.
		if not gameState.cheat then gameState.cheat = {} end -- The cheat state is stored in gameState so it gets cleared on death/level clear
	end
end
local function cheatDisarm() -- Whenever we hit a block we delete the table that constitutes "arming"
	gameState.cheat = nil
end

function lovr.update(dt)
	tim = tim + dt

	-- Use the highest-numbered hand, which is probably the right hand.
	local controllerNames = lovr.headset.getHands()
	local controller = controllerNames[#controllerNames]
	if #controllerNames then -- Turn roll of selected controller into a paddle position 0..1
		local q = lovr.math.quat( lovr.headset.getOrientation(controller) ):normalize()
		paddleAt = (q.z + 1)/2
	end

	-- If a death sequence has finished and the game should reset, handle that at the start of the frame.
	if gameState[1] == "dead" and tim - gameState.start > gameStateDeathRollover.reset then
		gameReset()
		boardReset()
		ballAt:set(vec2(-2 + tim%4, 1)) -- On reset randomize the ball position a little
		if ballAt.x < 0 then ballVel.x = -ballVel.x end -- Set starting velocity away from center
	end

	if gameState[1] ~= "dead" then -- Not dead. Normal game logic
		local ballMargin = ballWidth/2 -- A few last minute constants
		local borderWidth = bWidth/2
		local borderHeight = bHeight + bDistanceAway + bBackBuffer
		local paddleMargin = pHeight/2
		local startAbovePaddle = ballAt.y - ballMargin > paddleMargin -- At the start of the frame, was the ball above the paddle?

		-- The ball has crossed over a line it can't cross. Reverse its direction and apply its overshoot in the other direction
		local function bounce(key, dir, limit)
			local at = ballAt[key]
			local cVal = at + dir * ballMargin
			local cAgainst = limit
			ballVel[key] = ballVel[key] * -1
			ballAt[key] = at + (cAgainst - cVal) * 2
			-- Whenever the ball bounces off something, play a sound-- EXCEPT,
			-- In the time between the last block of a level clears and the ball next hits the paddle, we mute
			if gameState[1] ~= "win" then nextSound(ballXyz(ballAt)) end
		end

		-- Move up/down
		ballAt.y = ballAt.y + ballVel.y * dt
		local cellX, cellY = bCornerGridReverse(ballAt.x, ballAt.y + tie(ballVel.y)*ballMargin)
		if Board.get(board, cellX, cellY) then -- Vertically collide with block
			Board.set(board, cellX, cellY, false)
			score()
			cheatDisarm()
			bounce('y', tie(ballVel.y), ({bCornerGrid(cellX, cellY)})[2] + (ballVel.y > 0 and 0 or 1))
		end

		-- Move left/right
		ballAt.x = ballAt.x + ballVel.x * dt
		cellX, cellY = bCornerGridReverse(ballAt.x + tie(ballVel.x)*ballMargin, ballAt.y)
		if Board.get(board, cellX, cellY) then -- Horizontally collide with block
			Board.set(board, cellX, cellY, false)
			score()
			cheatDisarm()
			bounce('x', tie(ballVel.x), bCornerGrid(cellX, cellY) + (ballVel.x > 0 and -1 or 0))
		end

		-- Side barrier check
		if ballAt.x >=   borderWidth - ballMargin  then
			bounce('x',  1,  borderWidth)
		end
		if ballAt.x <= -(borderWidth - ballMargin) then
			bounce('x', -1, -borderWidth)
		end
		
		-- Top barrier check
		if ballAt.y >= borderHeight - ballMargin then
			cheatBackWall()
			bounce('y', 1, borderHeight)
		end

		if gameState[1] == "win" then -- In the second after collecing the last block of a level, play four quick "victory" notes
			local shouldStrum = 1 + math.floor((tim - gameState.start)/soundsWinStrumSpeed)
			if shouldStrum > gameState.strumAt then
				gameState.strumAt = gameState.strumAt+1
				local whichStrum = soundsWinStrum[gameState.strumAt]
				if whichStrum then nextSound(ballXyz(ballAt), sounds[whichStrum]) end
			end
		end

		local endAbovePaddle = ballAt.y - ballMargin > paddleMargin -- Now that we're at the end of the frame, is the ball above the paddle?

		-- Did the ball move from below the paddle to above the paddle during this frame?
		if startAbovePaddle and not endAbovePaddle then
			if math.abs(pGrid(paddleAt) - ballAt.x) < (pWidth/2+paddleMargin) then -- Ball hit paddle
				if gameState[1] == "win" then -- On first paddle hit after clearing a board, load the new board
					gameState = {}
					boardReset()
					gameLevel = gameLevel + 1
					if gameLevel < 11 then
						ballVel:set(ballVel * 1.15) -- Speed up
					end
					pendingSound = 1
				else
					cheatPaddle()
				end

				bounce('y', -1, paddleMargin)
			end
		end

		-- Build out LED "screen". The screen always contains at least two digits and is least significant digit first
		local i, tempPoints = 1,points
		while i < 3 or tempPoints > 0 do -- Slice one digit off the points at a time
			screen[i] = tempPoints % 10
			tempPoints = math.floor(tempPoints/10)
			i = i + 1
		end

		if ballAt.y <= bKill + ballMargin then -- Ball has hit kill plane
			if DEBUG_backBumper then -- IMMORTALITY!!
				bounce('y', -1, bKill)
			else
				gameState = {"dead", start=tim}
				nextSound(ballXyz(ballAt), sounds.fail)

				screen = {11, 10} -- Special characters : (
			end
		end
	else -- Death sequence logic
		if not gameState.substate then -- After death, do nothing at all and show the :(
			if tim - gameState.start > gameStateDeathRollover.silence then
				gameState.substate = "silence"
				screen = {} -- Clear all digits to nil
			end
		elseif gameState.substate == "silence" then -- Then do nothing for a bit
			if tim - gameState.start > gameStateDeathRollover.tone then
				gameState.substate = "tone"
				nextSound(ballXyz(vec2(0,0)), sounds.restart)
			end
		end -- Then let the tone play out until "reset"
	end

	lovr.audio.setPose(lovr.headset.getPose())
end

local function drawLed(root, character) -- Draw one digit of the LED screen
	if not character then return end
	for y=1,led.height do
		local line = root
		for x=1,led.width do
			line = line + lRight
			if character[x][y] then
				ledCube(line)
			end
		end
		root = root + lDown
	end
end

function lovr.draw()
	lovr.graphics.clear()
	
	if fixedCamera then
		lovr.graphics.translate(0, 0, -2) -- Move backward so Go users can see the paddle
	end

	-- This bit draws a three-dimensional grid, but it contains an intentional bug.
	-- The bug results in an interesting and attractive abstract environment!
	local gs = 30
	local far = 1*gs
	local grid = 2*gs
	for x=-grid,grid,gs do for y=-grid,grid,gs do for z=-grid,grid,gs do
		lovr.graphics.line(-far, y, z, far, y, z)
		if not (fixedCamera and x == 0 and z == 0) then -- In fixed camera setup this center line looks weird
			lovr.graphics.line(x, -far, z, x, far, z)
		end
		lovr.graphics.line(x, y, far, x, y, -far)
	end end end

	-- Draw board
	lovr.graphics.setShader(shader)
	local cheatX, cheatY, cheatStart
	if gameState.cheat then -- Unpack cheat state
		cheatX, cheatY, cheatStart = gameState.cheat.x, gameState.cheat.y, gameState.cheat.start
	end
	for x=1,bWidth do for y=1,bHeight do
		if Board.get(board,x,y) then
			if x == cheatX and y == cheatY and (tim - gameState.cheat.start) % 0.5 > 0.25 then -- Blinking cube during cheat
				lovr.graphics.setColor(1,1,1,1)
			else -- Base color on position so there's a nice gradient
				lovr.graphics.setColor(x/bWidth, y/bHeight, 1, 1)
			end
			cube(bCenter(x,y))
		end
	end end
	lovr.graphics.setColor(1, 1, 1, 1)
	-- Draw paddle and board
	paddle(paddleAt)
	if gameState[1] ~= "dead" then ball(ballAt) end
	-- Draw screen
	local screenlen = #screen
	local lUlCorner = lovr.math.vec3( lUlRoot - lDown*led.height - lRight * (screenlen * (led.width + 1) + 2)/ 2 )
	for i=screenlen,1, -1 do
		drawLed(lUlCorner, led[screen[i]+1])
		if i ~= 1 then lUlCorner = lUlCorner + lRight * (led.width + 1) end
	end
	-- Draw controller
	if controller then
		if controllerModel == nil then controllerModel = controller:newModel() or false end -- Only try to load controller once
		if controllerModel then
			local x, y, z, angle, ax, ay, az = lovr.headset.getPose(controller)
			controllerModel:draw(x,y,z,1,angle,ax, ay, az)
		end
	end
end
