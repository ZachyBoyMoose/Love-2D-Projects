-- units/weedling.lua - Enhanced Weedling with repair abilities
local Entity = require('entity')
local Weedling = setmetatable({}, Entity)
Weedling.__index = Weedling

function Weedling.new(x, y)
    local self = setmetatable(Entity.new(x, y, 10, 10), Weedling)
    self.color = {0.5, 0.35, 0.2}
    self.state = "idle" -- idle, moving, building, repairing
    self.targetConstruction = nil
    self.targetRepair = nil
    self.hp = 20
    self.maxHp = 20
    self.speed = 60
    self.buildSpeed = 1  -- Construction points per second
    
    return self
end

function Weedling:update(dt)
    if not self.isAlive then return end
    
    if self.state == "idle" then
        -- Look for construction work first
        local construction = self:findConstruction()
        if construction then
            self:assignConstruction(construction)
        else
            -- Look for buildings that need repair
            local damagedBuilding = self:findDamagedBuilding()
            if damagedBuilding then
                self:assignRepair(damagedBuilding)
            else
                -- Wander slowly if no work
                self:wander(dt)
            end
        end
    elseif self.state == "moving" then
        if self.targetConstruction then
            if self:moveTowards(self.targetConstruction.building.x, self.targetConstruction.building.y, dt) then
                self.state = "building"
            end
        elseif self.targetRepair then
            if self:moveTowards(self.targetRepair.x, self.targetRepair.y, dt) then
                -- Try to start repair
                if self.targetRepair:startRepair(self) then
                    self.state = "repairing"
                else
                    -- Can't afford repair, go back to idle
                    self.targetRepair = nil
                    self.state = "idle"
                end
            end
        end
    elseif self.state == "building" then
        if self.targetConstruction then
            -- Building is handled in the construction update
            -- Just stay in position
        else
            self.state = "idle"
        end
    elseif self.state == "repairing" then
        if self.targetRepair and self.targetRepair.beingRepaired then
            self.targetRepair:updateRepair(dt)
            
            -- Check if repair is complete
            if not self.targetRepair.beingRepaired then
                self.targetRepair = nil
                self.state = "idle"
            end
        else
            self.state = "idle"
        end
    end
end

function Weedling:findConstruction()
    for _, construction in ipairs(require('game').buildingInProgress) do
        if not construction.assignedWeedling then
            return construction
        end
    end
    return nil
end

function Weedling:findDamagedBuilding()
    local buildings = require('game').getBuildings()
    local nearestDamaged = nil
    local minDistance = math.huge
    
    for _, building in ipairs(buildings) do
        if building.isDestroyed and not building.beingRepaired then
            local dist = self:distanceTo(building)
            if dist < minDistance then
                minDistance = dist
                nearestDamaged = building
            end
        end
    end
    
    -- Only consider buildings within reasonable range
    if nearestDamaged and minDistance < 500 then
        return nearestDamaged
    end
    
    return nil
end

function Weedling:assignConstruction(construction)
    self.targetConstruction = construction
    construction.assignedWeedling = self
    self.state = "moving"
end

function Weedling:assignRepair(building)
    self.targetRepair = building
    self.state = "moving"
end

function Weedling:wander(dt)
    if not self.wanderTarget or self:moveTowards(self.wanderTarget.x, self.wanderTarget.y, dt * 0.5) then
        self.wanderTarget = {
            x = self.x + love.math.random(-100, 100),
            y = self.y + love.math.random(-100, 100)
        }
    end
end

function Weedling:takeDamage(amount)
    Entity.takeDamage(self, amount)
    
    if not self.isAlive then
        -- Remove from construction if assigned
        if self.targetConstruction then
            self.targetConstruction.assignedWeedling = nil
        end
        
        -- Stop repair if in progress
        if self.targetRepair and self.targetRepair.beingRepaired then
            self.targetRepair.beingRepaired = false
            require('game'):addMessage("Weedling killed! Repair interrupted!")
        end
        
        -- Remove from game's weedling list
        local game = require('game')
        for i, weedling in ipairs(game.weedlings) do
            if weedling == self then
                table.remove(game.weedlings, i)
                break
            end
        end
    end
end

function Weedling:draw()
    if not self.isAlive then return end
    
    -- Draw weedling body
    love.graphics.setColor(self.color[1], self.color[2], self.color[3])
    love.graphics.circle("fill", self.x, self.y, self.width/2)
    
    -- Draw state indicator
    love.graphics.setColor(1, 1, 1)
    love.graphics.setFont(love.graphics.newFont(8))
    local stateIcon = ""
    if self.state == "building" then
        stateIcon = "🔨"
        love.graphics.print("B", self.x - 3, self.y - 15)
    elseif self.state == "repairing" then
        stateIcon = "🔧"
        love.graphics.print("R", self.x - 3, self.y - 15)
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

return Weedling