-- enemies/lair.lua - Fixed lair with proper drawing
local Building = require('buildings/building')
local Lair = setmetatable({}, Building)
Lair.__index = Lair

function Lair.new(x, y)
    local self = setmetatable(Building.new(x, y, 50, 50, {0.6, 0, 0}, "lair"), Lair)
    self.hp = 200
    self.maxHp = 200
    self.spawnTimer = 0
    self.spawnInterval = 20 -- Base spawn interval
    self.maxEnemies = 5
    self.spawnedEnemies = {}
    self.level = 1
    self.aggressionLevel = 1
    
    -- Adjust based on difficulty
    local difficulty = require('gamestate').difficulty
    if difficulty == "easy" then
        self.spawnInterval = 30
        self.maxEnemies = 3
        self.aggressionLevel = 0.5
    elseif difficulty == "normal" then
        self.spawnInterval = 20
        self.maxEnemies = 5
        self.aggressionLevel = 1
    elseif difficulty == "hard" then
        self.spawnInterval = 12
        self.maxEnemies = 8
        self.hp = 300
        self.maxHp = 300
        self.aggressionLevel = 1.5
    end
    
    return self
end

function Lair:update(dt)
    if not self.isAlive then return end
    
    -- Clean up dead enemies from our list
    for i = #self.spawnedEnemies, 1, -1 do
        if not self.spawnedEnemies[i] or not self.spawnedEnemies[i].isAlive then
            table.remove(self.spawnedEnemies, i)
        end
    end
    
    -- Aggressive spawn timer
    self.spawnTimer = self.spawnTimer + dt * self.aggressionLevel
    if self.spawnTimer >= self.spawnInterval then
        self.spawnTimer = 0
        
        -- Always try to maintain maximum enemies
        while #self.spawnedEnemies < self.maxEnemies do
            self:spawnEnemy()
        end
    end
    
    -- Gradually increase difficulty over time
    local gameTime = require('game').gameTime
    if gameTime > 180 and self.level == 1 then -- 3 minutes
        self.level = 2
        self.spawnInterval = math.max(8, self.spawnInterval * 0.75)
        self.maxEnemies = self.maxEnemies + 2
        self.aggressionLevel = self.aggressionLevel * 1.2
        require('game'):addMessage("Enemy lair has grown stronger!")
    elseif gameTime > 360 and self.level == 2 then -- 6 minutes
        self.level = 3
        self.spawnInterval = math.max(6, self.spawnInterval * 0.75)
        self.maxEnemies = self.maxEnemies + 3
        self.aggressionLevel = self.aggressionLevel * 1.3
        require('game'):addMessage("Enemy lair has reached maximum strength!")
    elseif gameTime > 600 and self.level == 3 then -- 10 minutes
        self.level = 4
        self.spawnInterval = math.max(5, self.spawnInterval * 0.8)
        self.maxEnemies = self.maxEnemies + 2
        self.aggressionLevel = self.aggressionLevel * 1.2
        require('game'):addMessage("Enemy lair has become legendary!")
    end
    
    -- Periodically send attack waves
    if love.math.random() < 0.001 * self.aggressionLevel then
        self:sendAttackWave()
    end
end

function Lair:spawnEnemy()
    -- Determine enemy type based on lair level
    local enemyType = love.math.random(1, math.min(4, self.level + 1))
    local enemy
    
    -- Find a valid spawn position near the lair
    local spawnX = self.x + love.math.random(-80, 80)
    local spawnY = self.y + love.math.random(-80, 80)
    
    -- Ensure spawn position is passable
    local map = require('map')
    local attempts = 0
    while not map.isPassable(spawnX, spawnY) and attempts < 10 do
        spawnX = self.x + love.math.random(-80, 80)
        spawnY = self.y + love.math.random(-80, 80)
        attempts = attempts + 1
    end
    
    if enemyType == 1 then
        -- Spawn weak enemy (Buzzkill Beetle)
        enemy = require('enemies/buzzkill_beetle').new(spawnX, spawnY)
        enemy.hp = enemy.hp * (1 + (self.level - 1) * 0.3)
        enemy.maxHp = enemy.maxHp * (1 + (self.level - 1) * 0.3)
        enemy.attackPower = enemy.attackPower * (1 + (self.level - 1) * 0.2)
    elseif enemyType == 2 then
        -- Spawn strong enemy (Harvester Golem)
        enemy = require('enemies/harvester_golem').new(spawnX, spawnY)
        enemy.hp = enemy.hp * (1 + (self.level - 1) * 0.3)
        enemy.maxHp = enemy.maxHp * (1 + (self.level - 1) * 0.3)
        enemy.attackPower = enemy.attackPower * (1 + (self.level - 1) * 0.2)
    elseif enemyType == 3 then
        -- Spawn elite beetle
        enemy = require('enemies/buzzkill_beetle').new(spawnX, spawnY)
        enemy.hp = enemy.hp * 2.5
        enemy.maxHp = enemy.maxHp * 2.5
        enemy.attackPower = enemy.attackPower * 1.8
        enemy.speed = enemy.speed * 1.3
        enemy.color = {0.2, 0, 0.2} -- Darker, more menacing
    else
        -- Spawn champion golem
        enemy = require('enemies/harvester_golem').new(spawnX, spawnY)
        enemy.hp = enemy.hp * 3
        enemy.maxHp = enemy.maxHp * 3
        enemy.attackPower = enemy.attackPower * 2
        enemy.speed = enemy.speed * 1.1
        enemy.color = {0.8, 0.2, 0.2} -- Reddish tint for champion
    end
    
    if enemy then
        -- Make spawned enemies more aggressive
        enemy.sightRadius = enemy.sightRadius * (1 + self.aggressionLevel * 0.5)
        enemy.homeLair = self
        
        -- Track this enemy
        table.insert(self.spawnedEnemies, enemy)
        
        -- Add to game
        require('game').addEnemy(enemy)
        
        -- Make spawned enemies immediately seek targets
        enemy:findTarget()
    end
end

function Lair:sendAttackWave()
    -- Send a coordinated attack wave
    local targetBuilding = nil
    local minDistance = math.huge
    
    -- Find nearest PLAYER building (not other lairs!)
    for _, building in ipairs(require('game').getBuildings()) do
        -- IMPORTANT: Only target non-lair buildings (player structures)
        if building.isAlive and building.type ~= "lair" then
            local dist = self:distanceTo(building)
            -- Prioritize palace
            if building.type == "palace" then
                dist = dist * 0.5
            end
            if dist < minDistance then
                minDistance = dist
                targetBuilding = building
            end
        end
    end
    
    if targetBuilding then
        -- Send all idle enemies to attack
        for _, enemy in ipairs(self.spawnedEnemies) do
            if enemy and enemy.isAlive and enemy.state == "wandering" then
                enemy.target = targetBuilding
                enemy.state = "pursuing"
            end
        end
        
        -- Spawn extra enemies for the wave
        local waveSize = math.min(3, self.maxEnemies - #self.spawnedEnemies)
        for i = 1, waveSize do
            self:spawnEnemy()
            if self.spawnedEnemies[#self.spawnedEnemies] then
                self.spawnedEnemies[#self.spawnedEnemies].target = targetBuilding
                self.spawnedEnemies[#self.spawnedEnemies].state = "pursuing"
            end
        end
        
        require('game'):addMessage("Enemy attack wave incoming from " .. require('map').getDirectionFromPalace(self.x, self.y) .. "!")
    end
end

function Lair:takeDamage(amount, attacker)
    Building.takeDamage(self, amount)
    
    -- Alert all spawned enemies when lair is attacked
    if self.hp > 0 then
        for _, enemy in ipairs(self.spawnedEnemies) do
            if enemy and enemy.isAlive then
                -- Make enemies defend their lair
                if attacker then
                    enemy.target = attacker
                    enemy.state = "pursuing"
                else
                    enemy:findTarget()
                end
            end
        end
        
        -- Spawn defenders if heavily damaged
        if self.hp < self.maxHp * 0.5 and #self.spawnedEnemies < self.maxEnemies then
            for i = 1, math.min(2, self.maxEnemies - #self.spawnedEnemies) do
                self:spawnEnemy()
            end
        end
    end
end

function Lair:onDestroyed()
    Building.onDestroyed(self)
    
    -- Grant reward for destroying lair
    local reward = 300 + (200 * self.level)
    require('game').addCoins(reward)
    require('game'):addMessage("Lair destroyed! Earned " .. reward .. " KC!")
    
    -- Grant XP to nearby heroes
    for _, hero in ipairs(require('game').getHeroes()) do
        if hero:distanceTo(self) < 200 then
            hero:gainXP(100 * self.level)
        end
    end
    
    -- Check victory condition
    local lairsRemaining = 0
    for _, building in ipairs(require('game').buildings) do
        if building.type == "lair" and building.isAlive and building ~= self then
            lairsRemaining = lairsRemaining + 1
        end
    end
    
    if lairsRemaining > 0 then
        require('game'):addMessage(lairsRemaining .. " enemy lairs remaining!")
    end
end

function Lair:draw()
    -- Draw a menacing spiky structure
    love.graphics.setColor(self.color[1], self.color[2], self.color[3])
    
    -- Main body
    love.graphics.rectangle("fill", self.x - self.width/2, self.y - self.height/3, self.width, self.height * 2/3)
    
    -- Draw spikes (simplified to avoid nil errors)
    -- Left spike
    love.graphics.polygon("fill",
        self.x - self.width/2, self.y - self.height/3,
        self.x - self.width/2 - 10, self.y - self.height/2 - 5,
        self.x - self.width/3, self.y - self.height/3
    )
    
    -- Middle spike
    love.graphics.polygon("fill",
        self.x - self.width/6, self.y - self.height/3,
        self.x, self.y - self.height/2 - 15,
        self.x + self.width/6, self.y - self.height/3
    )
    
    -- Right spike
    love.graphics.polygon("fill",
        self.x + self.width/3, self.y - self.height/3,
        self.x + self.width/2 + 10, self.y - self.height/2 - 5,
        self.x + self.width/2, self.y - self.height/3
    )
    
    -- Dark entrance
    love.graphics.setColor(0, 0, 0)
    love.graphics.rectangle("fill", self.x - 10, self.y - 5, 20, 15)
    
    -- Draw spawn indicator when spawning
    if self.spawnTimer > self.spawnInterval - 2 then
        local alpha = (self.spawnTimer - (self.spawnInterval - 2)) / 2
        love.graphics.setColor(1, 0, 0, alpha)
        love.graphics.circle("line", self.x, self.y, self.width/2 + 15)
    end
    
    -- Draw health bar
    if self.hp < self.maxHp then
        local barWidth = self.width
        local barHeight = 6
        love.graphics.setColor(0, 0, 0)
        love.graphics.rectangle("fill", self.x - barWidth/2 - 1, self.y - self.height/2 - 21, barWidth + 2, barHeight + 2)
        
        love.graphics.setColor(1, 0, 0)
        love.graphics.rectangle("fill", self.x - barWidth/2, self.y - self.height/2 - 20, barWidth, barHeight)
        love.graphics.setColor(0, 1, 0)
        love.graphics.rectangle("fill", self.x - barWidth/2, self.y - self.height/2 - 20, barWidth * (self.hp / self.maxHp), barHeight)
    end
    
    -- Draw level indicator with stars
    if self.level > 1 then
        love.graphics.setColor(1, 0, 0)
        love.graphics.setFont(love.graphics.newFont(12))
        for i = 1, math.min(self.level, 5) do
            love.graphics.print("★", self.x - 20 + i * 8, self.y + self.height/2)
        end
    end
    
    -- Draw enemy count
    love.graphics.setColor(1, 1, 1)
    love.graphics.setFont(love.graphics.newFont(10))
    love.graphics.print(#self.spawnedEnemies .. "/" .. self.maxEnemies, self.x - 15, self.y + self.height/2 + 15)
    
    -- Draw aggression indicator
    if self.aggressionLevel > 1 then
        love.graphics.setColor(1, 0.5, 0, 0.5 + math.sin(love.timer.getTime() * 3) * 0.3)
        love.graphics.circle("line", self.x, self.y, self.width/2 + 5)
    end
end

return Lair