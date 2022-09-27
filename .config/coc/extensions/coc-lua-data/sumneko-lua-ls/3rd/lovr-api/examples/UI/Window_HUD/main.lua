-- "Second screen experience" demo
-- Click grid on desktop screen to build a scene simultaneously visible in VR space
--
-- Sample contributed by andi mcc

local shader = require 'shader'

-- In order for lovr.mouse to work, and therefore for this example to work,
-- we must be using LuaJIT and we must be using GLFW (ie: we can't be on Oculus Mobile)
if type(jit) == 'table' and lovr.headset.getDriver() ~= "vrapi" then
	lovr.mouse = require 'mouse'
end

local mirror = lovr.mirror              -- Backup lovr.mirror before it is overwritten
local font = lovr.graphics.newFont(36)  -- Font appropriate for screen-space usage
font:setFlipEnabled(true)
font:setPixelDensity(1)

-- Simple 2D triangle mesh
local triangle = lovr.graphics.newMesh(
	{{0,-1,0, 0,0,1}, {0.75,1,0, 0,0,1}, {-0.75,1,0, 0,0,1}},
	'triangles', 'static'
	)

-- Constants
local pixwidth = lovr.graphics.getWidth()   -- Window pixel width and height
local pixheight = lovr.graphics.getHeight()
local aspect = pixwidth/pixheight           -- Window aspect ratio
local height = 2                            -- Window width and height in screen coordinates
local width = aspect*2                      -- ( We will pick the coordinate system [[-1,1],[-aspect,aspect]] )
local topmargin = 0.2                       -- Space between top of screen and top of grid
local cells = 7                             -- Number of cells in grid (per side)
local towerscalexz = 2                      -- How wide is one block in 3D space?
local towerscaley = 3                       -- How tall (maximum) is one block in 3D space?

-- Derived constants
local gridheight = (height-topmargin*2)             -- Height of grid
local gridspan = gridheight/2                       -- Half height of grid
local cellheight = gridheight/cells                 -- Height of one grid cell
local cellspan = cellheight/2                       -- Half height of one grid cell
local bannedcell = math.ceil(cells/2)               -- Do not allow clicks at this x,y coordinate
local fontscale = height/lovr.graphics.getHeight()  -- Scale argument to screen-space print() functions

-- Screen-space coordinate system
local matrix = lovr.math.newMat4():orthographic(-aspect, aspect, -1, 1, -64, 64)

-- State: We will store the blocks to draw as a 2D array of heights (nil for no block)
local grid = {}
for x=1,cells do grid[x] = {} end

function lovr.load()
	lovr.handlers['mousepressed'] = function(x,y)
		local inx = x * width / pixwidth - width/2    -- Convert pixel x,y to our coordinate system
		local iny = y * height / pixheight - height/2
		local gridorigin = -gridspan - cellheight     -- Upper left of grid ()
		local gx = (inx - gridorigin) / cellheight    -- Convert coordinate system to grid cells
		local gy = (iny - gridorigin) / cellheight
		local fx = math.floor(gx)
		local fy = math.floor(gy)
		if fx >= 1 and fy >= 1 and fx <= cells and fy <= cells   -- If the click was within the grid
		   and not (fx == bannedcell and fy == bannedcell) then  -- and was not the banned center cell
			if grid[fx][fy] then
				grid[fx][fy] = nil                -- toggle off
			else
				grid[fx][fy] = lovr.math.random() -- toggle on (random height)
			end
		end
	end
end

function drawGrid()
	-- Draw cell backgrounds (where present)
	for _x=1,cells do for _y=1,cells do
		local gray = grid[_x][_y]
		if gray then
			local x = -gridspan + _x * cellheight - cellspan -- Center of cell
			local y = -gridspan + _y * cellheight - cellspan

			lovr.graphics.setColor(gray,gray,gray,1)
			lovr.graphics.plane('fill', x, y, 0, cellheight, cellheight)
		end
	end end

	-- Draw grid lines
	lovr.graphics.setColor(1,1,1,1)
	for c=0,cells do
		local x = -gridspan + c * cellheight
		local y = -gridspan + c * cellheight
		lovr.graphics.line(-gridspan, y, 0, gridspan, y, 0)
		lovr.graphics.line(x, -gridspan, 0, x, gridspan, 0)
	end

	-- Draw a red triangle indicating the position and orientation of the headset player
	lovr.graphics.push()
	local x, y, z, angle, ax, ay, az = lovr.headset.getPose()
	-- Flatten the 3-space current rotation of the headset into just its xz axis
	-- Equation from: http://www.euclideanspace.com/maths/geometry/rotations/conversions/angleToEuler/index.htm
	local s = math.sin(angle)
	local c = math.cos(angle)
	local t = 1-c;
	local xzangle = math.atan2(ay*s - ax*az*t , 1 - (ay*ay + az*az) * t);
	lovr.graphics.setColor(1,0,0,1)
	lovr.graphics.translate(x / towerscalexz, z / towerscalexz, 0)
	lovr.graphics.scale(cellheight*0.5*0.75)
	lovr.graphics.rotate(-xzangle, 0, 0, 1)
	triangle:draw()
	lovr.graphics.pop()
end

-- Draw HUD overlay
function lovr.mirror()
	mirror()
	--lovr.graphics.clear() -- Uncomment to hide headset view in background of window
	lovr.graphics.setShader(nil)
	lovr.graphics.setDepthTest(nil)
	lovr.graphics.origin()
  lovr.graphics.setViewPose(1, mat4())
	lovr.graphics.setProjection(1, matrix) -- Switch to screen space coordinates
	drawGrid()

	-- Draw instructions
	lovr.graphics.setColor(1,1,1,1)
	lovr.graphics.setFont(font)
	lovr.graphics.print("Instructions: Click the grid to create or remove blocks.", 0, (gridheight+cellheight)/2, 0, fontscale)
end

-- Draw one block
function floorbox(_x,_y,gray)
	local x = -gridspan + _x * cellheight - cellspan
	local z = -gridspan + _y * cellheight - cellspan
	local height = gray * towerscaley
	lovr.graphics.box('fill', x*towerscalexz, height/2, z*towerscalexz, cellheight*towerscalexz, height, cellheight*towerscalexz)
end

-- Draw 3D scene
function lovr.draw()
	lovr.graphics.setDepthTest('lequal', true) -- mirror() will have disabled this
	lovr.graphics.setShader(shader)
	lovr.graphics.setColor(0,1,1)
	for x=1,cells do for y=1,cells do
		local gray = grid[x][y]
		if gray then floorbox(x,y,gray) end
	end end
	lovr.graphics.setShader()

	if not lovr.mouse then -- If you can't click, you can't create any blocks
		lovr.graphics.print('This example only works on a desktop computer.', 0, 1.7, -3, .2)
	end
end
