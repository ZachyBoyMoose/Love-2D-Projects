-- buildings/building.lua - Enhanced building with destruction and repair mechanics
local Entity = require('entity')
local Building = setmetatable({}, Entity)
Building.__index = Building

function Building.new(x, y, width, height, color, buildingType)
    local self = setmetatable(Entity.new(x, y, width, height), Building)
    self.color = color
    self.originalColor = {color[1], color[2], color[3]}
    self.type = buildingType
    self.income = 0
    self.cost = 100
    self.isBuilt = true
    self.isDestroyed = false
    self.taxAmount = 0
    self.taxAccumulation = 0
    self.taxRate = 5  -- KC per cycle
    self.visitorCount = 0
    self.lastVisitorTime = 0
    self.repairProgress = 0
    self.repairCost = 0
    self.beingRepaired = false
    self.constructionProgress = 0
    self.recruitmentProgress = 0
    self.recruitmentTime = 0
    self.upgradeProgress = 0
    self.upgradeTime = 0
    
    return self
end

function Building:update(dt)
    if not self.isBuilt then return end
    
    -- Accumulate tax if not destroyed
    if not self.isDestroyed then
        self.taxAccumulation = self.taxAccumulation + self.taxRate * dt / 10  -- Accumulate slowly
        if self.taxAccumulation >= 1 then
            local taxToAdd = math.floor(self.taxAccumulation)
            self.taxAmount = self.taxAmount + taxToAdd
            self.taxAccumulation = self.taxAccumulation - taxToAdd
        end
    end
    
    -- Update recruitment progress
    if self.recruitmentTime > 0 then
        self.recruitmentProgress = self.recruitmentProgress + dt
        if self.recruitmentProgress >= self.recruitmentTime then
            self:completeRecruitment()
            self.recruitmentProgress = 0
            self.recruitmentTime = 0
        end
    end
    
    -- Update upgrade progress
    if self.upgradeTime > 0 then
        self.upgradeProgress = self.upgradeProgress + dt
        if self.upgradeProgress >= self.upgradeTime then
            self:completeUpgrade()
            self.upgradeProgress = 0
            self.upgradeTime = 0
        end
    end
end

function Building:takeDamage(amount)
    if self.isDestroyed then return end
    
    Entity.takeDamage(self, amount)
    
    -- Create damage effect
    table.insert(require('game').floatingTexts, {
        x = self.x,
        y = self.y,
        text = "-" .. math.floor(amount),
        color = {1, 0, 0},
        lifetime = 1,
        velocity = {love.math.random(-10, 10), -20}
    })
    
    -- Alert if building is critical
    if self.hp < self.maxHp * 0.3 and self.hp > 0 then
        require('game'):addMessage(self.type .. " is under attack!")
    end
    
    if self.hp <= 0 then
        self:onDestroyed()
    end
end

function Building:onDestroyed()
    self.isDestroyed = true
    self.hp = 0
    
    -- Darken the color to show destruction
    self.color[1] = self.originalColor[1] * 0.3
    self.color[2] = self.originalColor[2] * 0.3
    self.color[3] = self.originalColor[3] * 0.3
    
    -- Calculate repair cost
    self.repairCost = math.floor(self.cost * 0.5)
    
    require('game'):addMessage(self.type .. " has been destroyed! Needs repair (" .. self.repairCost .. " KC)")
    
    -- Special handling for palace destruction
    if self.type == "palace" then
        require('gamestate').endGame(false, "The Palace has fallen! The kingdom is lost!")
    end
end

function Building:startRepair(weedling)
    if not self.isDestroyed then return false end
    
    local game = require('game')
    if game.kushCoins >= self.repairCost then
        game.spendCoins(self.repairCost)
        self.beingRepaired = true
        self.repairProgress = 0
        return true
    else
        game:addMessage("Not enough KC to repair! Need " .. self.repairCost)
        return false
    end
end

function Building:updateRepair(dt)
    if not self.beingRepaired then return end
    
    self.repairProgress = self.repairProgress + dt / 10  -- 10 seconds to repair
    
    if self.repairProgress >= 1 then
        self:completeRepair()
    end
end

function Building:completeRepair()
    self.isDestroyed = false
    self.beingRepaired = false
    self.repairProgress = 0
    self.hp = self.maxHp * 0.5  -- Restore to half health
    
    -- Restore original color
    self.color[1] = self.originalColor[1]
    self.color[2] = self.originalColor[2]
    self.color[3] = self.originalColor[3]
    
    require('game'):addMessage(self.type .. " has been repaired!")
end

function Building:canFunction()
    return self.isBuilt and not self.isDestroyed and not self.beingRepaired
end

function Building:collectTax()
    local collected = self.taxAmount
    self.taxAmount = 0
    return collected
end

function Building:draw()
    -- Building shadow
    love.graphics.setColor(0, 0, 0, 0.3)
    love.graphics.rectangle("fill", self.x - self.width/2 + 3, self.y - self.height/2 + 3, self.width, self.height)
    
    -- Main building (darkened if destroyed)
    love.graphics.setColor(self.color[1], self.color[2], self.color[3])
    love.graphics.rectangle("fill", self.x - self.width/2, self.y - self.height/2, self.width, self.height)
    
    -- Building outline
    love.graphics.setColor(0, 0, 0)
    love.graphics.rectangle("line", self.x - self.width/2, self.y - self.height/2, self.width, self.height)
    
    -- Draw destruction effects
    if self.isDestroyed then
        -- Draw smoke particles
        love.graphics.setColor(0.3, 0.3, 0.3, 0.6)
        for i = 1, 5 do
            local offset = math.sin(love.timer.getTime() * 2 + i) * 10
            local yOffset = -math.abs(math.sin(love.timer.getTime() + i)) * 20
            love.graphics.circle("fill", self.x + offset, self.y + yOffset - 10, 5 + i)
        end
        
        -- Draw rubble
        love.graphics.setColor(0.2, 0.2, 0.2)
        love.graphics.rectangle("fill", self.x - self.width/3, self.y + self.height/3, self.width/3, self.height/6)
        love.graphics.rectangle("fill", self.x, self.y + self.height/4, self.width/4, self.height/5)
        
        -- Draw "DESTROYED" text
        love.graphics.setColor(1, 0, 0)
        love.graphics.setFont(love.graphics.newFont(10))
        love.graphics.print("DESTROYED", self.x - 30, self.y)
    end
    
    -- Draw repair progress bar
    if self.beingRepaired then
        local barWidth = self.width
        local barHeight = 6
        local barY = self.y + self.height/2 + 10
        
        love.graphics.setColor(0.2, 0.2, 0.2)
        love.graphics.rectangle("fill", self.x - barWidth/2, barY, barWidth, barHeight)
        love.graphics.setColor(0.5, 0.35, 0.2)
        love.graphics.rectangle("fill", self.x - barWidth/2, barY, barWidth * self.repairProgress, barHeight)
        
        love.graphics.setColor(1, 1, 1)
        love.graphics.setFont(love.graphics.newFont(8))
        love.graphics.print("Repairing...", self.x - 25, barY - 12)
    end
    
    -- Draw recruitment progress bar
    if self.recruitmentTime > 0 then
        local barWidth = self.width
        local barHeight = 6
        local barY = self.y - self.height/2 - 15
        
        love.graphics.setColor(0.2, 0.2, 0.2)
        love.graphics.rectangle("fill", self.x - barWidth/2, barY, barWidth, barHeight)
        love.graphics.setColor(0, 0.5, 1)
        love.graphics.rectangle("fill", self.x - barWidth/2, barY, barWidth * (self.recruitmentProgress / self.recruitmentTime), barHeight)
        
        love.graphics.setColor(1, 1, 1)
        love.graphics.setFont(love.graphics.newFont(8))
        love.graphics.print("Recruiting...", self.x - 25, barY - 12)
    end
    
    -- Draw upgrade progress bar
    if self.upgradeTime > 0 then
        local barWidth = self.width
        local barHeight = 6
        local barY = self.y - self.height/2 - 25
        
        love.graphics.setColor(0.2, 0.2, 0.2)
        love.graphics.rectangle("fill", self.x - barWidth/2, barY, barWidth, barHeight)
        love.graphics.setColor(0.8, 0.8, 0.2)
        love.graphics.rectangle("fill", self.x - barWidth/2, barY, barWidth * (self.upgradeProgress / self.upgradeTime), barHeight)
        
        love.graphics.setColor(1, 1, 1)
        love.graphics.setFont(love.graphics.newFont(8))
        love.graphics.print("Upgrading...", self.x - 25, barY - 12)
    end
    
    -- Draw health bar if damaged and not destroyed
    if not self.isDestroyed and self.hp < self.maxHp then
        local barWidth = self.width
        local barHeight = 4
        
        love.graphics.setColor(0, 0, 0)
        love.graphics.rectangle("fill", self.x - barWidth/2 - 1, self.y - self.height/2 - 11, barWidth + 2, barHeight + 2)
        
        love.graphics.setColor(1, 0, 0)
        love.graphics.rectangle("fill", self.x - barWidth/2, self.y - self.height/2 - 10, barWidth, barHeight)
        love.graphics.setColor(0, 1, 0)
        love.graphics.rectangle("fill", self.x - barWidth/2, self.y - self.height/2 - 10, barWidth * (self.hp / self.maxHp), barHeight)
    end
    
    -- Draw tax indicator if has accumulated tax
    if self.taxAmount and self.taxAmount > 0 and not self.isDestroyed then
        love.graphics.setColor(1, 1, 0)
        love.graphics.circle("fill", self.x + self.width/2 - 5, self.y - self.height/2 + 5, 4)
        love.graphics.setColor(0, 0, 0)
        love.graphics.setFont(love.graphics.newFont(8))
        love.graphics.print(math.floor(self.taxAmount), self.x + self.width/2 - 8, self.y - self.height/2)
    end
end

function Building:drawConstruction(progress)
    progress = progress or 0
    
    -- Draw construction scaffold
    love.graphics.setColor(0.4, 0.3, 0.2, 0.8)
    love.graphics.rectangle("line", self.x - self.width/2 - 2, self.y - self.height/2 - 2, self.width + 4, self.height + 4)
    
    -- Draw partial building
    love.graphics.setColor(self.color[1] * 0.5, self.color[2] * 0.5, self.color[3] * 0.5, 0.7)
    love.graphics.rectangle("fill", self.x - self.width/2, self.y - self.height/2 + (1-progress) * self.height, self.width, self.height * progress)
    
    -- Draw progress bar with better visibility
    local barWidth = self.width
    local barHeight = 8
    local barY = self.y + self.height/2 + 10
    
    love.graphics.setColor(0.2, 0.2, 0.2)
    love.graphics.rectangle("fill", self.x - barWidth/2, barY, barWidth, barHeight)
    love.graphics.setColor(0.5, 0.35, 0.2)
    love.graphics.rectangle("fill", self.x - barWidth/2, barY, barWidth * progress, barHeight)
    
    -- Draw percentage
    love.graphics.setColor(1, 1, 1)
    love.graphics.setFont(love.graphics.newFont(10))
    love.graphics.print(math.floor(progress * 100) .. "%", self.x - 15, barY - 15)
end

function Building:startRecruitment()
    self.recruitmentTime = 10  -- 10 seconds to recruit
    self.recruitmentProgress = 0
end

function Building:completeRecruitment()
    -- Override in guild classes
end

function Building:startUpgrade()
    self.upgradeTime = 15  -- 15 seconds to upgrade
    self.upgradeProgress = 0
end

function Building:completeUpgrade()
    -- Override in specific building classes
end

return Building