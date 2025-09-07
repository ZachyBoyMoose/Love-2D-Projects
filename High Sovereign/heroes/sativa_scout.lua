local Hero = require('heroes/hero')
local SativaScout = setmetatable({}, Hero)
SativaScout.__index = SativaScout

function SativaScout.new(x, y)
    local self = setmetatable(Hero.new(x, y, 10, 40, {0.6, 0.9, 0.4}), SativaScout)
    self.attackPower = 8
    self.defense = 3
    self.speed = 80
    self.attackRange = 100
    self.abilityCooldown = 0
    self.abilityActive = false
    return self
end

function SativaScout:update(dt)
    Hero.update(self, dt)
    
    -- Check for Speed Boost ability
    if self.abilityActive then
        self.abilityDuration = self.abilityDuration - dt
        if self.abilityDuration <= 0 then
            self.abilityActive = false
            self.speed = self.speed / 1.5 -- Reset speed
            self.attackRange = self.attackRange / 1.3 -- Reset range
        end
    end
end

function SativaScout:activateAbility()
    self.abilityActive = true
    self.abilityDuration = 7 -- 7 seconds
    self.abilityCooldown = 20 -- 20 second cooldown
    self.speed = self.speed * 1.5 -- Increase speed
    self.attackRange = self.attackRange * 1.3 -- Increase range
end

return SativaScout