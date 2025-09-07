local Enemy = require('enemies/enemy')
local BuzzkillBeetle = setmetatable({}, Enemy)
BuzzkillBeetle.__index = BuzzkillBeetle

function BuzzkillBeetle.new(x, y)
    local self = setmetatable(Enemy.new(x, y, 15, 15, {0, 0, 0}), BuzzkillBeetle)
    self.hp = 30
    self.maxHp = 30
    self.attackPower = 5
    self.speed = 70
    return self
end

return BuzzkillBeetle