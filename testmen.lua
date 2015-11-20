require("combs")
for deep = 1, 25 do
    local flipcombs = combs(25, deep)
    for i, fcomb in ipairs(flipcombs) do
	print(table.concat(fcomb, " "))
    end
end

-- 结果：
-- 列举 C(25,10) 就出问题，
-- lua: not enough memory
