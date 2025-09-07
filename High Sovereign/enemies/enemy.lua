-- enemies/enemy.lua - Fixed enemy AI that won't attack own lairs
local Entity = require('entity')
local Enemy = setmetatable({}, Entity)
Enemy.__index = Enemy

function Enemy.new(x, y, width, height, color)
    local self = setmetatable(Entity.new(x, y, width, height), Enemy)
    self.color = color
    self.attackPower = 10
    self.sightRadius = 6
    self.state = "wandering"
    self.aggroTarget = nil
    self.wanderTarget = nil
    self.attackTimer = 0
    self.lastAttackTime = 0
    self.homeLair = nil  -- Reference to the lair that spawned this enemy
    return self
end

function Enemy:update(dt)
    if not self.isAlive then return end
    
    -- State machine
    if self.state == "wandering" then
        self:wander(dt)
    elseif self.state == "pursuing" then
        self:pursue(dt)
    elseif self.state == "attacking" then
        self:attack(dt)
    elseif self.state == "confused" then
        self:confused(dt)
    end
    
    -- Periodically check for targets
    if love.math.random() < 0.05 then
        self:findTarget()
    end
end

function Enemy:wander(dt)
    -- Wander around randomly
    if not self.wanderTarget or self:distanceTo(self.wanderTarget) < 10 then
        local angle = love.math.random() * math.pi * 2
        local distance = 50 + love.math.random() * 100
        self.wanderTarget = {
            x = self.x + math.cos(angle) * distance,
            y = self.y + math.sin(angle) * distance,
            isAlive = true
        }
    end
    
    self:moveTowards(self.wanderTarget.x, self.wanderTarget.y, dt)
    
    -- Check for nearby targets while wandering
    if love.math.random() < 0.02 then
        self:findTarget()
    end
end

function Enemy:pursue(dt)
    if not self.target or not self.target.isAlive then
        self.state = "wandering"
        self.target = nil
        return
    end
    
    local distance = self:distanceTo(self.target)
    
    -- If close enough, start attacking
    if distance < 30 then
        self.state = "attacking"
        return
    end
    
    -- Move towards target
    self:moveTowards(self.target.x, self.target.y, dt)
    
    -- Give up if target is too far
    if distance > self.sightRadius * 50 then
        self.state = "wandering"
        self.target = nil
    end
end

function Enemy:attack(dt)
    if not self.target or not self.target.isAlive then
        self.state = "wandering"
        self.target = nil
        return
    end
    
    local distance = self:distanceTo(self.target)
    
    -- If target moved away, pursue
    if distance > 40 then
        self.state = "pursuing"
        return
    end
    
    -- Attack logic
    self.attackTimer = self.attackTimer - dt
    if self.attackTimer <= 0 then
        local damage = self.attackPower * (0.8 + love.math.random() * 0.4)
        self.target:takeDamage(damage)
        self.attackTimer = 1.5 -- Attack cooldown
        
        -- Visual feedback
        table.insert(require('game').floatingTexts, {
            x = self.target.x,
            y = self.target.y,
            text = "-" .. math.floor(damage),
            color = {1, 0, 0},
            lifetime = 1,
            velocity = {love.math.random(-20, 20), -30}
        })
        
        -- Alert nearby enemies
        if love.math.random() < 0.3 then
            self:alertNearbyEnemies()
        end
    end
end

function Enemy:confused(dt)
    -- State when affected by abilities like Hallucinate
    if not self.confusionTimer then
        self.confusionTimer = 5
    end
    
    self.confusionTimer = self.confusionTimer - dt
    
    if self.confusionTimer <= 0 then
        self.state = "wandering"
        self.confusionTimer = nil
        self.target = nil
    else
        -- Attack random targets, including other enemies (but not lairs)
        if self.target and self.target.isAlive then
            self:attack(dt)
        else
            -- Find a new random target (other enemies, not buildings)
            local allTargets = {}
            
            -- Add enemies as potential targets
            for _, enemy in ipairs(require('game').getEnemies()) do
                if enemy ~= self and enemy.isAlive then
                    table.insert(allTargets, enemy)
                end
            end
            
            -- Add heroes
            for _, hero in ipairs(require('game').getHeroes()) do
                if hero.isAlive then
                    table.insert(allTargets, hero)
                end
            end
            
            if #allTargets > 0 then
                self.target = allTargets[love.math.random(#allTargets)]
                self.state = "pursuing"
            end
        end
    end
end

function Enemy:findTarget()
    local nearestTarget = nil
    local minDistance = self.sightRadius * 32
    
    -- Priority 1: Attack heroes
    for _, hero in ipairs(require('game').getHeroes()) do
        if hero.isAlive then
            local distance = self:distanceTo(hero)
            if distance < minDistance then
                minDistance = distance
                nearestTarget = hero
            end
        end
    end
    
    -- Priority 2: Attack player buildings (NOT enemy lairs)
    if not nearestTarget then
        minDistance = self.sightRadius * 32
        for _, building in ipairs(require('game').getBuildings()) do
            -- IMPORTANT: Only target player buildings, not lairs!
            if building.isAlive and building.type ~= "lair" then
                local distance = self:distanceTo(building)
                
                -- Prioritize palace
                if building.type == "palace" then
                    distance = distance * 0.5
                end
                
                if distance < minDistance then
                    minDistance = distance
                    nearestTarget = building
                end
            end
        end
    end
    
    -- Priority 3: Attack civilian units (weedlings, collectors)
    if not nearestTarget then
        -- Attack weedlings
        for _, weedling in ipairs(require('game').weedlings) do
            if weedling and weedling.isAlive then
                local distance = self:distanceTo(weedling)
                if distance < minDistance then
                    minDistance = distance
                    nearestTarget = weedling
                end
            end
        end
        
        -- Attack kush collectors
        for _, collector in ipairs(require('game').kushCollectors) do
            if collector and collector.isAlive then
                local distance = self:distanceTo(collector)
                if distance < minDistance then
                    minDistance = distance
                    nearestTarget = collector
                end
            end
        end
    end
    
    if nearestTarget then
        self.target = nearestTarget
        self.state = "pursuing"
    end
end

function Enemy:alertNearbyEnemies()
    -- Alert other enemies to join the attack
    for _, enemy in ipairs(require('game').getEnemies()) do
        if enemy ~= self and enemy.isAlive and enemy.state == "wandering" then
            if self:distanceTo(enemy) < 100 then
                enemy.target = self.target
                enemy.state = "pursuing"
            end
        end
    end
end

function Enemy:takeDamage(amount, attacker)
    Entity.takeDamage(self, amount)
    
    -- Create damage effect
    table.insert(require('game').floatingTexts, {
        x = self.x,
        y = self.y,
        text = "-" .. math.floor(amount),
        color = {1, 0, 0},
        lifetime = 1,
        velocity = {love.math.random(-20, 20), -30}
    })
    
    -- Aggro on attacker if not already engaged (but not on lairs)
    if attacker and not self.target then
        -- Don't aggro on lairs
        if not attacker.type or attacker.type ~= "lair" then
            self.target = attacker
            self.state = "pursuing"
        end
    end
    
    -- Alert nearby enemies when hurt
    if self.hp < self.maxHp * 0.5 then
        self:alertNearbyEnemies()
    end
    
    -- Drop loot on death
    if not self.isAlive then
        self:dropLoot()
    end
end

function Enemy:dropLoot()
    -- Chance to drop coins
    if love.math.random() < 0.7 then
        local lootAmount = love.math.random(5, 20)
        
        -- Create loot effect
        table.insert(require('game').floatingTexts, {
            x = self.x,
            y = self.y - 10,
            text = "+" .. lootAmount .. " KC",
            color = {1, 1, 0},
            lifetime = 2,
            velocity = {0, -15}
        })
        
        -- Actually give the coins to the player
        require('game').addCoins(lootAmount)
    end
end

function Enemy:draw()
    if not self.isAlive then return end
    
    -- Draw enemy body
    love.graphics.setColor(self.color[1], self.color[2], self.color[3])
    love.graphics.rectangle("fill", self.x - self.width/2, self.y - self.height/2, self.width, self.height)
    
    -- Draw aggro indicator
    if self.target then
        love.graphics.setColor(1, 0, 0, 0.5)
        love.graphics.circle("line", self.x, self.y, self.width)
    end
    
    -- Draw health bar
    local barWidth = 30
    local barHeight = 4
    love.graphics.setColor(0, 0, 0)
    love.graphics.rectangle("fill", self.x - barWidth/2 - 1, self.y - self.height/2 - 11, barWidth + 2, barHeight + 2)
    
    love.graphics.setColor(1, 0, 0)
    love.graphics.rectangle("fill", self.x - barWidth/2, self.y - self.height/2 - 10, barWidth, barHeight)
    love.graphics.setColor(0, 1, 0)
    love.graphics.rectangle("fill", self.x - barWidth/2, self.y - self.height/2 - 10, barWidth * (self.hp / self.maxHp), barHeight)
    
    -- Draw confused state
    if self.state == "confused" then
        love.graphics.setColor(1, 0, 1, 0.5)
        love.graphics.print("?", self.x - 5, self.y - self.height/2 - 20)
    end
end

return Enemy