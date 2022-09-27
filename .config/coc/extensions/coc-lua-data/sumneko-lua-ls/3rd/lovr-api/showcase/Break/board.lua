-- A minimal 2D array helper class

local Board = {}

function Board.fill(board, w, h, v) -- Can initialize or grow (but not shrink) board
	for x=1,w do
		local col = board[x]
		if not col then
			col = {}
			board[x] = col
		end
		for y=1,h do
			col[y] = v
		end
	end
	return board
end

function Board.size(board) -- Return width, height
	if not board then return 0,0 end
	return #board, board[1] and #board[1] or 0
end

function Board.get(board, x, y)
	local col = board[x]
	if col then
		return col[y]
	end
	return nil
end

function Board.set(board, x, y, v)
	local xs, ys = Board.size(board)
	if x >= 1 and y >= 1 and x <= xs and y <= ys then
		board[x][y] = v
	end
end

return Board
