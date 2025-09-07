-- boss.lua
-- Three unique bosses: Belchzebub, Mammon, and The Devil
boss = {
    active = false,
    type = "",
    x = 0,
    y = 0,
    width = 0,
    height = 0,
    health = 0,
    maxHealth = 0,
    state = "inactive",
    direction = -1,
    attackTimer = 0,
    points = 1000,
    knockback = 0,
    phase = 1,
    specialTimer = 0,
    animFrame = 0,
    animTimer = 0,
    minions = {},
    deathTimer = 0,
    hitTimer = 0,
}

function initBoss()
    boss.active = false
    boss.state = "inactive"
    boss.knockback = 0
    boss.phase = 1
    boss.minions = {}
end

function spawnBoss()
    if not stages or not stages[currentStage] then return end
    
    local stage = stages[currentStage]
    boss.active = true
    boss.state = "intro"
    boss.phase = 1
    boss.animFrame = 0
    boss.animTimer = 0
    boss.specialTimer = 0
    boss.minions = {}
    boss.deathTimer = 0
    boss.hitTimer = 0
    
    -- Lock camera for boss fight
    local camX = getCameraX() or stage.width - love.graphics.getWidth()
    lockCameraForWave(camX, camX + love.graphics.getWidth() / camera.scale)
    
    if currentStage == 1 then
        -- Belchzebub - Lord of Flies
        boss.type = "belchzebub"
        boss.width = 80
        boss.height = 120
        boss.health = 250
        boss.maxHealth = 250
        boss.attackDamage = 20
        boss.attackRange = 70
        boss.color = {0.4, 0.3, 0.2}
    elseif currentStage == 2 then
        -- Mammon - Money Mauler
        boss.type = "mammon"
        boss.width = 100
        boss.height = 110
        boss.health = 350
        boss.maxHealth = 350
        boss.attackDamage = 25
        boss.attackRange = 60
        boss.color = {0.9, 0.8, 0.2}
    elseif currentStage == 3 then
        -- The Devil
        boss.type = "devil"
        boss.width = 100
        boss.height = 140
        boss.health = 500
        boss.maxHealth = 500
        boss.attackDamage = 30
        boss.attackRange = 80
        boss.color = {0.9, 0.1, 0.1}
    end
    
    boss.x = stage.width - 400
    boss.y = stage.floorHeight - boss.height
    boss.direction = -1
    boss.attackTimer = 0
    
    -- Boss intro animation
    triggerCameraShake(10, 1)
end

function updateBoss(dt)
    if not boss.active or boss.state == "inactive" then
        return
    end
    
    -- Update animation
    boss.animTimer = boss.animTimer + dt
    if boss.animTimer > 0.1 then
        boss.animTimer = 0
        boss.animFrame = (boss.animFrame + 1) % 6
    end
    
    -- Update minions
    for i = #boss.minions, 1, -1 do
        local minion = boss.minions[i]
        if not minion.active then
            table.remove(boss.minions, i)
        end
    end
    
    -- Apply knockback
    if boss.knockback ~= 0 then
        boss.x = boss.x + boss.knockback
        boss.knockback = boss.knockback * 0.9
        if math.abs(boss.knockback) < 0.5 then
            boss.knockback = 0
        end
    end
    
    -- State handling
    if boss.state == "intro" then
        boss.specialTimer = boss.specialTimer + dt
        if boss.specialTimer > 2 then
            boss.state = "active"
            boss.specialTimer = 0
        end
    elseif boss.state == "dying" then
        boss.deathTimer = boss.deathTimer - dt
        if boss.deathTimer <= 0 then
            boss.active = false
            createBossDeathEffect()
        end
    elseif boss.state == "hit" then
        boss.hitTimer = boss.hitTimer - dt
        if boss.hitTimer <= 0 then
            boss.state = "active"
        end
    elseif boss.state == "attacking" then
        boss.attackTimer = boss.attackTimer - dt
        if boss.attackTimer <= 0 then
            boss.state = "active"
        end
    elseif boss.state == "special" then
        updateBossSpecial(dt)
    else
        -- Boss AI based on type and phase
        updateBossAI(dt)
    end
end

function updateBossAI(dt)
    local dx = player.x - boss.x
    local dy = player.y - boss.y
    local dist = math.sqrt(dx*dx + dy*dy)
    
    boss.direction = dx > 0 and 1 or -1
    
    if boss.type == "belchzebub" then
        updateBelchzebubAI(dt, dist)
    elseif boss.type == "mammon" then
        updateMammonAI(dt, dist)
    elseif boss.type == "devil" then
        updateDevilAI(dt, dist)
    end
end

function updateBelchzebubAI(dt, dist)
    -- Swarm Boxer pattern
    if boss.phase == 1 then
        -- Machine-gun jabs
        if dist < boss.attackRange and boss.attackTimer <= 0 then
            boss.state = "attacking"
            boss.attackTimer = 0.2
            boss.attackDamage = 15
        elseif dist > 100 then
            -- Move toward player
            local speed = 60
            boss.x = boss.x + (boss.direction * speed * dt)
        end
        
        -- Occasional dive-bomb
        if math.random() < 0.005 then
            boss.state = "special"
            boss.specialType = "divebomb"
            boss.specialTimer = 1
        end
    else
        -- Phase 2: Summon flies
        if #boss.minions < 2 and boss.specialTimer <= 0 then
            boss.state = "special"
            boss.specialType = "summon"
            boss.specialTimer = 2
        end
        
        -- Smoke cloud attack
        if dist < 150 and math.random() < 0.01 then
            boss.state = "special"
            boss.specialType = "smoke"
            boss.specialTimer = 1.5
        end
    end
    
    boss.attackTimer = boss.attackTimer - dt
    boss.specialTimer = boss.specialTimer - dt
end

function updateMammonAI(dt, dist)
    -- Greedy Grappler pattern
    if boss.phase == 1 then
        -- Belly bump attack
        if dist < 80 and boss.attackTimer <= 0 then
            boss.state = "attacking"
            boss.attackTimer = 0.5
            boss.attackDamage = 20
            -- Push player back
            if checkAttackCollision(boss, player) then
                player.knockback = boss.direction * 15
            end
        elseif dist > 100 then
            -- Waddle toward player
            local speed = 40
            boss.x = boss.x + (boss.direction * speed * dt)
        end
        
        -- Coin shake attack
        if math.random() < 0.008 then
            boss.state = "special"
            boss.specialType = "coinshake"
            boss.specialTimer = 2
        end
    else
        -- Phase 2: Call security
        if #boss.minions < 2 and boss.specialTimer <= 0 then
            boss.state = "special"
            boss.specialType = "security"
            boss.specialTimer = 2
        end
        
        -- Coin slam uppercut
        if dist < boss.attackRange and boss.attackTimer <= 0 then
            boss.state = "attacking"
            boss.attackTimer = 0.8
            boss.attackDamage = 30
        end
    end
    
    boss.attackTimer = boss.attackTimer - dt
    boss.specialTimer = boss.specialTimer - dt
end

function updateDevilAI(dt, dist)
    -- Three-phase boss fight
    if boss.phase == 1 then
        -- Showboat Heavyweight - slow powerful attacks
        if dist < boss.attackRange and boss.attackTimer <= 0 then
            boss.state = "attacking"
            boss.attackTimer = 1.2
            boss.attackDamage = 35
            -- Wind-up telegraph
            triggerCameraShake(3, 0.2)
        elseif dist > 120 then
            local speed = 30
            boss.x = boss.x + (boss.direction * speed * dt)
        end
    elseif boss.phase == 2 then
        -- Raging Middleweight - faster combos
        if dist < boss.attackRange and boss.attackTimer <= 0 then
            boss.state = "attacking"
            boss.attackTimer = 0.6
            boss.attackDamage = 25
            -- Weave and hook combo
            boss.x = boss.x + boss.direction * 20
        elseif dist > 100 then
            local speed = 60
            boss.x = boss.x + (boss.direction * speed * dt)
        end
        
        -- Uppercut launcher
        if dist < 60 and math.random() < 0.01 then
            boss.state = "special"
            boss.specialType = "uppercut"
            boss.specialTimer = 0.8
        end
    else
        -- Phase 3: Desperation - pure fundamentals
        boss.color = {1, 0.8, 0.8} -- Glowing white-hot
        
        if dist < boss.attackRange and boss.attackTimer <= 0 then
            boss.state = "attacking"
            boss.attackTimer = 0.4
            boss.attackDamage = 20
            -- Rapid attacks
        end
        
        -- Constant pressure
        local speed = 80
        boss.x = boss.x + (boss.direction * speed * dt)
        
        -- Flame burst
        if math.random() < 0.015 then
            boss.state = "special"
            boss.specialType = "flameburst"
            boss.specialTimer = 1
        end
    end
    
    boss.attackTimer = boss.attackTimer - dt
    boss.specialTimer = boss.specialTimer - dt
end

function updateBossSpecial(dt)
    boss.specialTimer = boss.specialTimer - dt
    
    if boss.type == "belchzebub" then
        if boss.specialType == "divebomb" then
            -- Dive toward player
            boss.x = boss.x + boss.direction * 200 * dt
            boss.y = boss.y - 100 * dt
            
            if boss.specialTimer <= 0 then
                boss.state = "active"
                boss.y = getFloorHeight() - boss.height
                triggerCameraShake(10, 0.3)
            end
        elseif boss.specialType == "summon" then
            if boss.specialTimer <= 1 and #boss.minions < 2 then
                -- Spawn fly minions
                local minion = createEnemy("slugpug", boss.x - 50, boss.y)
                if minion then
                    minion.width = 25
                    minion.height = 40
                    minion.health = 15
                    table.insert(boss.minions, minion)
                end
            end
            if boss.specialTimer <= 0 then
                boss.state = "active"
            end
        elseif boss.specialType == "smoke" then
            -- Create smoke cloud effect
            createSmokeCloud(boss.x, boss.y)
            if boss.specialTimer <= 0 then
                boss.state = "active"
            end
        end
    elseif boss.type == "mammon" then
        if boss.specialType == "coinshake" then
            -- Shake coins out
            if math.floor(boss.specialTimer * 10) % 3 == 0 then
                createCoinProjectile(boss.x + boss.width/2, boss.y)
            end
            if boss.specialTimer <= 0 then
                boss.state = "active"
            end
        elseif boss.specialType == "security" then
            if boss.specialTimer <= 1 and #boss.minions < 2 then
                local minion = createEnemy("coin_creep", boss.x + 100, boss.y)
                if minion then
                    table.insert(boss.minions, minion)
                end
            end
            if boss.specialTimer <= 0 then
                boss.state = "active"
            end
        end
    elseif boss.type == "devil" then
        if boss.specialType == "uppercut" then
            boss.y = boss.y - 200 * dt
            if boss.specialTimer <= 0 then
                boss.state = "active"
                boss.y = getFloorHeight() - boss.height
                triggerCameraShake(15, 0.5)
            end
        elseif boss.specialType == "flameburst" then
            -- Create flame explosion
            createFlameRing(boss.x + boss.width/2, boss.y + boss.height/2)
            if boss.specialTimer <= 0 then
                boss.state = "active"
            end
        end
    end
end

function updateBossPhase()
    -- Check for phase transitions
    local healthPercent = boss.health / boss.maxHealth
    
    if boss.type == "belchzebub" then
        if healthPercent <= 0.5 and boss.phase == 1 then
            boss.phase = 2
            boss.state = "special"
            boss.specialType = "summon"
            boss.specialTimer = 2
            triggerCameraShake(10, 0.5)
        end
    elseif boss.type == "mammon" then
        if healthPercent <= 0.4 and boss.phase == 1 then
            boss.phase = 2
            boss.state = "special"
            boss.specialType = "security"
            boss.specialTimer = 2
            boss.color = {1, 0.9, 0.1} -- Turn more golden
        end
    elseif boss.type == "devil" then
        if healthPercent <= 0.66 and boss.phase == 1 then
            boss.phase = 2
            triggerCameraShake(10, 0.5)
        elseif healthPercent <= 0.33 and boss.phase == 2 then
            boss.phase = 3
            -- Halo burns off effect
            createHaloBurnEffect()
            triggerCameraShake(20, 1)
        end
    end
end

function drawBoss()
    if not boss.active or boss.state == "inactive" then
        return
    end
    
    love.graphics.push()
    love.graphics.translate(boss.x, boss.y)
    
    if boss.direction == -1 then
        love.graphics.scale(-1, 1)
        love.graphics.translate(-boss.width, 0)
    end
    
    -- Flash on hit
    if boss.state == "hit" then
        love.graphics.setColor(1, 1, 1)
    else
        love.graphics.setColor(boss.color)
    end
    
    -- Draw boss based on type
    if boss.type == "belchzebub" then
        drawBelchzebub()
    elseif boss.type == "mammon" then
        drawMammon()
    elseif boss.type == "devil" then
        drawDevil()
    end
    
    love.graphics.pop()
    
    -- Draw boss health bar
    drawBossHealthBar()
end

function drawBelchzebub()
    -- Lord of Flies - humanoid fly in wife-beater and bowler hat
    
    -- Body (stained wife-beater)
    love.graphics.setColor(0.8, 0.8, 0.7)
    love.graphics.rectangle("fill", boss.width/4, 30, boss.width/2, boss.height/2)
    
    -- Stains on shirt
    love.graphics.setColor(0.6, 0.5, 0.3)
    love.graphics.circle("fill", boss.width/2, 50, 5)
    love.graphics.circle("fill", boss.width/3, 60, 4)
    
    -- Pants
    love.graphics.setColor(0.3, 0.3, 0.3)
    love.graphics.rectangle("fill", boss.width/4, boss.height/2 + 20, boss.width/2, boss.height/2 - 20)
    
    -- Fly wings (animated)
    local wingBuzz = math.sin(boss.animFrame * 2) * 10
    love.graphics.setColor(0.2, 0.2, 0.2, 0.7)
    love.graphics.ellipse("fill", -10, 30 + wingBuzz, 20, 40)
    love.graphics.ellipse("fill", boss.width + 10, 30 - wingBuzz, 20, 40)
    
    -- Head (fly head)
    love.graphics.setColor(0.3, 0.2, 0.1)
    love.graphics.circle("fill", boss.width/2, 20, 20)
    
    -- Compound eyes (bloodshot)
    love.graphics.setColor(0.8, 0.2, 0.2)
    love.graphics.circle("fill", boss.width/2 - 10, 18, 8)
    love.graphics.circle("fill", boss.width/2 + 10, 18, 8)
    
    -- Black pupils
    love.graphics.setColor(0, 0, 0)
    love.graphics.circle("fill", boss.width/2 - 10, 18, 4)
    love.graphics.circle("fill", boss.width/2 + 10, 18, 4)
    
    -- Bowler hat
    love.graphics.setColor(0.1, 0.1, 0.1)
    love.graphics.ellipse("fill", boss.width/2, 5, 25, 8)
    love.graphics.arc("fill", boss.width/2, 8, 20, -math.pi, 0)
    
    -- Mandibles with cigar
    love.graphics.setColor(0.2, 0.2, 0.2)
    love.graphics.polygon("fill", boss.width/2 - 5, 25, boss.width/2 - 8, 30, boss.width/2 - 3, 30)
    love.graphics.polygon("fill", boss.width/2 + 5, 25, boss.width/2 + 8, 30, boss.width/2 + 3, 30)
    
    -- Cigar
    love.graphics.setColor(0.4, 0.3, 0.2)
    love.graphics.rectangle("fill", boss.width/2 + 15, 26, 15, 4)
    
    -- Smoke
    if boss.animFrame % 3 == 0 then
        love.graphics.setColor(0.5, 0.5, 0.5, 0.5)
        love.graphics.circle("fill", boss.width/2 + 30, 25, 3 + math.random(2))
    end
    
    -- Arms based on attack state
    love.graphics.setColor(0.3, 0.2, 0.1)
    if boss.state == "attacking" then
        -- Machine-gun jabs
        local jabExtend = 30 + math.sin(boss.animFrame * 3) * 10
        love.graphics.rectangle("fill", boss.width, 40, jabExtend, 10)
        love.graphics.circle("fill", boss.width + jabExtend, 45, 8)
    else
        -- Normal arms
        love.graphics.rectangle("fill", 5, 40, 10, 30)
        love.graphics.rectangle("fill", boss.width - 15, 40, 10, 30)
    end
end

function drawMammon()
    -- Money Mauler - grotesque gold-tattooed pit boss
    
    -- Obese body
    love.graphics.setColor(boss.color)
    love.graphics.ellipse("fill", boss.width/2, boss.height/2 + 10, boss.width/2 - 5, boss.height/2 - 10)
    
    -- Gold tattoos
    love.graphics.setColor(1, 0.9, 0)
    love.graphics.print("$", boss.width/3, boss.height/3)
    love.graphics.print("$", boss.width*2/3 - 8, boss.height/3)
    love.graphics.print("$", boss.width/2 - 4, boss.height/2)
    
    -- Suspenders
    love.graphics.setColor(0.2, 0.2, 0.2)
    love.graphics.rectangle("fill", boss.width/3, 25, 4, boss.height/2)
    love.graphics.rectangle("fill", boss.width*2/3 - 4, 25, 4, boss.height/2)
    
    -- Head with dealer's visor
    love.graphics.setColor(boss.color)
    love.graphics.circle("fill", boss.width/2, 25, 18)
    
    -- Crooked dealer's visor
    love.graphics.setColor(0, 0.5, 0)
    love.graphics.push()
    love.graphics.translate(boss.width/2, 15)
    love.graphics.rotate(-0.2)
    love.graphics.rectangle("fill", -20, -5, 40, 10)
    love.graphics.pop()
    
    -- Greedy eyes
    love.graphics.setColor(0, 0, 0)
    love.graphics.circle("fill", boss.width/2 - 8, 25, 3)
    love.graphics.circle("fill", boss.width/2 + 8, 25, 3)
    
    -- Dollar sign pupils
    love.graphics.setColor(0, 1, 0)
    love.graphics.print("$", boss.width/2 - 10, 20)
    love.graphics.print("$", boss.width/2 + 6, 20)
    
    -- Greedy mouth
    love.graphics.setColor(0, 0, 0)
    love.graphics.arc("fill", boss.width/2, 35, 10, 0, math.pi)
    
    -- Gold teeth
    love.graphics.setColor(1, 0.9, 0)
    for i = 0, 3 do
        love.graphics.rectangle("fill", boss.width/2 - 8 + i*5, 35, 3, 3)
    end
    
    -- Arms
    love.graphics.setColor(boss.color)
    if boss.state == "attacking" then
        -- Coin slam pose
        love.graphics.circle("fill", boss.width + 10, 50, 15)
        -- Coins flying
        love.graphics.setColor(1, 0.9, 0)
        for i = 1, 3 do
            love.graphics.circle("fill", boss.width + 20 + i*8, 50 - i*5, 3)
        end
    else
        love.graphics.circle("fill", 10, 50, 12)
        love.graphics.circle("fill", boss.width - 10, 50, 12)
    end
end

function drawDevil()
    -- The Devil - massive with flaming pompadour
    
    -- Shredded pinstripe suit body
    love.graphics.setColor(0.2, 0.2, 0.3)
    love.graphics.rectangle("fill", boss.width/5, 40, boss.width*3/5, boss.height/2)
    
    -- Pinstripes
    love.graphics.setColor(0.3, 0.3, 0.4)
    for i = 0, 5 do
        love.graphics.rectangle("fill", boss.width/5 + i*12, 40, 1, boss.height/2)
    end
    
    -- Torn areas
    love.graphics.setColor(boss.color)
    love.graphics.polygon("fill", boss.width/3, 60, boss.width/3 + 10, 55, boss.width/3 + 5, 70)
    
    -- Red skin/body
    love.graphics.rectangle("fill", boss.width/4, boss.height/2 + 20, boss.width/2, boss.height/2 - 20)
    
    -- Gold chains
    love.graphics.setColor(1, 0.9, 0)
    for i = 0, 2 do
        love.graphics.circle("fill", boss.width/2 - 15 + i*15, 45 + i*5, 3)
    end
    
    -- Massive head
    love.graphics.setColor(boss.color)
    love.graphics.circle("fill", boss.width/2, 25, 22)
    
    -- Flaming pompadour
    local flameHeight = 25
    if boss.phase == 3 then
        flameHeight = 35 -- Bigger flames in desperation
    end
    
    love.graphics.setColor(1, 0.5, 0)
    for i = -2, 2 do
        local flame = flameHeight + math.sin(boss.animFrame + i) * 5
        love.graphics.polygon("fill", 
            boss.width/2 + i*8 - 4, 5,
            boss.width/2 + i*8 + 4, 5,
            boss.width/2 + i*8, 5 - flame)
    end
    
    -- Evil face
    love.graphics.setColor(0, 0, 0)
    love.graphics.circle("fill", boss.width/2 - 8, 22, 4)
    love.graphics.circle("fill", boss.width/2 + 8, 22, 4)
    
    -- Red glowing eyes
    love.graphics.setColor(1, 0, 0)
    love.graphics.circle("fill", boss.width/2 - 8, 22, 2)
    love.graphics.circle("fill", boss.width/2 + 8, 22, 2)
    
    -- Evil grin
    love.graphics.setColor(0, 0, 0)
    love.graphics.arc("fill", boss.width/2, 30, 12, 0, math.pi)
    
    -- Sharp teeth
    love.graphics.setColor(1, 1, 1)
    for i = 0, 5 do
        love.graphics.polygon("fill",
            boss.width/2 - 10 + i*4, 30,
            boss.width/2 - 8 + i*4, 35,
            boss.width/2 - 6 + i*4, 30)
    end
    
    -- Horns
    love.graphics.setColor(0.4, 0.1, 0.1)
    love.graphics.polygon("fill", boss.width/2 - 20, 10, boss.width/2 - 15, 5, boss.width/2 - 18, -5)
    love.graphics.polygon("fill", boss.width/2 + 20, 10, boss.width/2 + 15, 5, boss.width/2 + 18, -5)
    
    -- Massive fists
    love.graphics.setColor(boss.color)
    if boss.state == "attacking" then
        -- Haymaker wind-up
        local windUp = math.sin(boss.attackTimer * 3) * 10
        love.graphics.circle("fill", boss.width + 15 + windUp, 60, 18)
    else
        love.graphics.circle("fill", 5, 60, 15)
        love.graphics.circle("fill", boss.width - 5, 60, 15)
    end
    
    -- Cigar (if phase 1)
    if boss.phase == 1 then
        love.graphics.setColor(0.4, 0.3, 0.2)
        love.graphics.rectangle("fill", boss.width/2 + 20, 32, 20, 5)
        love.graphics.setColor(1, 0.5, 0)
        love.graphics.circle("fill", boss.width/2 + 40, 34, 2)
    end
end

function drawBossHealthBar()
    local barWidth = 300
    local barHeight = 20
    local x = love.graphics.getWidth()/2 - barWidth/2
    local y = 30
    
    -- Background
    love.graphics.setColor(0.2, 0.2, 0.2)
    love.graphics.rectangle("fill", x, y, barWidth, barHeight)
    
    -- Health
    local healthPercent = boss.health / boss.maxHealth
    local healthColor = {1, 0, 0}
    
    if boss.phase == 2 then
        healthColor = {1, 0.5, 0}
    elseif boss.phase == 3 then
        healthColor = {1, 1, 0}
    end
    
    love.graphics.setColor(healthColor)
    love.graphics.rectangle("fill", x + 2, y + 2, (barWidth - 4) * healthPercent, barHeight - 4)
    
    -- Border
    love.graphics.setColor(1, 1, 1)
    love.graphics.rectangle("line", x, y, barWidth, barHeight)
    
    -- Boss name
    love.graphics.setColor(1, 1, 1)
    love.graphics.setNewFont(16)
    local name = ""
    if boss.type == "belchzebub" then
        name = "BELCHZEBUB - Lord of Flies"
    elseif boss.type == "mammon" then
        name = "MAMMON - The Money Mauler"
    elseif boss.type == "devil" then
        name = "THE DEVIL"
        if boss.phase == 3 then
            name = "THE DEVIL - DESPERATION"
        end
    end
    love.graphics.print(name, x + barWidth/2 - love.graphics.getFont():getWidth(name)/2, y - 20)
end

function createBossDeathEffect()
    -- Epic death explosion
    for i = 1, 20 do
        table.insert(effects, {
            type = "boss_explosion",
            x = boss.x + boss.width/2,
            y = boss.y + boss.height/2,
            timer = 1.5,
            maxTimer = 1.5,
            particles = {},
            color = boss.color
        })
        
        -- Create particles for this explosion
        local effect = effects[#effects]
        for j = 1, 15 do
            table.insert(effect.particles, {
                x = effect.x,
                y = effect.y,
                vx = math.random(-300, 300),
                vy = math.random(-400, -100),
                life = 1.0,
                size = math.random(5, 15),
                color = {
                    math.min(1, boss.color[1] + math.random() * 0.3),
                    math.min(1, boss.color[2] + math.random() * 0.3),
                    math.min(1, boss.color[3] + math.random() * 0.3)
                }
            })
        end
    end
    
    -- Massive camera shake
    triggerCameraShake(30, 1.5)
    
    -- Bonus points and souls
    score = score + boss.points
    coins = coins + 100
    
    -- Stage clear if this was the final boss
    if currentStage == 3 then
        gameState = "stage_clear"
        initStageClear()
    end
end