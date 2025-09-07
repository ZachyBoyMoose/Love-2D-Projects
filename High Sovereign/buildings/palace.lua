-- buildings/palace.lua - Complete Palace implementation
local Building = require('buildings/building')
local Palace = setmetatable({}, Building)
Palace.__index = Palace

function Palace.new(x, y)
    local self = setmetatable(Building.new(x, y, 80, 80, {0.5, 0, 0.5}, "palace"), Palace)
    self.hp = 500
    self.maxHp = 500
    self.income = 50
    self.maxWeedlings = 5
    self.maxCollectors = 2
    self.weedlingSpawnTimer = 0
    self.weedlingSpawnInterval = 30  -- Spawn a new weedling every 30 seconds if below max
    self.collectorSpawnTimer = 0
    self.collectorSpawnInterval = 60  -- Spawn a new collector every 60 seconds if below max
    self.accumulatedTax = 0
    
    return self
end

function Palace:update(dt)
    if not self.isAlive then return end
    
    local game = require('game')
    
    -- Count current weedlings
    local currentWeedlings = #game.weedlings
    
    -- Spawn weedlings if below maximum
    if currentWeedlings < self.maxWeedlings then
        self.weedlingSpawnTimer = self.weedlingSpawnTimer + dt
        if self.weedlingSpawnTimer >= self.weedlingSpawnInterval then
            self.weedlingSpawnTimer = 0
            local weedling = require('units/weedling').new(
                self.x + love.math.random(-40, 40),
                self.y + love.math.random(-40, 40)
            )
            table.insert(game.weedlings, weedling)
            game:addMessage("New Weedling spawned at Palace")
        end
    end
    
    -- Count current collectors
    local currentCollectors = #game.kushCollectors
    
    -- Spawn collectors if below maximum
    if currentCollectors < self.maxCollectors then
        self.collectorSpawnTimer = self.collectorSpawnTimer + dt
        if self.collectorSpawnTimer >= self.collectorSpawnInterval then
            self.collectorSpawnTimer = 0
            local collector = require('units/kush_collector').new(
                self.x + love.math.random(-40, 40),
                self.y + love.math.random(-40, 40)
            )
            table.insert(game.kushCollectors, collector)
            game:addMessage("New Kush Collector spawned at Palace")
        end
    end
end

function Palace:receiveTax(amount)
    -- Receive tax from collectors
    self.accumulatedTax = self.accumulatedTax + amount
    require('game').addCoins(amount)
    
    -- Visual feedback
    table.insert(require('game').floatingTexts, {
        x = self.x,
        y = self.y - 30,
        text = "+" .. amount .. " KC (Tax)",
        color = {1, 1, 0},
        lifetime = 2,
        velocity = {0, -20}
    })
end

function Palace:takeDamage(amount)
    Building.takeDamage(self, amount)
    
    if not self.isAlive then
        -- Palace destroyed - immediate game over
        require('game'):addMessage("The Palace has fallen! The kingdom is lost!")
        require('gamestate').endGame(false, "Your Palace was destroyed!")
    end
end

function Palace:draw()
    -- Draw palace base
    love.graphics.setColor(self.color[1], self.color[2], self.color[3])
    love.graphics.rectangle("fill", self.x - self.width/2, self.y - self.height/2, self.width, self.height)
    
    -- Draw palace towers (corners)
    local towerSize = 15
    love.graphics.setColor(0.4, 0, 0.4)
    -- Top-left tower
    love.graphics.rectangle("fill", self.x - self.width/2 - 5, self.y - self.height/2 - 5, towerSize, towerSize)
    -- Top-right tower
    love.graphics.rectangle("fill", self.x + self.width/2 - 10, self.y - self.height/2 - 5, towerSize, towerSize)
    -- Bottom-left tower
    love.graphics.rectangle("fill", self.x - self.width/2 - 5, self.y + self.height/2 - 10, towerSize, towerSize)
    -- Bottom-right tower
    love.graphics.rectangle("fill", self.x + self.width/2 - 10, self.y + self.height/2 - 10, towerSize, towerSize)
    
    -- Draw palace crown/roof
    love.graphics.setColor(0.6, 0, 0.6)
    love.graphics.polygon("fill",
        self.x - self.width/3, self.y - self.height/2,
        self.x, self.y - self.height/2 - 20,
        self.x + self.width/3, self.y - self.height/2
    )
    
    -- Draw entrance
    love.graphics.setColor(0, 0, 0)
    love.graphics.rectangle("fill", self.x - 10, self.y + self.height/4, 20, 20)
    
    -- Draw KC symbol on palace
    love.graphics.setColor(1, 1, 0)
    love.graphics.circle("fill", self.x, self.y - 10, 12)
    love.graphics.setColor(0, 0, 0)
    love.graphics.setFont(love.graphics.newFont(14))
    love.graphics.print("KC", self.x - 8, self.y - 18)
    
    -- Draw spawn progress bars if spawning
    local barY = self.y + self.height/2 + 10
    
    -- Weedling spawn progress
    if #require('game').weedlings < self.maxWeedlings then
        local progress = self.weedlingSpawnTimer / self.weedlingSpawnInterval
        love.graphics.setColor(0.2, 0.2, 0.2)
        love.graphics.rectangle("fill", self.x - 30, barY, 60, 5)
        love.graphics.setColor(0.5, 0.35, 0.2)
        love.graphics.rectangle("fill", self.x - 30, barY, 60 * progress, 5)
        love.graphics.setColor(1, 1, 1)
        love.graphics.setFont(love.graphics.newFont(8))
        love.graphics.print("Weedling", self.x - 20, barY - 10)
    end
    
    -- Collector spawn progress
    if #require('game').kushCollectors < self.maxCollectors then
        local progress = self.collectorSpawnTimer / self.collectorSpawnInterval
        barY = barY + 15
        love.graphics.setColor(0.2, 0.2, 0.2)
        love.graphics.rectangle("fill", self.x - 30, barY, 60, 5)
        love.graphics.setColor(1, 1, 0)
        love.graphics.rectangle("fill", self.x - 30, barY, 60 * progress, 5)
        love.graphics.setColor(1, 1, 1)
        love.graphics.setFont(love.graphics.newFont(8))
        love.graphics.print("Collector", self.x - 20, barY - 10)
    end
    
    -- Draw health bar if damaged
    if self.hp < self.maxHp then
        local barWidth = self.width
        local barHeight = 8
        
        love.graphics.setColor(0, 0, 0)
        love.graphics.rectangle("fill", self.x - barWidth/2 - 1, self.y - self.height/2 - 31, barWidth + 2, barHeight + 2)
        
        love.graphics.setColor(1, 0, 0)
        love.graphics.rectangle("fill", self.x - barWidth/2, self.y - self.height/2 - 30, barWidth, barHeight)
        love.graphics.setColor(0, 1, 0)
        love.graphics.rectangle("fill", self.x - barWidth/2, self.y - self.height/2 - 30, barWidth * (self.hp / self.maxHp), barHeight)
        
        -- Show critical warning
        if self.hp < self.maxHp * 0.3 then
            love.graphics.setColor(1, 0, 0, 0.5 + math.sin(love.timer.getTime() * 5) * 0.5)
            love.graphics.setFont(love.graphics.newFont(16))
            love.graphics.print("⚠ PALACE CRITICAL ⚠", self.x - 60, self.y - self.height/2 - 50)
        end
    end
end

return {
    new = Palace.new
}