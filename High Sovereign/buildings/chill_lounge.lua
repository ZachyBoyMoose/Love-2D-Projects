local Building = require('buildings/building')
local ChillLounge = setmetatable({}, Building)
ChillLounge.__index = ChillLounge

function ChillLounge.new(x, y)
    local self = setmetatable(Building.new(x, y, 40, 40, {0, 0.5, 1}, "chill_lounge"), ChillLounge)
    return self
end

return {
    new = ChillLounge.new
}