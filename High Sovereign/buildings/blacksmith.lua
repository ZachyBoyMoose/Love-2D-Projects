-- buildings/blacksmith.lua - Fixed with proper level properties
local Building = require('buildings/building')
local Blacksmith = setmetatable({}, Building)
Blacksmith.__index = Blacksmith

function Blacksmith.new(x, y)
    local self = setmetatable(Building.new(x, y, 40, 40, {0.3, 0.3, 0.3}, "blacksmith"), Blacksmith)
    self.cost = 250
    self.level = 1  -- Current research level
    self.maxLevel = 3  -- Maximum research level
    self.researchLevel = 1  -- Legacy property for compatibility
    self.maxResearchLevel = 3
    self.upgradeCost = 400
    return self
end

function Blacksmith:upgrade()
    if not self:canFunction() then
        require('game'):addMessage("Cannot upgrade - building is destroyed!")
        return false
    end
    
    if self.level >= self.maxLevel then
        require('game'):addMessage("Blacksmith is already at maximum level!")
        return false
    end
    
    if require('game').spendCoins(self.upgradeCost) then
        -- Start upgrade timer
        self:startUpgrade()
        require('game'):addMessage("Upgrading Blacksmith")
        return true
    else
        require('game'):addMessage("Not enough Kush Coins for upgrade!")
        return false
    end
end

function Blacksmith:completeUpgrade()
    self.level = self.level + 1
    self.researchLevel = self.level  -- Keep both in sync
    self.upgradeCost = math.floor(self.upgradeCost * 2)
    
    -- Apply global equipment upgrade to all heroes
    for _, hero in ipairs(require('game').getHeroes()) do
        hero.attackPower = hero.attackPower * 1.2
        hero.defense = hero.defense * 1.1
    end
    
    require('game'):addMessage("Blacksmith upgraded to level " .. self.level .. "! All heroes gain improved equipment!")
end

function Blacksmith:draw()
    Building.draw(self)
    
    if not self.isDestroyed then
        -- Draw forge/anvil
        love.graphics.setColor(1, 0.5, 0)
        love.graphics.rectangle("fill", self.x - 10, self.y - 10, 20, 20)
        
        -- Draw hammer icon
        love.graphics.setColor(0.2, 0.2, 0.2)
        love.graphics.rectangle("fill", self.x - 2, self.y - 15, 4, 12)
        love.graphics.rectangle("fill", self.x - 6, self.y - 15, 12, 4)
        
        -- Draw research tier
        love.graphics.setColor(1, 1, 1)
        love.graphics.setFont(love.graphics.newFont(10))
        love.graphics.print("Tier " .. self.level, self.x - 15, self.y - 25)
        
        -- Draw max level indicator
        if self.level >= self.maxLevel then
            love.graphics.setColor(0, 1, 0)
            love.graphics.setFont(love.graphics.newFont(8))
            love.graphics.print("MAX", self.x + 10, self.y - 25)
        end
    end
end

return {
    new = Blacksmith.new
}