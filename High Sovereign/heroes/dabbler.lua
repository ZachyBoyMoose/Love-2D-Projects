-- heroes/dabbler.lua - Rogue class implementation
local Hero = require('heroes/hero')
local Dabbler = setmetatable({}, Hero)
Dabbler.__index = Dabbler

function Dabbler.new(x, y)
    local self = setmetatable(Hero.new(x, y, 12, 12, {0.5, 0.5, 0.5}, "dabbler"), Dabbler)
    self.attackPower = 20
    self.defense = 2
    self.speed = 100
    self.criticalChance = 0.3
    self.vaporizeActive = false
    
    -- Dabblers are more greedy and opportunistic
    self.personality.greed = math.min(1.0, self.personality.greed + 0.3)
    self.motivationThreshold = 0.3 -- More easily motivated by bounties
    
    return self
end

function Dabbler:update(dt)
    Hero.update(self, dt)
    
    -- Check for Vaporize ability on single high-value targets
    if self.combatTarget and self.combatTarget.hp > 50 and self.abilityCooldown <= 0 then
        if love.math.random() < 0.1 then -- 10% chance per update
            self:activateVaporize()
        end
    end
end

function Dabbler:activateVaporize()
    if self.combatTarget and self.abilityCooldown <= 0 then
        -- Massive burst damage
        local damage = self.attackPower * 5
        self.combatTarget:takeDamage(damage, self)
        
        -- Visual effect
        table.insert(require('game').floatingTexts, {
            x = self.combatTarget.x,
            y = self.combatTarget.y - 20,
            text = "VAPORIZED! -" .. math.floor(damage),
            color = {1, 0, 1},
            lifetime = 2,
            velocity = {0, -40}
        })
        
        self.abilityCooldown = 20 -- 20 second cooldown
    end
end

function Dabbler:draw()
    -- Small grey square
    love.graphics.setColor(self.color[1], self.color[2], self.color[3])
    love.graphics.rectangle("fill", self.x - self.width/2, self.y - self.height/2, self.width, self.height)
    
    -- Draw stealth indicator when moving fast
    if self.state == "pursuing_bounty" or self.state == "fleeing" then
        love.graphics.setColor(0.5, 0.5, 0.5, 0.3)
        love.graphics.circle("line", self.x, self.y, self.width)
    end
    
    Hero.draw(self) -- Draw health bars etc
end

return Dabbler