-- ��ַ�����

require("combit")
local _r = require("functions")
local ChessBoard = class("ChessBoard")

ChessBoard.WHITE = 1
ChessBoard.BLACK = -1
ChessBoard.HOLE = 0

ChessBoard.CROSS = {{0,0}, {0,1}, {1,0}, {0,-1}, {-1,0}}

function ChessBoard:ctor(data)
    self.rows_ = data.rows
    self.cols_ = data.cols
    self.grid_ = data.grid

    -- ��һ�� 1*2 ��Ԫ���� ���б��ʾ�ն�λ�ã��±���[��][��]
    self.hole_ = {}
    self.hole_ = self:getHole()
    self.Bits_ = self.rows_ * self.cols_ -- #self.hole
end

-- ��ĳ�����ξ���תΪһ����������
-- ÿ�����������Ϊ�����Ʊ�������
-- ���ӿն�
-- �ȱ����� {row=1, col=1} ��Ϊ��λ
function ChessBoard:convertNumber(grid)
    local number = 0
    for row = 1,  self.rows_ do
	for col = 1,  self.cols_ do
	    local coin = grid[row][col]
	    if not self:isHole(row, col) then
		local bit = 0
		if coin == ChessBoard.WHITE then
		    bit = 1
		end
		number = 2 * number + bit
	    end
	end
    end
    return number
end

-- �����㣬��������ֵ���ɾ���
-- ���ؾ���������ƴ�
function ChessBoard:convertGrid(number)
    local bit = {}

    -- �����ɵ� bit �Ǵӵ�λ����λ����
    while number > 0 do
	local mod = math.fmod(number, 2)
	table.insert(bit, mod)
	number = math.floor(number/2)
    end

    -- ��λ����0
    local len = #bit
    for i = len+1, self.Bits_ do
	table.insert(bit, 0)
    end

    local grid = {}
    local ind = #bit
    for row = 1,  self.rows_ do
	grid[row] = {}
	for col = 1,  self.cols_ do
	    if self:isHole(row, col) then
		grid[row][col] = ChessBoard.HOLE
	    else
		local coin = bit[ind]
		if coin == 1 then
		    grid[row][col] = ChessBoard.WHITE
		elseif coin == 0 then
		    grid[row][col] = ChessBoard.BLACK
		else
		    assert("Error Found: expect a bit number 1/0")
		end
		ind = ind - 1
	    end
	end
    end

    return grid, table.concat(bit)
end

-- ������ (row, col) תΪ������
-- �������к���
function ChessBoard:convertIndex(position)
    local index = (position.row - 1) * self.cols_ + position.col
    return index
end

-- �ӵ�����ת��Ϊ (row, col) ����
function ChessBoard:convertPosition(index)
    local position = {}
    if index > 0 then
	position.row = math.ceil(index / self.cols_)
	position.col = math.fmod(index, self.cols_)
	if position.col == 0 then
	    position.col = self.cols_
	end
    end
    return position
end

-- ��ת�������൱�ھ���Ԫ�س˷���ת������ֻ�ڷ�ת���Ӵ�Ϊ-1������Ϊ1
-- ����һ���¾���
function ChessBoard:flipGrid(grid, trans)
    local fgrid = {}
    for row = 1,  self.rows_ do
	fgrid[row] = {}
	for col = 1,  self.cols_ do
	    fgrid[row][col] = grid[row][col] * trans[row][col]
	end
    end
    return fgrid
end

-- ����ת�ƾ���
-- �������Ϊ���ĵ����꣬����״���壬Ĭ����ʮ����
-- postion ��{row=, col=}�ṹ�ı�
-- shape ��ÿ������1*2�����飬[1] ��Ӧ row, [2] ��Ӧcol
function ChessBoard:makeTrans(position, shape)
    if not shape then
	shape = ChessBoard.CROSS
    end

    ---print("position:", position.row, position.col)

    local grid = self:ones()
    for i = 1,  #shape do
	local pos = shape[i]
	---printf("shape[%d] pos:{%d,%d}", i, pos[1], pos[2])
	local row = pos[1] + position.row
	local col = pos[2] + position.col
	---printf("row=%d, col=%d", row, col)
	if self:isFlipable(row, col) then
	    grid[row][col] = -1
	end
    end

    return grid
end

-- �ж�һ��λ���Ƿ�ն�
function ChessBoard:isHole(row, col)
    for i = 1,  #self.hole_ do
	local pos = self.hole_[i]
	if pos[1] == row and pos[2] == col then
	    return true
	end
    end
    return false
end

-- �ж�һ��λ���Ƿ�ɷ�ת
function ChessBoard:isFlipable(row, col)
    if row > self.rows_ or col > self.cols_ 
	or row < 1 or col < 1
	or self:isHole(row, col) then
	return false
    end
    return true
end

-- ����һ��ȫΪ1�ľ���
function ChessBoard:ones()
    local grid = {}
    for row = 1,  self.rows_ do
	grid[row] = {}
	for col = 1,  self.cols_ do
	    grid[row][col] = 1
	end
    end
    return grid
end

-- ��ÿն������б�
function ChessBoard:getHole()
    local hole = {}
    for row = 1,  self.rows_ do
	for col = 1,  self.cols_ do
	    if self.grid_[row][col] == ChessBoard.HOLE then
		table.insert(hole, {row, col})
	    end
	end
    end
    return hole
end

-- ��һ��״̬�ڵ���������
-- state: ״̬�ڵ�
--   .number: ��ʾ���������ֵ
--   .parent: �����
--   .path: �����ͨ��ʲô��ʽת�����ˣ��õ��������ֱ�ʾ��ת��λ��
-- subMore: �ռ����ɵ��ӽ����б�
-- htree: �Ѿ�������״̬��������һ�� hash ����
-- endNumber: ����ﵽĳ��״̬������ֵ������ֹ����
-- ����������״̬�������º�� htree
function ChessBoard:growDown(state, subMore, htree, endNumber)
    -- local subMore = {}

    local grid = self:convertGrid(state.number)

    -- for i = 1,  self.Bits_ do
    for i = state.path + 1,  self.Bits_ do
	local position = self:convertPosition(i)
	if self:isFlipable(position.row, position.col) then
	    local subGrid = self:flipGrid(grid, self:makeTrans(position))
	    local subState = {}
	    subState.number = self:convertNumber(subGrid)

	    if not htree[subState.number] then
		subState.parent = state
		subState.path = i
		table.insert(subMore, subState)
		htree[subState.number] = subState
	    else
		-- print("State (%d) has arrived before", subState.number)
	    end

	    if endNumber and endNumber == subState.number then
		print("growDown(): find target state", endNumber)
		break
	    end
	end
    end

    return subMore, htree
end

-- Ѱ��һ�����󲼾ֵĽⷨ
-- ����һ��λ�������б���row,col�ֶΣ����޽ⷵ��false
function ChessBoard:solve(grid)
    if not grid then
	grid = self.grid_
    end

    local endNumber = self:convertNumber(grid)
    local endState = nil
    local travelPath = {}

    print("solve() began")
    printf("Target State: number=%d", endNumber)
    self:viewGrid(grid)

    local htree = {}
    local subMore = {}

    -- ������״̬��ȫ���泯��
    local rootGrid = self:ones()
    local rootState = {}
    rootState.number = self:convertNumber(rootGrid)
    rootState.path = 0
    rootState.parent = nil

    local deep = 0
    local nstate = 0
    local maxState = math.pow(2, self.Bits_)

    -- ģ�ⷭ�棬���������ӽ��
    self:growDown(rootState, subMore, htree, endNumber)
    while #subMore > 0 do
	deep = deep + 1
	nstate = nstate + #subMore
	printf("solve() Walk down: deep=%d, states=%d", deep, nstate)

	if subMore[#subMore].number == endNumber then
	    endState = subMore[#subMore]
	    break
	elseif nstate >= maxState then
	    print("All possible states riched")
	    break
	end

	local subsubMore = {}
	for i = 1,  #subMore do
	    local state = subMore[i]
	    self:growDown(state, subsubMore, htree, endNumber)
	    if subsubMore[#subsubMore].number == endNumber then
		break
	    end
	end
	subMore = subsubMore
    end

    -- ����ҵ�ĳ���ӽ��״̬�뵱ǰ״̬��ͬ������ݹ����ⷨ·��
    if endState then
	local state = endState
	while state.parent do
	    table.insert(travelPath, self:convertPosition(state.path))
	    state = state.parent
	end
	print("solve() success")
	return travelPath
    else
	print("solve() fail")
	return false
    end
end

-- ������ϵ��㷨
local combs
function ChessBoard:solve2(grid)
    if not grid then
	grid = self.grid_
    end

    -- ��ѡλ���б�
    local validpos = {}
    local rootGrid = {}
    for row = 1, self.rows_ do
	rootGrid[row] = {}
	for col = 1, self.cols_ do
	    if not self:isHole(row, col) then
		local pos = {}
		pos.row = row
		pos.col = col
		table.insert(validpos, pos)
		rootGrid[row][col] = ChessBoard.WHITE
	    else
		rootGrid[row][col] = ChessBoard.HOLE
	    end
	end
    end

    -- ��ͬ�㣬ѡ������
    local npos = #validpos
    local done = false
    local combFound
    for deep = 1, npos do
	-- һ������������������
	-- local flipcombs = combs(npos, deep)
	-- print("deep and flipcombs Count:", deep, #flipcombs)

	-- ����ĳ����ϣ��Ӹ������������
	print("deep:", deep)
	for fcomb in combit(npos, deep) do
	    local testGrid = rootGrid
	    for j, tr in ipairs(fcomb) do
		local trpos = validpos[tr]
		local trgrid = self:makeTrans(trpos)
		testGrid = self:flipGrid(testGrid, trgrid)
	    end
	    if self:isSameGrid(testGrid, grid) then
		done = true
		combFound = fcomb
		break
	    end
	end

	if done then
	    break
	end
    end

    if not combFound then
	return false
    end

    -- ת��Ϊʵ��λ�������λ�÷���
    local path = {}
    for j, tr in ipairs(combFound) do
	table.insert(path, validpos[tr])
    end
    return path
end

-- Ѱ��������������� n ��Ԫ����ѡ�� k ����������
function combs(n, k)
    local result = {}
    local cm = {}
    local finish = false

    for i = 1, k do
	cm[i] = i
    end

    table.insert(result, clone(cm))

    while not finish do

	-- �Ժ���ǰѰ�ҵ�һ������������±�
	local j = k
	while(cm[j] >= n-k+j) do
	    j = j-1
	end

	-- ��Ѱ�����±꿪ʼ�������Ԫ�ص���1
	local cj = cm[j]
	for i = j, k do
	    cm[i] = cj + i-j + 1
	end

	table.insert(result, clone(cm))

	if cm[1] == n - k + 1 then
	    finish = true
	end
    end

    return result
end

-- �ж����������Ƿ����
function ChessBoard:isSameGrid(this, that)
    for row = 1, self.rows_ do
	for col = 1, self.cols_ do
	    if this[row][col] ~= that[row][col] then
		return false
	    end
	end
    end
    return true
end

-- [[�����ú���
function ChessBoard:viewPath(path)
    for i = 1, #path do
	printf("path[%d]: (row=%d, col=%d)", i, path[i].row, path[i].col)
    end
end

function ChessBoard:viewGrid(grid)
    for row = 1, self.rows_ do
	print(table.concat(grid[row], "\t"))
    end
end

function ChessBoard:viewCombs(combs)
    for i, cm in ipairs(combs) do
	print(table.concat(cm, " "))
    end
end
--]]

return ChessBoard
