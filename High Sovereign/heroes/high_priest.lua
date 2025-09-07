-- heroes/high_priest.lua - Priestess/Healer class implementation
local Hero = require('heroes/hero')
local HighPriest = setmetatable({}, Hero)
HighPriest.__index = HighPriest

function HighPriest.new(x, y)
    local self = setmetatable(Hero.new(x, y, 16, 16, {1, 1, 1}, "high_priest"), HighPriest)
    self.attackPower = 5
    self.defense = 3
    self.speed = 45
    self.healPower = 15
    self.healTarget = nil
    self.kushlings = {}
    
    -- Priests are wise and moderately brave
    self.personality.wisdom = math.min(1.0, self.personality.wisdom + 0.4)
    self.personality.greed = self.personality.greed * 0.5 -- Less greedy
    
    return self
end

function HighPriest:update(dt)
    Hero.update(self, dt)
    
    -- Update kushlings
    for i = #self.kushlings, 1, -1 do
        local kushling = self.kushlings[i]
        kushling.lifetime = kushling.lifetime - dt
        if kushling.lifetime <= 0 then
            table.remove(self.kushlings, i)
        else
            self:updateKushling(kushling, dt)
        end
    end
    
    -- Look for allies to heal
    if self.state ~= "fighting" then
        self:findHealTarget()
    end
    
    -- Check for Summon Kushlings ability
    if self.abilityCooldown <= 0 then
        local criticalAllies = self:countCriticalAllies(150)
        if criticalAllies > 0 then
            self:summonKushlings()
        end
    end
end

function HighPriest:findHealTarget()
    local lowestHpRatio = 0.5 -- Only heal allies below 50% health
    local healTarget = nil
    
    for _, hero in ipairs(require('game').getHeroes()) do
        if hero ~= self and hero.isAlive then
            local hpRatio = hero.hp / hero.maxHp
            if hpRatio < lowestHpRatio and self:distanceTo(hero) < 200 then
                lowestHpRatio = hpRatio
                healTarget = hero
            end
        end
    end
    
    if healTarget then
        self.healTarget = healTarget
        self.state = "healing"
    end
end

function HighPriest:countCriticalAllies(range)
    local count = 0
    for _, hero in ipairs(require('game').getHeroes()) do
        if hero ~= self and hero.isAlive and hero.hp < hero.maxHp * 0.25 and self:distanceTo(hero) < range then
            count = count + 1
        end
    end
    return count
end

function HighPriest:summonKushlings()
    -- Summon 2-3 Kushlings
    local count = love.math.random(2, 3)
    for i = 1, count do
        local kushling = {
            x = self.x + love.math.random(-30, 30),
            y = self.y + love.math.random(-30, 30),
            lifetime = 10,
            speed = 60,
            damage = 5
        }
        table.insert(self.kushlings, kushling)
    end
    
    -- Visual effect
    table.insert(require('game').floatingTexts, {
        x = self.x,
        y = self.y - 20,
        text = "KUSHLINGS SUMMONED!",
        color = {0.4, 0.8, 0.4},
        lifetime = 2,
        velocity = {0, -20}
    })
    
    self.abilityCooldown = 40
end

function HighPriest:updateKushling(kushling, dt)
    -- Find nearest enemy
    local nearestEnemy = nil
    local minDist = math.huge
    
    for _, enemy in ipairs(require('game').getEnemies()) do
        if enemy.isAlive then
            local dist = math.sqrt((kushling.x - enemy.x)^2 + (kushling.y - enemy.y)^2)
            if dist < minDist then
                minDist = dist
                nearestEnemy = enemy
            end
        end
    end
    
    if nearestEnemy and minDist < 200 then
        -- Move toward enemy
        local dx = nearestEnemy.x - kushling.x
        local dy = nearestEnemy.y - kushling.y
        local dist = math.sqrt(dx*dx + dy*dy)
        
        if dist > 10 then
            kushling.x = kushling.x + (dx/dist) * kushling.speed * dt
            kushling.y = kushling.y + (dy/dist) * kushling.speed * dt
        else
            -- Attack
            nearestEnemy:takeDamage(kushling.damage * dt, self)
        end
    end
end

function HighPriest:draw()
    -- White circle
    love.graphics.setColor(self.color[1], self.color[2], self.color[3])
    love.graphics.circle("fill", self.x, self.y, self.width/2)
    
    -- Green cross in the middle
    love.graphics.setColor(0.4, 0.8, 0.4)
    love.graphics.setLineWidth(2)
    love.graphics.line(self.x - 5, self.y, self.x + 5, self.y)
    love.graphics.line(self.x, self.y - 5, self.x, self.y + 5)
    love.graphics.setLineWidth(1)
    
    -- Draw kushlings
    love.graphics.setColor(0.4, 0.8, 0.4)
    for _, kushling in ipairs(self.kushlings) do
        love.graphics.circle("fill", kushling.x, kushling.y, 4)
    end
    
    -- Draw heal beam if healing
    if self.healTarget and self.state == "healing" then
        love.graphics.setColor(0.4, 1, 0.4, 0.5)
        love.graphics.setLineWidth(3)
        love.graphics.line(self.x, self.y, self.healTarget.x, self.healTarget.y)
        love.graphics.setLineWidth(1)
    end
    
    Hero.draw(self)
end

return HighPriest