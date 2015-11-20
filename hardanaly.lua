-- 难度分析
-- 以正确解所需步数，在原棋局中可能存在的组合数目（取对数）作为难度指标
local levelData = require("stdLevels")
local solved = require("solved")
local ChessBoard = require("ChessBoard")

require("combine")

local result = {}
for i, data in ipairs(levelData) do
    local line = {}
    local board = ChessBoard.new(data)

    line.level = i
    line.row = data.rows
    line.col = data.cols
    line.hole = #board.hole_

    -- 自由度，可点击格子数
    line.free = line.row * line.col - line.hole
    -- 优化解所需步数
    line.step = #solved[i]
    -- 复杂度，从所有自由格子数中选出所需步数的格子，有几种情况
    line.complex = combine(line.free, line.step)
    -- 对数熵，难度指数
    line.hardess = math.log(line.complex)

    table.insert(result, line)
end

local head = {"level", "row", "col",  "hole", "free", "step", "complex", "hardess"}

local function savecsv(file, tab, head)
    io.output(file .. ".csv")

    if head then
	-- 有表头，假设 tab 数组的每个元素含有相同的字段
	io.write(table.concat(head, ",") .. "\n")
	for _, line in ipairs(tab) do
	    local buf = {}
	    for _, field in ipairs(head) do
		table.insert(buf, line[field])
	    end
	    io.write(table.concat(buf, ",") .."\n")
	end
    else
	-- 没有表头，假设 tab 就是矩阵结构
	for _, line in ipairs(tab) do
	    io.write(table.concat(line, ",") .."\n")
	end
    end
    io.close()
end

local file = "hardanaly"
savecsv(file, result, head)
