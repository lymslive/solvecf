-- �Ѷȷ���
-- ����ȷ�����貽������ԭ����п��ܴ��ڵ������Ŀ��ȡ��������Ϊ�Ѷ�ָ��
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

    -- ���ɶȣ��ɵ��������
    line.free = line.row * line.col - line.hole
    -- �Ż������貽��
    line.step = #solved[i]
    -- ���Ӷȣ����������ɸ�������ѡ�����貽���ĸ��ӣ��м������
    line.complex = combine(line.free, line.step)
    -- �����أ��Ѷ�ָ��
    line.hardess = math.log(line.complex)

    table.insert(result, line)
end

local head = {"level", "row", "col",  "hole", "free", "step", "complex", "hardess"}

local function savecsv(file, tab, head)
    io.output(file .. ".csv")

    if head then
	-- �б�ͷ������ tab �����ÿ��Ԫ�غ�����ͬ���ֶ�
	io.write(table.concat(head, ",") .. "\n")
	for _, line in ipairs(tab) do
	    local buf = {}
	    for _, field in ipairs(head) do
		table.insert(buf, line[field])
	    end
	    io.write(table.concat(buf, ",") .."\n")
	end
    else
	-- û�б�ͷ������ tab ���Ǿ���ṹ
	for _, line in ipairs(tab) do
	    io.write(table.concat(line, ",") .."\n")
	end
    end
    io.close()
end

local file = "hardanaly"
savecsv(file, result, head)
