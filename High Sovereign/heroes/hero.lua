local Entity = require('entity')
local Hero = setmetatable({}, Entity)
Hero.__index = Hero

function Hero.new(x, y, width, height, color, heroType)
    local self = setmetatable(Entity.new(x, y, width, height), Hero)
    self.color = color
    self.type = heroType
    self.state = "idle"
    self.money = 0
    self.equipmentLevel = 1
    self.focus = 100
    self.maxFocus = 100
    self.attackPower = 10
    self.defense = 5
    self.sightRadius = 8
    self.homeGuild = nil
    self.target = nil
    self.abilityCooldown = 0
    self.abilityActive = false
    self.level = 1
    self.xp = 0
    self.xpForNextLevel = 100
    self.currentBounty = nil
    self.fleeTarget = nil
    self.lastRestTime = 0
    self.lastShopTime = 0
    self.combatTarget = nil
    self.attackTimer = 0
    self.motivationThreshold = 0.5
    
    -- Generate unique personality
    self.personality = {
        greed = love.math.random() * 0.8 + 0.2,
        bravery = love.math.random() * 0.8 + 0.2,
        laziness = love.math.random() * 0.5,
        wisdom = love.math.random() * 0.8 + 0.2
    }
    
    -- Generate hero name
    local prefixes = {"Brave", "Swift", "Mighty", "Wise", "Dank", "Chill", "High", "Lit", "Blazed", "Toasted"}
    local suffixes = {"Blazer", "Toker", "Roller", "Dabber", "Chief", "Puffer", "Smoker", "Burner", "Sparker"}
    self.name = prefixes[love.math.random(#prefixes)] .. " " .. suffixes[love.math.random(#suffixes)]
    
    -- Personality affects base stats
    self.attackPower = self.attackPower * (0.8 + self.personality.bravery * 0.4)
    self.defense = self.defense * (0.8 + self.personality.wisdom * 0.4)
    self.speed = self.speed * (1.5 - self.personality.laziness)
    
    return self
end

function Hero:update(dt)
    if not self.isAlive then return end
    
    -- Update ability cooldown
    if self.abilityCooldown > 0 then
        self.abilityCooldown = self.abilityCooldown - dt
    end
    
    -- Decrease focus over time (fatigue)
    self.focus = math.max(0, self.focus - dt * 2)
    
    -- State machine with personality-driven decisions
    if self.state == "idle" then
        self:makeDecision()
    elseif self.state == "wandering" then
        self:wander(dt)
    elseif self.state == "pursuing_bounty" then
        self:pursueBounty(dt)
    elseif self.state == "fleeing" then
        self:flee(dt)
    elseif self.state == "resting" then
        self:rest(dt)
    elseif self.state == "shopping" then
        self:shop(dt)
    elseif self.state == "fighting" then
        self:fight(dt)
    elseif self.state == "returning_home" then
        self:returnHome(dt)
    elseif self.state == "exploring" then
        self:explore(dt)
    end
    
    -- Check for critical situations
    self:checkCriticalStatus()
end

function Hero:makeDecision()
    -- Priority system for decision making
    
    -- 1. Health critical - flee or rest
    if self.hp < self.maxHp * 0.3 then
        if self.personality.bravery < 0.4 then
            self:startFleeing()
            return
        elseif self.focus < 30 then
            self:findRestPlace()
            return
        end
    end
    
    -- 2. Low focus - need rest
    if self.focus < 30 then
        self:findRestPlace()
        return
    end
    
    -- 3. Has money - maybe shop
    if self.money >= 50 and love.timer.getTime() - self.lastShopTime > 60 then
        if love.math.random() < self.personality.greed then
            self:findShop()
            return
        end
    end
    
    -- 4. Look for bounties
    local bestBounty = self:findBestBounty()
    if bestBounty then
        self:acceptBounty(bestBounty)
        return
    end
    
    -- 5. Look for enemies to fight (brave heroes)
    if self.personality.bravery > 0.6 then
        local enemy = self:findNearbyEnemy()
        if enemy then
            self.combatTarget = enemy
            self.state = "fighting"
            return
        end
    end
    
    -- 6. Return to guild if nothing to do
    if self.homeGuild and love.math.random() < 0.3 then
        self.state = "returning_home"
        return
    end
    
    -- 7. Default to exploring
    self.state = "exploring"
end

function Hero:findBestBounty()
    local bounties = require('game').getBounties()
    local bestBounty = nil
    local bestAppeal = self.motivationThreshold
    
    for _, bounty in ipairs(bounties) do
        if not bounty.completed then
            local appeal = bounty:calculateAppeal(self)
            
            -- Check if we're brave enough for dangerous bounties
            if bounty.dangerLevel > 5 and self.personality.bravery < 0.5 then
                appeal = appeal * 0.3
            end
            
            if appeal > bestAppeal then
                bestAppeal = appeal
                bestBounty = bounty
            end
        end
    end
    
    return bestBounty
end

function Hero:acceptBounty(bounty)
    bounty:accept(self)
    self.currentBounty = bounty
    self.state = "pursuing_bounty"
    
    -- Announce acceptance
    require('game'):addMessage(self.name .. " accepted " .. bounty.bountyType .. " bounty")
end

function Hero:pursueBounty(dt)
    if not self.currentBounty or self.currentBounty.completed then
        self.currentBounty = nil
        self.state = "idle"
        return
    end
    
    -- Move towards bounty location
    if self:moveTowards(self.currentBounty.x, self.currentBounty.y, dt) then
        -- Reached bounty location
        if self.currentBounty.bountyType == "explore" then
            -- Explore area
            self:exploreArea()
            self.currentBounty:complete(self)
        elseif self.currentBounty.bountyType == "attack" then
            -- Look for enemies to attack
            local enemy = self:findNearbyEnemy()
            if enemy then
                self.combatTarget = enemy
                self.state = "fighting"
            else
                -- No enemies, complete bounty
                self.currentBounty:complete(self)
            end
        elseif self.currentBounty.bountyType == "defend" then
            -- Defend area for some time
            if not self.defendTimer then
                self.defendTimer = 10
            end
            self.defendTimer = self.defendTimer - dt
            
            -- Attack any nearby enemies
            local enemy = self:findNearbyEnemy()
            if enemy then
                self.combatTarget = enemy
                self.state = "fighting"
                return
            end
            
            if self.defendTimer <= 0 then
                self.currentBounty:complete(self)
                self.defendTimer = nil
            end
        end
        
        if self.currentBounty and self.currentBounty.completed then
            self.currentBounty = nil
            self.state = "idle"
        end
    end
    
    -- Check for dangers along the way
    if love.math.random() < 0.01 then
        local enemy = self:findNearbyEnemy()
        if enemy and self:distanceTo(enemy) < 50 then
            if self.personality.bravery > 0.3 then
                self.combatTarget = enemy
                self.state = "fighting"
            else
                self:startFleeing()
            end
        end
    end
end

function Hero:explore(dt)
    -- Wander around exploring the map
    if not self.exploreTarget or self:distanceTo(self.exploreTarget) < 20 then
        -- Pick a new exploration target
        local angle = love.math.random() * math.pi * 2
        local distance = 100 + love.math.random() * 200
        self.exploreTarget = {
            x = self.x + math.cos(angle) * distance,
            y = self.y + math.sin(angle) * distance
        }
    end
    
    self:moveTowards(self.exploreTarget.x, self.exploreTarget.y, dt)
    
    -- Chance to stop exploring and make new decision
    if love.math.random() < 0.005 then
        self.state = "idle"
    end
end

function Hero:exploreArea()
    -- Reveal fog of war in the area
    local game = require('game')
    local radius = 10
    local centerX, centerY = math.floor(self.x / 32), math.floor(self.y / 32)
    
    for dx = -radius, radius do
        for dy = -radius, radius do
            if dx*dx + dy*dy <= radius*radius then
                local x, y = centerX + dx, centerY + dy
                if x >= 1 and x <= #game.fogOfWar and y >= 1 and y <= #game.fogOfWar[1] then
                    game.fogOfWar[x][y] = false
                end
            end
        end
    end
end

function Hero:fight(dt)
    if not self.combatTarget or not self.combatTarget.isAlive then
        -- Combat ended
        if self.combatTarget and not self.combatTarget.isAlive then
            -- Victory! Gain XP
            self:gainXP(30)
            
            -- Loot money
            local loot = love.math.random(5, 20)
            self.money = self.money + loot
            
            -- Complete bounty if applicable
            if self.currentBounty and self.currentBounty.bountyType == "attack" then
                self.currentBounty:complete(self)
                self.currentBounty = nil
            end
        end
        
        self.combatTarget = nil
        self.state = "idle"
        return
    end
    
    local distance = self:distanceTo(self.combatTarget)
    
    -- Get in range
    if distance > 30 then
        self:moveTowards(self.combatTarget.x, self.combatTarget.y, dt)
    else
        -- Attack
        self.attackTimer = self.attackTimer - dt
        if self.attackTimer <= 0 then
            local damage = self.attackPower * (0.8 + love.math.random() * 0.4)
            self.combatTarget:takeDamage(damage)
            self.attackTimer = 1.0 / (1 + self.level * 0.1) -- Attack speed increases with level
            
            -- Visual feedback
            table.insert(require('game').floatingTexts, {
                x = self.combatTarget.x,
                y = self.combatTarget.y,
                text = "-" .. math.floor(damage),
                color = {1, 0, 0},
                lifetime = 1,
                velocity = {love.math.random(-20, 20), -30}
            })
        end
    end
    
    -- Take damage from enemy
    if self.combatTarget.attackPower and distance < 40 then
        if love.math.random() < dt then -- Chance to be hit
            local enemyDamage = self.combatTarget.attackPower * (0.8 + love.math.random() * 0.4)
            local reducedDamage = enemyDamage * (1 - self.defense / 100)
            self:takeDamage(reducedDamage)
        end
    end
    
    -- Check if should flee
    if self.hp < self.maxHp * 0.2 and self.personality.bravery < 0.6 then
        self:startFleeing()
    end
end

function Hero:startFleeing()
    self.state = "fleeing"
    self.fleeTarget = self.homeGuild or require('game').palace
    require('game'):addMessage(self.name .. " is fleeing!")
end

function Hero:flee(dt)
    if not self.fleeTarget then
        self.state = "idle"
        return
    end
    
    -- Move away from danger quickly
    local fleeSpeed = self.speed * 1.5 -- Panic speed boost
    local dx = self.fleeTarget.x - self.x
    local dy = self.fleeTarget.y - self.y
    local distance = math.sqrt(dx*dx + dy*dy)
    
    if distance > 5 then
        self.x = self.x + (dx / distance) * fleeSpeed * dt
        self.y = self.y + (dy / distance) * fleeSpeed * dt
    else
        -- Reached safety
        self.state = "resting"
        self.fleeTarget = nil
    end
end

function Hero:returnHome(dt)
    if not self.homeGuild then
        self.state = "idle"
        return
    end
    
    if self:moveTowards(self.homeGuild.x, self.homeGuild.y, dt) then
        -- At home, rest a bit
        self.state = "resting"
        self.restDuration = 5
    end
end

function Hero:findRestPlace()
    -- Find the nearest chill lounge
    local nearestLounge = nil
    local minDistance = math.huge
    
    for _, building in ipairs(require('game').getBuildings()) do
        if building.type == "chill_lounge" and building.isBuilt then
            local distance = self:distanceTo(building)
            if distance < minDistance then
                minDistance = distance
                nearestLounge = building
            end
        end
    end
    
    -- If no lounge, rest at guild
    self.restTarget = nearestLounge or self.homeGuild
    if self.restTarget then
        self.state = "resting"
    else
        self.state = "idle"
    end
end

function Hero:rest(dt)
    local restLocation = self.restTarget or self.homeGuild
    
    if not restLocation then
        self.state = "idle"
        return
    end
    
    if self:distanceTo(restLocation) > 30 then
        self:moveTowards(restLocation.x, restLocation.y, dt)
    else
        -- Resting
        self.focus = math.min(self.focus + 20 * dt, self.maxFocus)
        self.hp = math.min(self.hp + 10 * dt, self.maxHp)
        
        -- Pay for services
        if restLocation.type == "chill_lounge" then
            local cost = 2 * dt
            if self.money >= cost then
                self.money = self.money - cost
                require('game').addCoins(cost)
            end
        end
        
        -- Done resting?
        if self.focus >= self.maxFocus * 0.9 and self.hp >= self.maxHp * 0.8 then
            self.state = "idle"
            self.restTarget = nil
            self.lastRestTime = love.timer.getTime()
        end
    end
end

function Hero:findShop()
    local nearestShop = nil
    local minDistance = math.huge
    
    for _, building in ipairs(require('game').getBuildings()) do
        if building.type == "dispensary" and building.isBuilt then
            local distance = self:distanceTo(building)
            if distance < minDistance then
                minDistance = distance
                nearestShop = building
            end
        end
    end
    
    if nearestShop then
        self.shopTarget = nearestShop
        self.state = "shopping"
    else
        self.state = "idle"
    end
end

function Hero:shop(dt)
    if not self.shopTarget then
        self.state = "idle"
        return
    end
    
    if self:distanceTo(self.shopTarget) > 30 then
        self:moveTowards(self.shopTarget.x, self.shopTarget.y, dt)
    else
        -- Buy equipment upgrades
        local costs = {50, 100, 200, 400}
        local cost = costs[math.min(self.equipmentLevel, #costs)]
        
        if self.money >= cost then
            self.money = self.money - cost
            self.equipmentLevel = self.equipmentLevel + 1
            self.attackPower = self.attackPower + 5
            self.defense = self.defense + 3
            self.maxHp = self.maxHp + 20
            require('game').addCoins(cost)
            
            require('game'):addMessage(self.name .. " bought equipment (Level " .. self.equipmentLevel .. ")")
        end
        
        self.state = "idle"
        self.shopTarget = nil
        self.lastShopTime = love.timer.getTime()
    end
end

function Hero:findNearbyEnemy()
    local enemies = require('game').getEnemies()
    local nearestEnemy = nil
    local minDistance = self.sightRadius * 32
    
    for _, enemy in ipairs(enemies) do
        if enemy.isAlive then
            local distance = self:distanceTo(enemy)
            if distance < minDistance then
                minDistance = distance
                nearestEnemy = enemy
            end
        end
    end
    
    return nearestEnemy
end

function Hero:checkCriticalStatus()
    -- Override current action if critical
    if self.hp < self.maxHp * 0.15 and self.state ~= "fleeing" and self.state ~= "resting" then
        self:startFleeing()
    end
end

function Hero:takeDamage(amount)
    Entity.takeDamage(self, amount)
    
    -- Create floating damage text
    table.insert(require('game').floatingTexts, {
        x = self.x,
        y = self.y,
        text = "-" .. math.floor(amount),
        color = {1, 0, 0},
        lifetime = 1,
        velocity = {love.math.random(-20, 20), -30}
    })
    
    -- Chance to flee based on personality
    if self.hp < self.maxHp * 0.3 and self.personality.bravery < 0.5 then
        if self.state ~= "fleeing" then
            self:startFleeing()
        end
    end
end

function Hero:gainXP(amount)
    self.xp = self.xp + amount
    
    -- Visual feedback
    table.insert(require('game').floatingTexts, {
        x = self.x,
        y = self.y - 10,
        text = "+" .. amount .. " XP",
        color = {1, 1, 1},
        lifetime = 1.5,
        velocity = {0, -15}
    })
    
    if self.xp >= self.xpForNextLevel then
        self:levelUp()
    end
end

function Hero:levelUp()
    self.level = self.level + 1
    self.xp = self.xp - self.xpForNextLevel
    self.xpForNextLevel = math.floor(self.xpForNextLevel * 1.5)
    
    -- Increase stats
    local oldMaxHp = self.maxHp
    self.maxHp = self.maxHp * 1.2
    self.hp = self.hp + (self.maxHp - oldMaxHp)
    self.maxFocus = self.maxFocus * 1.15
    self.focus = self.maxFocus
    self.attackPower = self.attackPower * 1.15
    self.defense = self.defense * 1.1
    
    -- Visual feedback
    table.insert(require('game').floatingTexts, {
        x = self.x,
        y = self.y - 20,
        text = "LEVEL UP!",
        color = {1, 1, 0},
        lifetime = 3,
        velocity = {0, -10}
    })
    
    require('game'):addMessage(self.name .. " reached level " .. self.level .. "!")
end

function Hero:wander(dt)
    -- Simple wandering with personality influence
    if not self.wanderTarget or self:distanceTo(self.wanderTarget) < 10 then
        -- Lazy heroes wander less
        if love.math.random() > self.personality.laziness then
            local range = 200 * (1 - self.personality.laziness)
            self.wanderTarget = {
                x = self.x + love.math.random(-range, range),
                y = self.y + love.math.random(-range, range)
            }
        else
            -- Lazy hero might just stand still
            self.wanderTarget = {x = self.x, y = self.y}
        end
    end
    
    self:moveTowards(self.wanderTarget.x, self.wanderTarget.y, dt)
    
    -- Check for opportunities while wandering
    if love.math.random() < 0.01 then
        self.state = "idle"
    end
end

function Hero:draw()
    if not self.isAlive then return end
    
    -- Draw hero body
    love.graphics.setColor(self.color[1], self.color[2], self.color[3])
    love.graphics.rectangle("fill", self.x - self.width/2, self.y - self.height/2, self.width, self.height)
    
    -- Draw personality indicator (small colored dot)
    if self.personality.bravery > 0.7 then
        love.graphics.setColor(1, 0, 0) -- Red for brave
    elseif self.personality.greed > 0.7 then
        love.graphics.setColor(1, 1, 0) -- Yellow for greedy
    else
        love.graphics.setColor(0.5, 0.5, 0.5) -- Gray for balanced
    end
    love.graphics.circle("fill", self.x, self.y - self.height/2 - 5, 2)
    
    -- Draw health bar
    local barWidth = 30
    local barHeight = 4
    love.graphics.setColor(0, 0, 0)
    love.graphics.rectangle("fill", self.x - barWidth/2 - 1, self.y - self.height/2 - 11, barWidth + 2, barHeight + 2)
    
    love.graphics.setColor(1, 0, 0)
    love.graphics.rectangle("fill", self.x - barWidth/2, self.y - self.height/2 - 10, barWidth, barHeight)
    love.graphics.setColor(0, 1, 0)
    love.graphics.rectangle("fill", self.x - barWidth/2, self.y - self.height/2 - 10, barWidth * (self.hp / self.maxHp), barHeight)
    
    -- Draw focus bar
    love.graphics.setColor(0, 0, 1)
    love.graphics.rectangle("fill", self.x - barWidth/2, self.y - self.height/2 - 16, barWidth * (self.focus / self.maxFocus), 2)
    
    -- Draw level
    love.graphics.setColor(1, 1, 1)
    love.graphics.print(tostring(self.level), self.x - 5, self.y - self.height/2 - 25)
    
    -- Draw state indicator
    love.graphics.setColor(0.8, 0.8, 0.8)
    local stateText = ""
    if self.state == "fighting" then
        stateText = "⚔"
    elseif self.state == "fleeing" then
        stateText = "!"
    elseif self.state == "resting" then
        stateText = "z"
    elseif self.state == "shopping" then
        stateText = "$"
    elseif self.state == "pursuing_bounty" then
        stateText = "→"
    end
    love.graphics.print(stateText, self.x + self.width/2 + 2, self.y - 5)
end

return Hero