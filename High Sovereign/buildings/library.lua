-- buildings/library.lua - Fixed with proper level properties
local Building = require('buildings/building')
local Library = setmetatable({}, Building)
Library.__index = Library

function Library.new(x, y)
    local self = setmetatable(Building.new(x, y, 40, 40, {0.9, 0.9, 0.9}, "library"), Library)
    self.cost = 300
    self.level = 1
    self.maxLevel = 1  -- Library doesn't have traditional levels, it researches upgrades
    self.researchedUpgrades = {}
    self.availableUpgrades = {
        {name = "Improved Cultivation", cost = 200, description = "Increases all building income by 50%"},
        {name = "Advanced Rolling", cost = 250, description = "Joint Rollers deal 30% more damage"},
        {name = "Mystical Insights", cost = 300, description = "Psilocyber-Stoners abilities recharge faster"}
    }
    self.upgradeCost = 0  -- No direct upgrade, researches individual techs
    return self
end

function Library:researchUpgrade(index)
    if not self:canFunction() then
        require('game'):addMessage("Cannot research - library is destroyed!")
        return false
    end
    
    local upgrade = self.availableUpgrades[index]
    if upgrade and not self.researchedUpgrades[upgrade.name] then
        if require('game').spendCoins(upgrade.cost) then
            -- Apply the upgrade effect
            if upgrade.name == "Improved Cultivation" then
                for _, building in ipairs(require('game').getBuildings()) do
                    if building.income then
                        building.income = building.income * 1.5
                    end
                end
            elseif upgrade.name == "Advanced Rolling" then
                for _, hero in ipairs(require('game').getHeroes()) do
                    if hero.type == "joint_roller" then
                        hero.attackPower = hero.attackPower * 1.3
                    end
                end
            elseif upgrade.name == "Mystical Insights" then
                for _, hero in ipairs(require('game').getHeroes()) do
                    if hero.type == "psilocyber_stoner" then
                        if hero.abilityCooldown then
                            hero.abilityCooldown = hero.abilityCooldown * 0.7
                        end
                    end
                end
            end
            
            self.researchedUpgrades[upgrade.name] = true
            table.remove(self.availableUpgrades, index)
            require('game'):addMessage("Research complete: " .. upgrade.name)
            return true
        else
            require('game'):addMessage("Not enough Kush Coins for research!")
            return false
        end
    end
    return false
end

function Library:draw()
    Building.draw(self)
    
    if not self.isDestroyed then
        -- Draw book shelves
        love.graphics.setColor(0.2, 0.2, 0.6)
        for i = -1, 1 do
            love.graphics.rectangle("fill", self.x - 15, self.y + i*10 - 5, 30, 3)
        end
        
        -- Draw scroll icon
        love.graphics.setColor(0.9, 0.8, 0.6)
        love.graphics.circle("fill", self.x, self.y, 8)
        love.graphics.setColor(0.6, 0.5, 0.3)
        love.graphics.circle("line", self.x, self.y, 8)
        
        -- Show number of researches completed
        local researchCount = 0
        for _ in pairs(self.researchedUpgrades) do
            researchCount = researchCount + 1
        end
        
        if researchCount > 0 then
            love.graphics.setColor(0, 1, 0)
            love.graphics.setFont(love.graphics.newFont(10))
            love.graphics.print(researchCount .. " Researched", self.x - 30, self.y + 20)
        end
    end
end

return {
    new = Library.new
}