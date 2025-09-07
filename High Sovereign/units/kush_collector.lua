-- units/kush_collector.lua - Enhanced Kush Collector with automatic tax collection
local Entity = require('entity')
local KushCollector = setmetatable({}, Entity)
KushCollector.__index = KushCollector

function KushCollector.new(x, y)
    local self = setmetatable(Entity.new(x, y, 12, 12), KushCollector)
    self.color = {1, 1, 0}
    self.state = "idle" -- idle, collecting, returning, waiting
    self.targetBuilding = nil
    self.collectedCoins = 0
    self.hp = 15
    self.maxHp = 15
    self.speed = 80
    self.collectionRange = 30
    self.waitTimer = 0
    self.maxCarryCapacity = 100
    
    return self
end

function KushCollector:update(dt)
    if not self.isAlive then return end
    
    if self.state == "idle" or self.state == "waiting" then
        -- Wait a bit between collections
        if self.state == "waiting" then
            self.waitTimer = self.waitTimer - dt
            if self.waitTimer <= 0 then
                self.state = "idle"
            else
                return
            end
        end
        
        -- Find a building with tax to collect
        local targetBuilding = self:findBuildingWithTax()
        if targetBuilding then
            self.targetBuilding = targetBuilding
            self.state = "collecting"
        elseif self.collectedCoins > 0 then
            -- Return to palace if carrying coins
            self.state = "returning"
        end
    elseif self.state == "collecting" then
        if self.targetBuilding and self.targetBuilding.isAlive and not self.targetBuilding.isDestroyed then
            if self:distanceTo(self.targetBuilding) > self.collectionRange then
                -- Move to building
                self:moveTowards(self.targetBuilding.x, self.targetBuilding.y, dt)
            else
                -- Collect tax
                local taxAmount = self.targetBuilding:collectTax()
                if taxAmount > 0 then
                    self.collectedCoins = math.min(self.collectedCoins + taxAmount, self.maxCarryCapacity)
                    
                    -- Visual feedback
                    table.insert(require('game').floatingTexts, {
                        x = self.targetBuilding.x,
                        y = self.targetBuilding.y - 20,
                        text = "-" .. taxAmount .. " KC",
                        color = {1, 1, 0},
                        lifetime = 1.5,
                        velocity = {0, -15}
                    })
                end
                
                -- Check if should return or continue collecting
                if self.collectedCoins >= self.maxCarryCapacity * 0.8 then
                    self.state = "returning"
                else
                    self.targetBuilding = nil
                    self.state = "idle"
                end
            end
        else
            self.targetBuilding = nil
            self.state = "idle"
        end
    elseif self.state == "returning" then
        local palace = require('game').palace
        if palace and palace.isAlive then
            if self:distanceTo(palace) > self.collectionRange then
                -- Move to palace
                self:moveTowards(palace.x, palace.y, dt)
            else
                -- Deliver coins
                if self.collectedCoins > 0 then
                    palace:receiveTax(self.collectedCoins)
                    self.collectedCoins = 0
                end
                
                -- Wait before next collection cycle
                self.state = "waiting"
                self.waitTimer = 3
            end
        else
            -- No palace, just wait
            self.state = "idle"
        end
    end
end

function KushCollector:findBuildingWithTax()
    local buildings = require('game').getBuildings()
    local bestBuilding = nil
    local highestTax = 5  -- Minimum tax to bother collecting
    
    for _, building in ipairs(buildings) do
        if building.taxAmount and building.taxAmount > highestTax and 
           not building.isDestroyed and building.type ~= "palace" then
            -- Prioritize buildings with more tax
            if building.taxAmount > highestTax then
                highestTax = building.taxAmount
                bestBuilding = building
            end
        end
    end
    
    return bestBuilding
end

function KushCollector:takeDamage(amount)
    Entity.takeDamage(self, amount)
    
    if not self.isAlive then
        -- Drop collected coins
        if self.collectedCoins > 0 then
            require('game'):addMessage("Kush Collector killed! Lost " .. self.collectedCoins .. " KC!")
            
            -- Visual feedback for lost coins
            table.insert(require('game').floatingTexts, {
                x = self.x,
                y = self.y,
                text = "-" .. self.collectedCoins .. " KC LOST!",
                color = {1, 0, 0},
                lifetime = 3,
                velocity = {0, -20}
            })
        end
        
        -- Remove from game's collector list
        local game = require('game')
        for i, collector in ipairs(game.kushCollectors) do
            if collector == self then
                table.remove(game.kushCollectors, i)
                break
            end
        end
    end
end

function KushCollector:draw()
    if not self.isAlive then return end
    
    -- Draw collector body
    love.graphics.setColor(self.color[1], self.color[2], self.color[3])
    love.graphics.rectangle("fill", self.x - self.width/2, self.y - self.height/2, self.width, self.height)
    
    -- Draw coin bag if carrying coins
    if self.collectedCoins > 0 then
        -- Bag size based on amount carried
        local bagSize = 4 + (self.collectedCoins / self.maxCarryCapacity) * 4
        love.graphics.setColor(0.4, 0.8, 0.4)
        love.graphics.circle("fill", self.x, self.y - 8, bagSize)
        
        -- Show amount carried
        love.graphics.setColor(1, 1, 1)
        love.graphics.setFont(love.graphics.newFont(8))
        love.graphics.print(self.collectedCoins, self.x - 8, self.y - 20)
    end
    
    -- Draw state indicator
    love.graphics.setColor(1, 1, 1)
    love.graphics.setFont(love.graphics.newFont(8))
    if self.state == "collecting" then
        love.graphics.print("C", self.x - 3, self.y + 8)
    elseif self.state == "returning" then
        love.graphics.print("R", self.x - 3, self.y + 8)
    elseif self.state == "waiting" then
        love.graphics.print("W", self.x - 3, self.y + 8)
    end
    
    -- Draw health bar if damaged
    if self.hp < self.maxHp then
        local barWidth = 15
        local barHeight = 3
        love.graphics.setColor(1, 0, 0)
        love.graphics.rectangle("fill", self.x - barWidth/2, self.y - 10, barWidth, barHeight)
        love.graphics.setColor(0, 1, 0)
        love.graphics.rectangle("fill", self.x - barWidth/2, self.y - 10, barWidth * (self.hp / self.maxHp), barHeight)
    end
end

return KushCollector