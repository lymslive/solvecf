-- 棋局分析类

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

    -- 用一个 1*2 二元数组 的列表表示空洞位置，下标是[行][列]
    self.hole_ = {}
    self.hole_ = self:getHole()
    self.Bits_ = self.rows_ * self.cols_ -- #self.hole
end

-- 将某个棋形矩阵转为一个特征数字
-- 每格的正反面视为二进制编码数字
-- 忽视空洞
-- 先遍历的 {row=1, col=1} 视为高位
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

-- 逆运算，从特征数值生成矩阵
-- 返回矩阵与二进制串
function ChessBoard:convertGrid(number)
    local bit = {}

    -- 初生成的 bit 是从低位往高位排列
    while number > 0 do
	local mod = math.fmod(number, 2)
	table.insert(bit, mod)
	number = math.floor(number/2)
    end

    -- 高位补足0
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

-- 从坐标 (row, col) 转为单索引
-- 遍历先行后列
function ChessBoard:convertIndex(position)
    local index = (position.row - 1) * self.cols_ + position.col
    return index
end

-- 从单索引转化为 (row, col) 坐标
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

-- 翻转操作，相当于矩阵元素乘法，转换矩阵只在翻转格子处为-1，其余为1
-- 返回一个新矩阵
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

-- 创建转移矩阵
-- 输入参数为中心点坐标，及形状定义，默认是十字形
-- postion 是{row=, col=}结构的表
-- shape 的每个点是1*2纯数组，[1] 对应 row, [2] 对应col
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

-- 判断一个位置是否空洞
function ChessBoard:isHole(row, col)
    for i = 1,  #self.hole_ do
	local pos = self.hole_[i]
	if pos[1] == row and pos[2] == col then
	    return true
	end
    end
    return false
end

-- 判断一个位置是否可翻转
function ChessBoard:isFlipable(row, col)
    if row > self.rows_ or col > self.cols_ 
	or row < 1 or col < 1
	or self:isHole(row, col) then
	return false
    end
    return true
end

-- 生成一个全为1的矩阵
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

-- 获得空洞坐标列表
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

-- 从一个状态节点生成子树
-- state: 状态节点
--   .number: 表示矩阵的特征值
--   .parent: 父结点
--   .path: 父结点通过什么方式转换至此，用单索引数字表示翻转的位置
-- subMore: 收集生成的子结点的列表
-- htree: 已经遍历的状态，保存在一个 hash 表中
-- endNumber: 如果达到某个状态（特征值）则终止生成
-- 返回所有子状态，及更新后的 htree
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

-- 寻找一个矩阵布局的解法
-- 返回一个位置坐标列表（含row,col字段），无解返回false
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

    -- 构建根状态，全正面朝向
    local rootGrid = self:ones()
    local rootState = {}
    rootState.number = self:convertNumber(rootGrid)
    rootState.path = 0
    rootState.parent = nil

    local deep = 0
    local nstate = 0
    local maxState = math.pow(2, self.Bits_)

    -- 模拟翻面，向下搜索子结点
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

    -- 如果找到某个子结点状态与当前状态相同，则回溯构建解法路径
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

-- 采用组合的算法
local combs
function ChessBoard:solve2(grid)
    if not grid then
	grid = self.grid_
    end

    -- 可选位置列表
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

    -- 不同层，选几个点
    local npos = #validpos
    local done = false
    local combFound
    for deep = 1, npos do
	-- 一定步数下所有组合情况
	-- local flipcombs = combs(npos, deep)
	-- print("deep and flipcombs Count:", deep, #flipcombs)

	-- 处理某种组合，从根结点连续翻牌
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

    -- 转换为实际位置坐标点位置返回
    local path = {}
    for j, tr in ipairs(combFound) do
	table.insert(path, validpos[tr])
    end
    return path
end

-- 寻找所有组合数，从 n 个元素中选出 k 个的组合情况
function combs(n, k)
    local result = {}
    local cm = {}
    local finish = false

    for i = 1, k do
	cm[i] = i
    end

    table.insert(result, clone(cm))

    while not finish do

	-- 自后向前寻找第一个不够大的数下标
	local j = k
	while(cm[j] >= n-k+j) do
	    j = j-1
	end

	-- 从寻到的下标开始，后面的元素递增1
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

-- 判断两个矩阵是否相等
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

-- [[调试用函数
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
