local Building = require('buildings/building')
local Dispensary = setmetatable({}, Building)
Dispensary.__index = Dispensary

function Dispensary.new(x, y)
    local self = setmetatable(Building.new(x, y, 35, 35, {1, 0.5, 0}, "dispensary"), Dispensary)
    return self
end

return {
    new = Dispensary.new
}