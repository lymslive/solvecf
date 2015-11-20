-- Ѱ��������������� n ��Ԫ����ѡ�� k ����������
local copy
function combs(n, k)
    local result = {}
    local cm = {}
    local finish = false

    for i = 1, k do
	cm[i] = i
    end

    table.insert(result, copy(cm))

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

	table.insert(result, copy(cm))

	if cm[1] == n - k + 1 then
	    finish = true
	end
    end

    return result
end

function copy(tab)
    local cp = {}
    for i = 1, #tab do
	cp[i] = tab[i]
    end
    return cp
end


--[[ main
local n = tonumber(arg[1])
local k = tonumber(arg[2])
local result = combs(n, k)
print("combines:", #result)
for i = 1, #result do
    print(table.concat(result[i], "\t"))
end
--]]
