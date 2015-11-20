local _r = require("functions")
local oldLevels = require("Levels")

local stdLevels = {}

for i = 1 , 100 do
    local data = oldLevels.get(i)
    for row = 1 , data.rows do
	for col = 1 , data.cols do
	    if data.grid[row][col] == 0 then
		data.grid[row][col] = -1
	    elseif data.grid[row][col] == "X" then
		data.grid[row][col] = 0
	    end
	end
    end
    stdLevels[i] = data
end

function stdLevels:view(lv)
    local data = self[lv]

    for row = 1 , data.rows do
	print(table.concat(data.grid[row], "\t"))
    end
end

return stdLevels
