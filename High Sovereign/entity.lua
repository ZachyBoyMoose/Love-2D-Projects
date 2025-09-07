local Entity = {}
Entity.__index = Entity

function Entity.new(x, y, width, height)
    local self = setmetatable({}, Entity)
    self.x = x
    self.y = y
    self.width = width
    self.height = height
    self.hp = 100
    self.maxHp = 100
    self.isAlive = true
    self.speed = 50
    self.target = nil
    return self
end

function Entity:update(dt)
    -- To be implemented by subclasses
end

function Entity:draw()
    -- To be implemented by subclasses
end

function Entity:takeDamage(amount)
    self.hp = self.hp - amount
    if self.hp <= 0 then
        self.hp = 0
        self.isAlive = false
    end
end

function Entity:heal(amount)
    self.hp = math.min(self.hp + amount, self.maxHp)
end

function Entity:distanceTo(other)
    return math.sqrt((self.x - other.x)^2 + (self.y - other.y)^2)
end

function Entity:moveTowards(targetX, targetY, dt)
    local dx = targetX - self.x
    local dy = targetY - self.y
    local distance = math.sqrt(dx*dx + dy*dy)
    
    if distance > 5 then
        self.x = self.x + (dx / distance) * self.speed * dt
        self.y = self.y + (dy / distance) * self.speed * dt
        return false -- Not yet reached
    else
        return true -- Reached target
    end
end

return Entity