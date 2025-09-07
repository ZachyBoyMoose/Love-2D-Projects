local Enemy = require('enemies/enemy')
local HarvesterGolem = setmetatable({}, Enemy)
HarvesterGolem.__index = HarvesterGolem

function HarvesterGolem.new(x, y)
    local self = setmetatable(Enemy.new(x, y, 35, 35, {0.4, 0.3, 0.2}), HarvesterGolem)
    self.hp = 150
    self.maxHp = 150
    self.attackPower = 15
    self.speed = 25
    return self
end

return HarvesterGolem