local Hero = require('heroes/hero')
local IndicaKnight = setmetatable({}, Hero)
IndicaKnight.__index = IndicaKnight

function IndicaKnight.new(x, y)
    local self = setmetatable(Hero.new(x, y, 20, 30, {0.2, 0.5, 0.2}), IndicaKnight)
    self.attackPower = 15
    self.defense = 10
    self.speed = 40
    self.abilityCooldown = 0
    self.abilityDuration = 0
    return self
end

function IndicaKnight:update(dt)
    Hero.update(self, dt)
    
    -- Check for Couch-lock Stance ability
    if self.abilityActive then
        self.abilityDuration = self.abilityDuration - dt
        if self.abilityDuration <= 0 then
            self.abilityActive = false
            self.defense = self.defense / 2 -- Reset defense
        end
    end
    
    -- Activate ability when surrounded by 3+ enemies
    if not self.abilityActive and self.abilityCooldown <= 0 then
        local nearbyEnemies = 0
        for _, enemy in ipairs(require('game').getEnemies()) do
            if self:distanceTo(enemy) < 50 then
                nearbyEnemies = nearbyEnemies + 1
            end
        end
        
        if nearbyEnemies >= 3 then
            self:activateAbility()
        end
    end
end

function IndicaKnight:activateAbility()
    self.abilityActive = true
    self.abilityDuration = 5 -- 5 seconds
    self.abilityCooldown = 30 -- 30 second cooldown
    self.defense = self.defense * 3 -- Triple defense
end

return IndicaKnight