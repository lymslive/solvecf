require("combit")

local n = tonumber(arg[1])
local k = tonumber(arg[2])

local tic = os.time()
for k = 1, n do
    for comb in combit(n, k) do
	print(table.concat(comb, " "))
    end
end
print("elapse time:", os.time()-tic)
