-- 计算组合数 C(n,k)
-- http://blog.csdn.net/justmeh/article/details/5799708
function combine(n, k)
    local result = {}
    -- result[0] = 1
    for i = 1, n do
	result[i] = 1
	for j = i-1, 1, -1 do
	    result[j] = result[j-1] + result[j]
	end
	result[0] = 1
    end
    return result[k], result
end

if not arg then
    return
end

-- [[ main
-- sum(C(n,k), k=1,n) = 2^n -1
-- sum(C(n,k), k=0,n) = 2^n
local n = tonumber(arg[1])
local k = tonumber(arg[2])
if n and k then
    print(n, k)

    local cnk, list = combine(n,k)
    print("C(n,k)=", cnk)

    local all = 0
    for k = 1, n do
	-- all = all + list[k]
	print("k, cnk:", k, list[k])
    end

    -- print("sum(cnk)=", all)
end
--]]
