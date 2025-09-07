-- heroes/psilocyber_stoner.lua - Wizard class implementation
local Hero = require('heroes/hero')
local PsilocyberStoner = setmetatable({}, Hero)
PsilocyberStoner.__index = PsilocyberStoner

function PsilocyberStoner.new(x, y)
    local self = setmetatable(Hero.new(x, y, 18, 18, {0.7, 0.3, 0.9}, "psilocyber_stoner"), PsilocyberStoner)
    self.attackPower = 12
    self.defense = 4
    self.speed = 35
    self.attackRange = 150 -- Ranged attacker
    self.pulseTime = 0
    
    -- Wizards are wise but not very brave
    self.personality.wisdom = math.min(1.0, self.personality.wisdom + 0.3)
    self.personality.bravery = self.personality.bravery * 0.7
    
    return self
end

function PsilocyberStoner:update(dt)
    Hero.update(self, dt)
    
    self.pulseTime = self.pulseTime + dt
    
    -- Maintain distance from enemies
    if self.combatTarget and self:distanceTo(self.combatTarget) < 80 then
        -- Move away to maintain range
        local dx = self.x - self.combatTarget.x
        local dy = self.y - self.combatTarget.y
        local dist = math.sqrt(dx*dx + dy*dy)
        if dist > 0 then
            self.x = self.x + (dx/dist) * self.speed * dt * 0.5
            self.y = self.y + (dy/dist) * self.speed * dt * 0.5
        end
    end
    
    -- Check for Hallucinate ability
    if self.abilityCooldown <= 0 then
        local nearbyEnemies = self:countNearbyEnemies(100)
        if nearbyEnemies >= 2 then
            self:activateHallucinate()
        end
    end
end

function PsilocyberStoner:countNearbyEnemies(range)
    local count = 0
    for _, enemy in ipairs(require('game').getEnemies()) do
        if enemy.isAlive and self:distanceTo(enemy) < range then
            count = count + 1
        end
    end
    return count
end

function PsilocyberStoner:activateHallucinate()
    -- Make nearby enemies confused and attack each other
    for _, enemy in ipairs(require('game').getEnemies()) do
        if self:distanceTo(enemy) < 100 then
            enemy.state = "confused"
            enemy.confusionTimer = 5
            
            -- Find a random target for the confused enemy
            local enemies = require('game').getEnemies()
            if #enemies > 1 then
                local randomEnemy = enemies[love.math.random(#enemies)]
                if randomEnemy ~= enemy then
                    enemy.target = randomEnemy
                end
            end
        end
    end
    
    -- Visual effect
    table.insert(require('game').floatingTexts, {
        x = self.x,
        y = self.y - 20,
        text = "HALLUCINATE!",
        color = {0.7, 0.3, 0.9},
        lifetime = 2,
        velocity = {0, -20}
    })
    
    self.abilityCooldown = 25
end

function PsilocyberStoner:draw()
    -- Purple circle that pulses
    local pulse = math.sin(self.pulseTime * 3) * 0.2 + 1
    love.graphics.setColor(self.color[1], self.color[2], self.color[3])
    love.graphics.circle("fill", self.x, self.y, (self.width/2) * pulse)
    
    -- Draw magic aura
    love.graphics.setColor(0.7, 0.3, 0.9, 0.3)
    love.graphics.circle("line", self.x, self.y, self.width * pulse)
    
    Hero.draw(self)
end

return PsilocyberStoner