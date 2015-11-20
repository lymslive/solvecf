local levelData = require("stdLevels")
local ChessBoard = require("ChessBoard")

local level = tonumber(arg[1]) or 1
printf("level %d:", level)
levelData:view(level)

local lb = ChessBoard.new(levelData[level])

print("size:", lb.rows_, lb.cols_)
print("State Number:", lb:convertNumber(lb.grid_))

-- local walk = lb:solve()
local tic = os.time()
local walk = lb:solve2()
print("solved time:", os.time()-tic)

print("solve it:", type(walk), walk)
if type(walk) == "table" then
    lb:viewPath(walk)
end
