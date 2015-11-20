-- ������ĵ�����ʵ��

function combit(nTotal, kSelect)
    local n = nTotal
    local k = kSelect
    assert(type(n) == "number", "combit: n expected a number")
    assert(type(k) == "number", "combit: k expected a number")
    assert(n >= k and n >=0 and k >= 0, "combit: expected positive int n>k")

    local cm = {}
    local finish = false
    local count = 0

    return function()

	-- if finish then return nil end
	count = count + 1

	if count == 1 then
	    for i = 1, k do
		cm[i] = i
	    end
	    return cm
	end

	if cm[1] == nil or cm[1] == n - k + 1 then
	    finish = true
	    return nil
	end

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

	return cm
    end, nTotal, count
end
