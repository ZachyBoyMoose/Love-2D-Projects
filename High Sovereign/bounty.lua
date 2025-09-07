-- bounty.lua - Enhanced bounty system with better visuals
local Bounty = {}

function Bounty.new(bountyType, x, y, reward, target)
    local self = {
        x = x,
        y = y,
        bountyType = bountyType, -- 'attack', 'explore', or 'defend'
        reward = reward,
        completed = false,
        acceptedBy = {},
        dangerLevel = 1,
        priority = 1,
        createdTime = love.timer.getTime(),
        expireTime = nil,
        target = target, -- Can be an enemy, building, or location
        floatOffset = 0,
        floatTime = 0
    }
    
    -- Set danger level and priority based on type
    if bountyType == 'attack' then
        self.dangerLevel = love.math.random(3, 8)
        self.priority = 2
        -- If target is specified, adjust danger based on target strength
        if target and target.hp then
            self.dangerLevel = math.min(10, math.floor(target.hp / 20))
        end
    elseif bountyType == 'explore' then
        self.dangerLevel = love.math.random(1, 5)
        self.priority = 1
    elseif bountyType == 'defend' then
        self.dangerLevel = love.math.random(4, 9)
        self.priority = 3
    end
    
    -- Adjust reward based on danger
    self.reward = reward + (self.dangerLevel * 5)
    
    function self:calculateAppeal(hero)
        local distance = math.sqrt((hero.x - self.x)^2 + (hero.y - self.y)^2)
        
        -- Base appeal calculation
        local appeal = (self.reward * hero.personality.greed) / (distance + 100)
        
        -- Modify by danger vs bravery
        local dangerMod = 1
        if self.dangerLevel > 5 then
            dangerMod = hero.personality.bravery
        elseif self.dangerLevel < 3 then
            dangerMod = 1.5 -- Easy bounties are more appealing
        end
        appeal = appeal * dangerMod
        
        -- Class preferences for different bounty types
        if hero.type == "indica_knight" and self.bountyType == "defend" then
            appeal = appeal * 2.0
        elseif hero.type == "sativa_scout" and self.bountyType == "explore" then
            appeal = appeal * 2.0
        elseif hero.type == "joint_roller" and self.bountyType == "attack" then
            appeal = appeal * 1.8
        elseif hero.type == "dabbler" and self.bountyType == "attack" then
            appeal = appeal * 1.5
        elseif hero.type == "psilocyber_stoner" and self.bountyType == "defend" then
            appeal = appeal * 1.6
        elseif hero.type == "high_priest" and self.bountyType == "defend" then
            appeal = appeal * 1.7
        elseif hero.type == "gnome_chomper" and self.bountyType == "attack" then
            appeal = appeal * 1.9
        end
        
        -- Heroes are less interested if many others have accepted
        appeal = appeal / (1 + #self.acceptedBy * 0.3)
        
        -- Urgency increases appeal over time
        local age = love.timer.getTime() - self.createdTime
        appeal = appeal * (1 + age / 60)
        
        -- Lazy heroes need more motivation
        appeal = appeal * (1.5 - hero.personality.laziness)
        
        -- Priority modifier
        appeal = appeal * self.priority
        
        return appeal
    end
    
    function self:evaluateRisk(hero)
        -- Calculate risk based on hero's power vs danger
        local heroPower = hero.level * hero.attackPower + hero.defense
        local riskRatio = self.dangerLevel * 10 / heroPower
        
        if riskRatio > 2 then
            return 0.3 -- Very risky
        elseif riskRatio > 1 then
            return 0.7 -- Moderate risk
        else
            return 1.0 -- Safe
        end
    end
    
    function self:accept(hero)
        -- Add hero to accepted list
        table.insert(self.acceptedBy, hero)
        hero.currentBounty = self
    end
    
    function self:complete(hero)
        self.completed = true
        
        -- Pay out reward to hero
        hero.money = hero.money + self.reward
        
        -- Give XP based on danger level
        hero:gainXP(self.dangerLevel * 20)
        
        -- Create floating text for reward
        table.insert(require('game').floatingTexts, {
            x = self.x,
            y = self.y,
            text = "+" .. self.reward .. " KC",
            color = {1, 1, 0},
            lifetime = 2,
            velocity = {0, -20}
        })
        
        -- Log the completion
        require('game'):addMessage(hero.name .. " completed " .. self.bountyType .. " bounty for " .. self.reward .. " KC")
    end
    
    function self:update(dt)
        -- Update floating animation
        self.floatTime = self.floatTime + dt
        self.floatOffset = math.sin(self.floatTime * 2) * 5
        
        -- Update position if following a target
        if self.target and self.target.x and self.target.y then
            self.x = self.target.x
            self.y = self.target.y
        end
    end
    
    function self:draw()
        -- Calculate draw position with floating effect
        local drawY = self.y + self.floatOffset - 30
        
        -- Draw bounty type background circle with pulsing
        local pulse = math.sin(love.timer.getTime() * self.priority) * 0.2 + 0.8
        
        -- Set color based on bounty type
        if self.bountyType == 'attack' then
            love.graphics.setColor(1 * pulse, 0, 0, 0.8)
        elseif self.bountyType == 'explore' then
            love.graphics.setColor(1 * pulse, 1 * pulse, 0, 0.8)
        elseif self.bountyType == 'defend' then
            love.graphics.setColor(0, 0, 1 * pulse, 0.8)
        end
        
        -- Draw circular background
        love.graphics.circle("fill", self.x, drawY, 20)
        
        -- Draw border
        love.graphics.setColor(1, 1, 1, 0.9)
        love.graphics.setLineWidth(2)
        love.graphics.circle("line", self.x, drawY, 20)
        love.graphics.setLineWidth(1)
        
        -- Draw bounty type icon
        love.graphics.setColor(1, 1, 1)
        love.graphics.setFont(love.graphics.newFont(16))
        local icon = "?"
        if self.bountyType == 'attack' then
            icon = "⚔"
        elseif self.bountyType == 'explore' then
            icon = "?"
        elseif self.bountyType == 'defend' then
            icon = "⛨"
        end
        love.graphics.print(icon, self.x - 8, drawY - 10)
        
        -- Draw reward amount below
        love.graphics.setColor(1, 1, 0)
        love.graphics.setFont(love.graphics.newFont(12))
        love.graphics.print(self.reward .. " KC", self.x - 20, drawY + 25)
        
        -- Draw danger indicator (skulls)
        love.graphics.setColor(1, 0.5, 0)
        love.graphics.setFont(love.graphics.newFont(10))
        local dangerSymbols = ""
        for i = 1, math.min(math.floor(self.dangerLevel / 3), 3) do
            dangerSymbols = dangerSymbols .. "☠"
        end
        if dangerSymbols ~= "" then
            love.graphics.print(dangerSymbols, self.x - (#dangerSymbols * 3), drawY + 40)
        end
        
        -- Draw accepted hero count
        if #self.acceptedBy > 0 then
            love.graphics.setColor(0, 1, 0)
            love.graphics.setFont(love.graphics.newFont(10))
            love.graphics.print(#self.acceptedBy .. " heroes", self.x - 20, drawY - 35)
        end
        
        -- Draw timer if expiring soon
        if self.expireTime then
            local timeLeft = self.expireTime - love.timer.getTime()
            if timeLeft < 30 then
                love.graphics.setColor(1, 0, 0)
                love.graphics.setFont(love.graphics.newFont(10))
                love.graphics.print(math.floor(timeLeft) .. "s", self.x - 10, drawY + 55)
            end
        end
        
        -- Draw line to target if exists
        if self.target and self.target ~= self then
            love.graphics.setColor(1, 1, 1, 0.2)
            love.graphics.setLineWidth(1)
            love.graphics.line(self.x, self.y, self.x, drawY)
        end
    end
    
    return self
end

return {
    new = Bounty.new
}