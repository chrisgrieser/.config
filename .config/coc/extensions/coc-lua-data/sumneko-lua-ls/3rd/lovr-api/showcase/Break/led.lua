-- Constructs a set of 2D arrays containing some simple block numbers

local blob = [[

000
0 0
0 0
0 0
000

  0
  0
  0
  0
  0

000
  0
000
0
000

000
  0
000
  0
000

0 0
0 0
000
  0
  0

000
0
000
  0
000

000
0
000
0 0
000

000
  0
 0
 0
 0

000
0 0
000
0 0
000

000
0 0
000
  0
000


 0

 0


 0
0 
0 
0 
 0
]]

local Board = require 'board'
local led = {width = 3, height = 5} -- Array part will be an array of Boards
local current = nil    -- Board currently adding pixels to
local scanning = false -- False when looking for a blank separator line
local x, y
for c in blob:gmatch"." do -- Convert the above string to Boards
	if c == "\n" then -- On newline
		if scanning then -- We are already building a Board
			x = 1
			y = y + 1
			if y > led.height then -- Board is full, push Board to "led" and start over
				scanning = false
				table.insert(led, current)
				current = nil
			end
		else          -- We haven't started a board yet, this is the blank line between Boards
			scanning = true
			x, y = 1,1
			current = Board.fill({}, led.width, led.height, false)
		end
	else -- On character
		if scanning then
			if c == "0" then -- 0 is true anything else stays false.
				current[x][y] = true
			end
			x = x + 1
		end
	end
end
return led
