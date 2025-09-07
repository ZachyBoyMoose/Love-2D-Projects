-- heroes/gnome_chomper.lua - Dwarf class implementation
local Hero = require('heroes/hero')
local GnomeChomper = setmetatable({}, Hero)
GnomeChomper.__index = GnomeChomper

function GnomeChomper.new(x, y)
    local self = setmetatable(Hero.new(x, y, 20, 14, {0.4, 0.3, 0.2}, "gnome_chomper"), GnomeChomper)
    self.attackPower = 18
    self.defense = 12
    self.speed = 30 -- Slow movement
    self.magicResistance = 0.5 -- Base 50% magic resistance
    self.magicResistanceBoost = false
    
    -- Dwarves are brave and greedy
    self.personality.bravery = math.min(1.0, self.personality.bravery + 0.3)
    self.personality.greed = math.min(1.0, self.personality.greed + 0.2)
    
    return self
end

function GnomeChomper:update(dt)
    Hero.update(self, dt)
    
    -- Reset magic resistance boost
    if self.magicResistanceBoost and self.abilityCooldown <= 15 then
        self.magicResistance = 0.5
        self.magicResistanceBoost = false
    end
    
    -- Prioritize magical enemies and lairs
    if self.state == "idle" or self.state == "wandering" then
        self:findMagicalTarget()
    end
end

function GnomeChomper:findMagicalTarget()
    -- Look for magical enemies or lairs
    local bestTarget = nil
    local minDist = 300
    
    -- Check lairs first (priority)
    for _, building in ipairs(require('game').getBuildings()) do
        if building.type == "lair" and building.isAlive then
            local dist = self:distanceTo(building)
            if dist < minDist then
                minDist = dist
                bestTarget = building
            end
        end
    end
    
    if bestTarget then
        self.combatTarget = bestTarget
        self.state = "fighting"
    end
end

function GnomeChomper:takeDamage(amount, attacker)
    -- Check if damage is magical
    local isMagical = attacker and (attacker.type == "psilocyber_stoner" or attacker.attackType == "magic")
    
    if isMagical then
        amount = amount * (1 - self.magicResistance)
        
        -- Activate magic resistance boost when taking magic damage
        if self.abilityCooldown <= 0 then
            self.magicResistance = 0.9 -- 90% resistance
            self.magicResistanceBoost = true
            self.abilityCooldown = 25
            
            -- Visual effect
            table.insert(require('game').floatingTexts, {
                x = self.x,
                y = self.y - 20,
                text = "MAGIC RESIST!",
                color = {0.4, 0.3, 0.2},
                lifetime = 2,
                velocity = {0, -20}
            })
        end
    end
    
    Hero.takeDamage(self, amount)
end

function GnomeChomper:draw()
    -- Short, wide brown rectangle
    love.graphics.setColor(self.color[1], self.color[2], self.color[3])
    love.graphics.rectangle("fill", self.x - self.width/2, self.y - self.height/2, self.width, self.height)
    
    -- Draw magic resistance indicator
    if self.magicResistanceBoost then
        love.graphics.setColor(0.8, 0.6, 0.4, 0.5)
        love.graphics.rectangle("line", self.x - self.width/2 - 2, self.y - self.height/2 - 2, self.width + 4, self.height + 4)
    end
    
    Hero.draw(self)
end

return GnomeChomper