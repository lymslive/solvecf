local levelData = require("stdLevels")
local ChessBoard = require("ChessBoard")

local starLevel = tonumber(arg[1]) or 1
local stopLevel = tonumber(arg[2]) or 100

local fid = io.open("solved.lua",  "a+")
for level = starLevel, stopLevel do
    print("\nLevel:", level)
    local lb = ChessBoard.new(levelData[level])
    -- local walk = lb:solve()

    local tic = os.time()
    local walk = lb:solve2()
    print("solved time:", os.time()-tic)

    if walk then
	local str = string.format("solved[%d]={\n", level)
	-- for i = 1, #walk do
	for i = #walk, 1, -1 do
	    str = str .. string.format("\t{row=%d, col=%d},\n", walk[i].row, walk[i].col)
	end
	str = str .. "}\n"
	fid:write(str)
    end

end

fid:close()
--  直接穷举 5*5 棋盘，经常失败，内存不足
--  改用组合迭代器解决
