-- heroes/joint_roller.lua - Elf class implementation
local Hero = require('heroes/hero')
local JointRoller = setmetatable({}, Hero)
JointRoller.__index = JointRoller

function JointRoller.new(x, y)
    local self = setmetatable(Hero.new(x, y, 10, 25, {0.8, 0.7, 0.6}, "joint_roller"), JointRoller)
    self.attackPower = 10
    self.defense = 4
    self.speed = 90 -- Very fast
    self.attackRange = 120 -- Ranged attacker
    self.projectiles = {}
    
    -- Elves are swift and wise
    self.personality.wisdom = math.min(1.0, self.personality.wisdom + 0.2)
    self.personality.laziness = self.personality.laziness * 0.5 -- Less lazy
    
    return self
end

function JointRoller:update(dt)
    Hero.update(self, dt)
    
    -- Update projectiles
    for i = #self.projectiles, 1, -1 do
        local proj = self.projectiles[i]
        if proj:update(dt) then
            table.remove(self.projectiles, i)
        end
    end
    
    -- Maintain distance from targets
    if self.combatTarget and self:distanceTo(self.combatTarget) < 60 then
        -- Hit and run tactics
        local dx = self.x - self.combatTarget.x
        local dy = self.y - self.combatTarget.y
        local dist = math.sqrt(dx*dx + dy*dy)
        if dist > 0 then
            self.x = self.x + (dx/dist) * self.speed * dt * 0.7
            self.y = self.y + (dy/dist) * self.speed * dt * 0.7
        end
    end
    
    -- Check for Volley ability on high-health targets
    if self.combatTarget and self.combatTarget.hp > 80 and self.abilityCooldown <= 0 then
        self:activateVolley()
    end
end

function JointRoller:fight(dt)
    if not self.combatTarget or not self.combatTarget.isAlive then
        self.combatTarget = nil
        self.state = "idle"
        return
    end
    
    local distance = self:distanceTo(self.combatTarget)
    
    -- Stay at range
    if distance > self.attackRange then
        self:moveTowards(self.combatTarget.x, self.combatTarget.y, dt)
    elseif distance < 60 then
        -- Too close, back away
        local dx = self.x - self.combatTarget.x
        local dy = self.y - self.combatTarget.y
        local dist = math.sqrt(dx*dx + dy*dy)
        if dist > 0 then
            self.x = self.x + (dx/dist) * self.speed * dt
            self.y = self.y + (dy/dist) * self.speed * dt
        end
    else
        -- Perfect range, attack
        self.attackTimer = self.attackTimer - dt
        if self.attackTimer <= 0 then
            self:fireProjectile()
            self.attackTimer = 1.0
        end
    end
end

function JointRoller:fireProjectile()
    local projectile = {
        x = self.x,
        y = self.y,
        target = self.combatTarget,
        speed = 200,
        damage = self.attackPower,
        update = function(self, dt)
            if not self.target or not self.target.isAlive then
                return true
            end
            
            local dx = self.target.x - self.x
            local dy = self.target.y - self.y
            local dist = math.sqrt(dx*dx + dy*dy)
            
            if dist < 10 then
                self.target:takeDamage(self.damage)
                return true
            else
                self.x = self.x + (dx/dist) * self.speed * dt
                self.y = self.y + (dy/dist) * self.speed * dt
                return false
            end
        end,
        draw = function(self)
            love.graphics.setColor(0.8, 0.7, 0.6)
            love.graphics.rectangle("fill", self.x - 2, self.y - 2, 4, 4)
        end
    }
    
    table.insert(self.projectiles, projectile)
end

function JointRoller:activateVolley()
    -- Fire 3 projectiles
    for i = 1, 3 do
        self:fireProjectile()
    end
    
    -- Visual effect
    table.insert(require('game').floatingTexts, {
        x = self.x,
        y = self.y - 20,
        text = "VOLLEY!",
        color = {0.8, 0.7, 0.6},
        lifetime = 1.5,
        velocity = {0, -20}
    })
    
    self.abilityCooldown = 15
end

function JointRoller:draw()
    -- Very tall, thin light-brown rectangle
    love.graphics.setColor(self.color[1], self.color[2], self.color[3])
    love.graphics.rectangle("fill", self.x - self.width/2, self.y - self.height/2, self.width, self.height)
    
    -- Draw projectiles
    for _, proj in ipairs(self.projectiles) do
        proj:draw()
    end
    
    -- Draw bow indicator
    love.graphics.setColor(0.6, 0.5, 0.4)
    love.graphics.arc("line", "open", self.x, self.y, 8, -math.pi/4, math.pi/4)
    
    Hero.draw(self)
end

return JointRoller