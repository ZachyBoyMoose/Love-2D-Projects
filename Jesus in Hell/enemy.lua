-- enemy.lua
-- All enemy types from the game design document
enemies = {}
effects = {}

local enemyDefinitions = {
    -- Stage 1 enemies
    slugpug = {
        width = 35, height = 55, speed = 100, health = 25, 
        attackDamage = 8, attackRange = 35, points = 50,
        color = {0.6, 0.4, 0.3}, rushAttack = true,
        description = "short rusher"
    },
    toothpick = {
        width = 25, height = 75, speed = 70, health = 30, 
        attackDamage = 10, attackRange = 60, points = 75,
        color = {0.7, 0.5, 0.3}, pokeAttack = true,
        description = "lanky poker"
    },
    porkknuckle = {
        width = 55, height = 65, speed = 50, health = 45, 
        attackDamage = 15, attackRange = 40, points = 100,
        color = {0.8, 0.5, 0.4}, chargeAttack = true,
        description = "heavy charger"
    },
    fly_guard = {
        width = 40, height = 70, speed = 90, health = 40, 
        attackDamage = 12, attackRange = 45, points = 125,
        color = {0.3, 0.3, 0.5}, flutterDash = true,
        description = "medium demon with flutter dash"
    },
    
    -- Stage 2 enemies
    coin_creep = {
        width = 30, height = 50, speed = 120, health = 20, 
        attackDamage = 6, attackRange = 30, points = 60,
        color = {0.8, 0.8, 0.2}, pickpocket = true,
        description = "pickpocket demon"
    },
    blubbermaw = {
        width = 60, height = 70, speed = 40, health = 60, 
        attackDamage = 18, attackRange = 35, points = 150,
        color = {0.5, 0.5, 0.7}, grappler = true,
        description = "fat grappler"
    },
    pit_boss_imp = {
        width = 45, height = 65, speed = 80, health = 50, 
        attackDamage = 14, attackRange = 50, points = 140,
        color = {0.2, 0.2, 0.2}, shoulderCheck = true,
        description = "mid-size bouncer"
    },
    cash_shark = {
        width = 35, height = 80, speed = 100, health = 45, 
        attackDamage = 16, attackRange = 70, points = 175,
        color = {0.1, 0.6, 0.1}, hookCombo = true,
        description = "lanky dealer demon"
    },
    
    -- Stage 3 enemies
    wrathling = {
        width = 38, height = 60, speed = 130, health = 35, 
        attackDamage = 12, attackRange = 40, points = 100,
        color = {0.9, 0.2, 0.2}, berserk = true,
        description = "berserk rusher"
    },
    pride_thug = {
        width = 50, height = 75, speed = 75, health = 55, 
        attackDamage = 20, attackRange = 55, points = 200,
        color = {0.6, 0.2, 0.6}, armoredDash = true,
        description = "muscular showboat"
    },
    spine_sentinel = {
        width = 45, height = 85, speed = 60, health = 70, 
        attackDamage = 22, attackRange = 65, points = 250,
        color = {0.7, 0.7, 0.8}, parryFists = true, ungrabable = true,
        description = "tall armored demon"
    }
}

function initEnemies()
    enemies = {}
    effects = {}
end

function spawnWave(stage, wave)
    local waveData = getWaveData(stage, wave)
    if not waveData then return end
    
    local cameraX = getCameraX() or 0
    local scale = getCameraScale() or 1.5
    local screenWidth = love.graphics.getWidth() / scale
    local floorHeight = getFloorHeight()
    
    -- Lock camera for wave
    lockCameraForWave(cameraX, cameraX + screenWidth)
    
    -- Spawn enemies based on wave data
    for i, enemyType in ipairs(waveData.enemies) do
        local spawnX, spawnY
        
        -- Determine spawn position based on formation
        if waveData.formation == "line" then
            spawnX = cameraX + (i - 1) * 100 + 50
            spawnY = floorHeight - enemyDefinitions[enemyType].height
        elseif waveData.formation == "v" then
            local center = cameraX + screenWidth / 2
            spawnX = center + (i - math.ceil(#waveData.enemies/2)) * 80
            spawnY = floorHeight - enemyDefinitions[enemyType].height + math.abs(i - math.ceil(#waveData.enemies/2)) * 20
        elseif waveData.formation == "surround" then
            if i % 2 == 0 then
                spawnX = cameraX - 50
            else
                spawnX = cameraX + screenWidth + 50
            end
            spawnY = floorHeight - enemyDefinitions[enemyType].height + (i - 1) * 15
        elseif waveData.formation == "pincer" then
            if i <= math.ceil(#waveData.enemies/2) then
                spawnX = cameraX - 50 - (i - 1) * 30
            else
                spawnX = cameraX + screenWidth + 50 + (i - math.ceil(#waveData.enemies/2) - 1) * 30
            end
            spawnY = floorHeight - enemyDefinitions[enemyType].height
        else
            -- Default spread
            spawnX = cameraX + math.random(50, screenWidth - 50)
            spawnY = floorHeight - enemyDefinitions[enemyType].height + math.random(-30, 30)
        end
        
        createEnemy(enemyType, spawnX, spawnY)
    end
    
    -- Spawn any special elements for this wave
    if waveData.hazards then
        for _, hazard in ipairs(waveData.hazards) do
            createWaveHazard(hazard, cameraX, screenWidth)
        end
    end
    
    if waveData.pickups then
        for _, pickup in ipairs(waveData.pickups) do
            createWavePickup(pickup, cameraX, screenWidth)
        end
    end
end

function getWaveData(stage, wave)
    local waveConfigs = {
        -- Stage 1 waves
        {
            {enemies = {"slugpug", "slugpug", "toothpick"}, formation = "line", 
             pickups = {type = "crate", contains = "rosary"}},
            {enemies = {"slugpug", "slugpug", "slugpug", "porkknuckle"}, formation = "surround",
             hazards = {"sewer_burst"}},
            {enemies = {"toothpick", "toothpick", "porkknuckle"}, formation = "v",
             hazards = {"sewer_burst", "sewer_burst"}},
            {enemies = {"slugpug", "slugpug", "toothpick", "toothpick"}, formation = "pincer",
             pickups = {type = "crate", contains = "thorned_knuckle"}},
            {enemies = {"fly_guard", "slugpug", "slugpug"}, formation = "line"},
            {enemies = {"toothpick", "toothpick", "porkknuckle", "fly_guard"}, formation = "surround",
             pickups = {type = "crate", contains = "bread_fish"}}
        },
        -- Stage 2 waves
        {
            {enemies = {"coin_creep", "coin_creep", "blubbermaw"}, formation = "line",
             pickups = {type = "chest", contains = "martini"}},
            {enemies = {"coin_creep", "coin_creep", "coin_creep", "pit_boss_imp"}, formation = "v",
             hazards = {"coin_river"}},
            {enemies = {"blubbermaw", "blubbermaw", "coin_creep"}, formation = "surround",
             hazards = {"roulette_wheel"}},
            {enemies = {"pit_boss_imp", "coin_creep", "blubbermaw"}, formation = "pincer",
             pickups = {type = "chest", contains = "crown_thorns"}},
            {enemies = {"cash_shark", "coin_creep", "coin_creep"}, formation = "line"},
            {enemies = {"blubbermaw", "blubbermaw", "coin_creep", "coin_creep", "cash_shark"}, formation = "surround",
             pickups = {type = "slot_machine", contains = "miracle_loaf"}}
        },
        -- Stage 3 waves
        {
            {enemies = {"wrathling", "wrathling"}, formation = "line",
             pickups = {type = "bone_chest", contains = "chalice"}},
            {enemies = {"pride_thug", "pride_thug", "wrathling"}, formation = "v",
             hazards = {"bone_pendulum"}},
            {enemies = {"wrathling", "pride_thug", "wrathling"}, formation = "surround",
             hazards = {"lava_vent"}},
            {enemies = {"spine_sentinel", "wrathling"}, formation = "line",
             pickups = {type = "bone_chest", contains = "holy_upper"}},
            {enemies = {"wrathling", "pride_thug", "spine_sentinel", "wrathling"}, formation = "pincer",
             pickups = {type = "bone_chest", contains = "spirit_bomb"}},
            {enemies = {"wrathling", "wrathling", "wrathling", "wrathling"}, formation = "surround"}
        }
    }
    
    if stage <= #waveConfigs and wave <= #waveConfigs[stage] then
        return waveConfigs[stage][wave]
    end
    return nil
end

function createEnemy(type, x, y)
    local def = enemyDefinitions[type]
    if not def then return end
    
    local enemy = {
        type = type, x = x, y = y, 
        width = def.width, height = def.height,
        speed = def.speed, health = def.health, maxHealth = def.health,
        attackDamage = def.attackDamage, attackRange = def.attackRange,
        points = def.points, color = def.color, 
        state = "idle", direction = -1, active = true, 
        deathTimer = 0.5, hitTimer = 0.2,
        attackTimer = 0, attackCooldown = 0, attackCooldownMax = 1.0,
        knockback = 0, hitFlash = false, deathFlash = false,
        jumpVelocity = 0, isGrounded = true,
        animFrame = 0, animTimer = 0,
        
        -- Special abilities
        rushAttack = def.rushAttack,
        pokeAttack = def.pokeAttack,
        chargeAttack = def.chargeAttack,
        flutterDash = def.flutterDash,
        pickpocket = def.pickpocket,
        grappler = def.grappler,
        shoulderCheck = def.shoulderCheck,
        hookCombo = def.hookCombo,
        berserk = def.berserk,
        armoredDash = def.armoredDash,
        parryFists = def.parryFists,
        ungrabable = def.ungrabable
    }
    
    table.insert(enemies, enemy)
    return enemy
end

function updateEnemies(dt)
    for i, enemy in ipairs(enemies) do
        if enemy.active then
            updateEnemy(enemy, dt)
        end
    end
    
    updateEffects(dt)
end

function updateEnemy(enemy, dt)
    -- Update animation
    enemy.animTimer = enemy.animTimer + dt
    if enemy.animTimer > 0.15 then
        enemy.animTimer = 0
        enemy.animFrame = (enemy.animFrame + 1) % 4
    end
    
    -- Apply physics
    if not enemy.isGrounded then
        enemy.jumpVelocity = enemy.jumpVelocity + 800 * dt
        enemy.y = enemy.y + enemy.jumpVelocity * dt
        
        if enemy.y >= getFloorHeight() - enemy.height then
            enemy.y = getFloorHeight() - enemy.height
            enemy.isGrounded = true
            enemy.jumpVelocity = 0
            if enemy.state == "thrown" then
                enemy.health = enemy.health - 10
                if enemy.health <= 0 then
                    enemy.state = "dying"
                    enemy.deathTimer = 0.5
                else
                    enemy.state = "hit"
                    enemy.hitTimer = 0.5
                end
            end
        end
    end
    
    -- Apply knockback
    if enemy.knockback ~= 0 then
        enemy.x = enemy.x + enemy.knockback * dt * 60
        enemy.knockback = enemy.knockback * (1 - dt * 10)
        if math.abs(enemy.knockback) < 1 then enemy.knockback = 0 end
    end
    
    -- State handling
    if enemy.state == "dying" then
        enemy.deathTimer = enemy.deathTimer - dt
        enemy.deathFlash = math.floor(enemy.deathTimer * 10) % 2 == 0
        if enemy.deathTimer <= 0 then
            enemy.active = false
            createDeathEffect(enemy.x + enemy.width/2, enemy.y + enemy.height/2, enemy.color)
        end
    elseif enemy.state == "hit" then
        enemy.hitTimer = enemy.hitTimer - dt
        enemy.hitFlash = true
        if enemy.hitTimer <= 0 then
            enemy.state = "idle"
            enemy.hitFlash = false
        end
    elseif enemy.state == "grabbed" then
        -- Being held by player
    elseif enemy.state == "thrown" then
        -- Flying through air
    elseif enemy.state == "attacking" then
        enemy.attackTimer = enemy.attackTimer - dt
        if enemy.attackTimer <= 0 then
            enemy.state = "idle"
            enemy.attackCooldown = enemy.attackCooldownMax
        end
    else
        updateEnemyAI(enemy, dt)
    end
    
    if enemy.attackCooldown > 0 then
        enemy.attackCooldown = enemy.attackCooldown - dt
    end
end

function updateEnemyAI(enemy, dt)
    local dx = player.x - enemy.x
    local dy = player.y - enemy.y
    local dist = math.sqrt(dx*dx + dy*dy)
    
    if dist > 400 then
        enemy.state = "idle"
        return
    end
    
    if dist > 0 then
        dx = dx / dist
        dy = dy / dist
    end
    
    enemy.direction = dx > 0 and 1 or -1
    
    -- Special AI behaviors based on enemy type
    if enemy.berserk then
        -- Always rush player
        enemy.x = enemy.x + dx * enemy.speed * 1.5 * dt
        enemy.y = enemy.y + dy * enemy.speed * 0.5 * dt
        enemy.state = "walking"
        
        if dist < enemy.attackRange and enemy.attackCooldown <= 0 then
            performEnemyAttack(enemy)
        end
    elseif enemy.chargeAttack and enemy.state == "charging" then
        -- Charging attack
        enemy.x = enemy.x + enemy.direction * enemy.speed * 3 * dt
        enemy.chargeTimer = enemy.chargeTimer - dt
        if enemy.chargeTimer <= 0 then
            enemy.state = "idle"
            enemy.attackCooldown = 2
        end
    elseif enemy.flutterDash and math.random() < 0.01 then
        -- Random flutter dash
        enemy.jumpVelocity = -200
        enemy.isGrounded = false
        enemy.knockback = enemy.direction * 20
    elseif dist > enemy.attackRange then
        -- Move toward player
        enemy.x = enemy.x + dx * enemy.speed * dt
        enemy.y = enemy.y + dy * enemy.speed * 0.3 * dt
        enemy.state = "walking"
        
        -- Special movement abilities
        if enemy.chargeAttack and dist < 150 and enemy.attackCooldown <= 0 and math.random() < 0.02 then
            enemy.state = "charging"
            enemy.chargeTimer = 0.5
        end
    elseif enemy.attackCooldown <= 0 then
        performEnemyAttack(enemy)
    end
    
    -- Keep enemies on screen during waves
    if isWaveActive() then
        local bounds = getCameraScreenBounds()
        enemy.x = math.max(bounds.left + 10, math.min(bounds.right - enemy.width - 10, enemy.x))
    end
end

function performEnemyAttack(enemy)
    enemy.state = "attacking"
    enemy.attackTimer = 0.3
    enemy.attackCooldown = 1.0
    
    -- Special attack patterns
    if enemy.hookCombo then
        enemy.attackTimer = 0.5
        enemy.attackDamage = enemy.attackDamage * 1.2
    elseif enemy.pokeAttack then
        enemy.attackRange = enemy.attackRange * 1.5
    elseif enemy.pickpocket and math.random() < 0.3 then
        -- Try to steal coins
        enemy.attackDamage = 5
        if coins > 0 then coins = coins - 1 end
    end
end

function drawEnemy(enemy)
    if not enemy.active then return end
    
    love.graphics.push()
    love.graphics.translate(enemy.x, enemy.y)
    
    if enemy.direction == -1 then
        love.graphics.scale(-1, 1)
        love.graphics.translate(-enemy.width, 0)
    end
    
    if enemy.hitFlash then
        love.graphics.setColor(1, 1, 1)
    elseif enemy.deathFlash then
        love.graphics.setColor(1, 0, 0)
    else
        love.graphics.setColor(enemy.color)
    end
    
    -- Draw enemy based on type
    if enemy.type == "slugpug" then
        drawSlugpug(enemy)
    elseif enemy.type == "toothpick" then
        drawToothpick(enemy)
    elseif enemy.type == "porkknuckle" then
        drawPorkknuckle(enemy)
    elseif enemy.type == "fly_guard" then
        drawFlyGuard(enemy)
    elseif enemy.type == "coin_creep" then
        drawCoinCreep(enemy)
    elseif enemy.type == "blubbermaw" then
        drawBlubbermaw(enemy)
    elseif enemy.type == "pit_boss_imp" then
        drawPitBossImp(enemy)
    elseif enemy.type == "cash_shark" then
        drawCashShark(enemy)
    elseif enemy.type == "wrathling" then
        drawWrathling(enemy)
    elseif enemy.type == "pride_thug" then
        drawPrideThug(enemy)
    elseif enemy.type == "spine_sentinel" then
        drawSpineSentinel(enemy)
    else
        -- Generic enemy
        love.graphics.rectangle("fill", 0, 0, enemy.width, enemy.height)
    end
    
    love.graphics.pop()
end

function drawSlugpug(enemy)
    -- Short, stocky rusher
    love.graphics.rectangle("fill", 5, 15, enemy.width - 10, enemy.height - 15)
    
    -- Stubby legs
    love.graphics.rectangle("fill", 8, enemy.height - 10, 8, 10)
    love.graphics.rectangle("fill", enemy.width - 16, enemy.height - 10, 8, 10)
    
    -- Head
    love.graphics.circle("fill", enemy.width/2, 10, 12)
    
    -- Eyes
    love.graphics.setColor(1, 0, 0)
    love.graphics.circle("fill", enemy.width/2 - 5, 8, 2)
    love.graphics.circle("fill", enemy.width/2 + 5, 8, 2)
    
    -- Fists
    if enemy.state == "attacking" then
        love.graphics.setColor(enemy.color[1]*0.8, enemy.color[2]*0.8, enemy.color[3]*0.8)
        love.graphics.circle("fill", enemy.width + 5, 25, 6)
    end
end

function drawToothpick(enemy)
    -- Lanky poker demon
    love.graphics.rectangle("fill", enemy.width/3, 10, enemy.width/3, enemy.height - 20)
    
    -- Long thin legs
    love.graphics.rectangle("fill", enemy.width/3, enemy.height - 20, 3, 20)
    love.graphics.rectangle("fill", enemy.width*2/3 - 3, enemy.height - 20, 3, 20)
    
    -- Small head
    love.graphics.circle("fill", enemy.width/2, 8, 6)
    
    -- Poker arm
    if enemy.state == "attacking" then
        love.graphics.setColor(0.5, 0.5, 0.5)
        love.graphics.rectangle("fill", enemy.width, 20, enemy.attackRange, 2)
        love.graphics.polygon("fill", enemy.width + enemy.attackRange, 20, 
                            enemy.width + enemy.attackRange + 8, 21,
                            enemy.width + enemy.attackRange, 22)
    end
    
    -- Eyes
    love.graphics.setColor(1, 1, 0)
    love.graphics.circle("fill", enemy.width/2 - 2, 6, 1)
    love.graphics.circle("fill", enemy.width/2 + 2, 6, 1)
end

function drawPorkknuckle(enemy)
    -- Heavy charger
    love.graphics.rectangle("fill", 3, 10, enemy.width - 6, enemy.height - 15)
    
    -- Thick legs
    love.graphics.rectangle("fill", 10, enemy.height - 15, 12, 15)
    love.graphics.rectangle("fill", enemy.width - 22, enemy.height - 15, 12, 15)
    
    -- Big head
    love.graphics.circle("fill", enemy.width/2, 15, 15)
    
    -- Tusks
    love.graphics.setColor(1, 1, 1)
    love.graphics.polygon("fill", 10, 15, 15, 20, 12, 25)
    love.graphics.polygon("fill", enemy.width - 10, 15, enemy.width - 15, 20, enemy.width - 12, 25)
    
    -- Eyes
    love.graphics.setColor(0, 0, 0)
    love.graphics.circle("fill", enemy.width/2 - 6, 12, 2)
    love.graphics.circle("fill", enemy.width/2 + 6, 12, 2)
    
    -- Charge effect
    if enemy.state == "charging" then
        love.graphics.setColor(1, 0.5, 0)
        for i = 1, 3 do
            love.graphics.circle("line", -i*10, enemy.height/2, 3)
        end
    end
end

function drawFlyGuard(enemy)
    -- Medium demon with wings
    love.graphics.rectangle("fill", enemy.width/4, 20, enemy.width/2, enemy.height - 25)
    
    -- Wings (flutter animation)
    local wingFlap = math.sin(enemy.animFrame * math.pi / 2) * 5
    love.graphics.setColor(0.2, 0.2, 0.3)
    love.graphics.polygon("fill", 0, 15, -10 - wingFlap, 25, -5, 35, 5, 30)
    love.graphics.polygon("fill", enemy.width, 15, enemy.width + 10 + wingFlap, 25, 
                        enemy.width + 5, 35, enemy.width - 5, 30)
    
    -- Head
    love.graphics.setColor(enemy.color)
    love.graphics.circle("fill", enemy.width/2, 12, 10)
    
    -- Compound eyes
    love.graphics.setColor(1, 0, 0, 0.7)
    love.graphics.circle("fill", enemy.width/2 - 5, 10, 4)
    love.graphics.circle("fill", enemy.width/2 + 5, 10, 4)
end

function drawCoinCreep(enemy)
    -- Pickpocket demon
    love.graphics.rectangle("fill", enemy.width/3, 15, enemy.width/3, enemy.height - 20)
    
    -- Sneaky pose
    local sneakLean = math.sin(enemy.animTimer * 5) * 2
    love.graphics.push()
    love.graphics.translate(sneakLean, 0)
    
    -- Head with hood
    love.graphics.setColor(0.5, 0.5, 0.1)
    love.graphics.polygon("fill", enemy.width/2 - 8, 5, enemy.width/2 + 8, 5,
                        enemy.width/2 + 10, 15, enemy.width/2 - 10, 15)
    
    love.graphics.pop()
    
    -- Grabby hands
    love.graphics.setColor(enemy.color)
    if enemy.state == "attacking" then
        love.graphics.circle("fill", enemy.width + 8, 25, 4)
        love.graphics.circle("fill", enemy.width + 5, 30, 3)
    end
    
    -- Coin pouch
    love.graphics.setColor(0.9, 0.9, 0.1)
    love.graphics.circle("fill", enemy.width/2, enemy.height - 10, 5)
end

function drawBlubbermaw(enemy)
    -- Fat grappler
    love.graphics.ellipse("fill", enemy.width/2, enemy.height/2, enemy.width/2 - 2, enemy.height/2 - 5)
    
    -- Stubby arms
    love.graphics.circle("fill", 5, enemy.height/2, 8)
    love.graphics.circle("fill", enemy.width - 5, enemy.height/2, 8)
    
    -- Big mouth
    love.graphics.setColor(0, 0, 0)
    love.graphics.arc("fill", enemy.width/2, enemy.height/2, 15, 0, math.pi)
    
    -- Teeth
    love.graphics.setColor(1, 1, 1)
    for i = 0, 4 do
        love.graphics.polygon("fill", enemy.width/2 - 10 + i*5, enemy.height/2,
                            enemy.width/2 - 8 + i*5, enemy.height/2 + 5,
                            enemy.width/2 - 6 + i*5, enemy.height/2)
    end
    
    -- Eyes
    love.graphics.setColor(0, 0, 0)
    love.graphics.circle("fill", enemy.width/2 - 10, enemy.height/3, 2)
    love.graphics.circle("fill", enemy.width/2 + 10, enemy.height/3, 2)
end

function drawPitBossImp(enemy)
    -- Mid-size bouncer in suit
    love.graphics.rectangle("fill", enemy.width/4, 20, enemy.width/2, enemy.height - 25)
    
    -- Suit jacket
    love.graphics.setColor(0.1, 0.1, 0.1)
    love.graphics.rectangle("fill", enemy.width/4 - 2, 25, enemy.width/2 + 4, 20)
    
    -- Tie
    love.graphics.setColor(0.8, 0, 0)
    love.graphics.rectangle("fill", enemy.width/2 - 2, 25, 4, 15)
    
    -- Head with sunglasses
    love.graphics.setColor(enemy.color)
    love.graphics.circle("fill", enemy.width/2, 12, 10)
    
    love.graphics.setColor(0, 0, 0)
    love.graphics.rectangle("fill", enemy.width/2 - 8, 10, 16, 4)
    
    -- Shoulder check pose
    if enemy.state == "attacking" then
        love.graphics.setColor(enemy.color)
        love.graphics.rectangle("fill", enemy.width - 5, 20, 15, 15)
    end
end

function drawCashShark(enemy)
    -- Lanky dealer demon
    love.graphics.rectangle("fill", enemy.width/3, 15, enemy.width/3, enemy.height - 20)
    
    -- Dealer vest
    love.graphics.setColor(0, 0.3, 0)
    love.graphics.rectangle("fill", enemy.width/3 - 2, 20, enemy.width/3 + 4, 25)
    
    -- Long arms for hook combos
    if enemy.state == "attacking" then
        local hookAngle = enemy.animFrame * math.pi / 4
        love.graphics.setColor(enemy.color)
        love.graphics.push()
        love.graphics.translate(enemy.width, 30)
        love.graphics.rotate(hookAngle)
        love.graphics.rectangle("fill", 0, -2, 25, 4)
        love.graphics.circle("fill", 25, 0, 5)
        love.graphics.pop()
    end
    
    -- Head with visor
    love.graphics.setColor(enemy.color)
    love.graphics.circle("fill", enemy.width/2, 10, 8)
    
    love.graphics.setColor(0, 0.5, 0)
    love.graphics.arc("fill", enemy.width/2, 8, 10, -math.pi, 0)
    
    -- Dollar sign eyes
    love.graphics.setColor(0, 1, 0)
    love.graphics.print("$", enemy.width/2 - 7, 5)
    love.graphics.print("$", enemy.width/2 + 2, 5)
end

function drawWrathling(enemy)
    -- Berserk rusher with flames
    love.graphics.rectangle("fill", enemy.width/4, 15, enemy.width/2, enemy.height - 20)
    
    -- Flame aura
    love.graphics.setColor(1, 0.5, 0, 0.5)
    for i = 0, 3 do
        local flameY = -5 - math.sin(enemy.animTimer * 10 + i) * 5
        love.graphics.circle("fill", 5 + i*10, flameY, 4)
    end
    
    -- Angry face
    love.graphics.setColor(enemy.color)
    love.graphics.circle("fill", enemy.width/2, 10, 9)
    
    -- Red eyes
    love.graphics.setColor(1, 0, 0)
    love.graphics.circle("fill", enemy.width/2 - 4, 8, 2)
    love.graphics.circle("fill", enemy.width/2 + 4, 8, 2)
    
    -- Rage mouth
    love.graphics.setColor(0, 0, 0)
    love.graphics.rectangle("fill", enemy.width/2 - 5, 13, 10, 3)
end

function drawPrideThug(enemy)
    -- Muscular showboat
    love.graphics.rectangle("fill", enemy.width/5, 20, enemy.width*3/5, enemy.height - 25)
    
    -- Muscular arms
    love.graphics.circle("fill", 5, 25, 7)
    love.graphics.circle("fill", enemy.width - 5, 25, 7)
    love.graphics.rectangle("fill", 0, 25, 10, 20)
    love.graphics.rectangle("fill", enemy.width - 10, 25, 10, 20)
    
    -- Crown
    love.graphics.setColor(0.9, 0.9, 0.1)
    for i = 0, 2 do
        love.graphics.polygon("fill", enemy.width/2 - 8 + i*8, 0,
                            enemy.width/2 - 6 + i*8, -8,
                            enemy.width/2 - 2 + i*8, 0)
    end
    
    -- Smug face
    love.graphics.setColor(enemy.color)
    love.graphics.circle("fill", enemy.width/2, 10, 10)
    
    -- Sunglasses
    love.graphics.setColor(0, 0, 0)
    love.graphics.rectangle("fill", enemy.width/2 - 9, 8, 18, 5)
    
    -- Armored dash effect
    if enemy.state == "attacking" and enemy.armoredDash then
        love.graphics.setColor(0.7, 0.7, 0.7, 0.5)
        love.graphics.rectangle("fill", -10, 0, enemy.width + 20, enemy.height)
    end
end

function drawSpineSentinel(enemy)
    -- Tall armored demon
    love.graphics.setColor(0.6, 0.6, 0.7)
    love.graphics.rectangle("fill", enemy.width/4, 10, enemy.width/2, enemy.height - 15)
    
    -- Bone armor plates
    love.graphics.setColor(0.9, 0.9, 0.9)
    for i = 0, 3 do
        love.graphics.rectangle("fill", enemy.width/4 - 2, 15 + i*18, enemy.width/2 + 4, 5)
    end
    
    -- Skull helmet
    love.graphics.setColor(1, 1, 1)
    love.graphics.circle("fill", enemy.width/2, 8, 10)
    
    -- Eye sockets
    love.graphics.setColor(0, 0, 0)
    love.graphics.circle("fill", enemy.width/2 - 4, 6, 3)
    love.graphics.circle("fill", enemy.width/2 + 4, 6, 3)
    
    -- Parry fists
    if enemy.state == "attacking" or enemy.parryActive then
        love.graphics.setColor(0.5, 0.5, 0.6)
        love.graphics.circle("fill", enemy.width + 8, 30, 8)
        love.graphics.circle("fill", enemy.width + 8, 40, 8)
    end
end

function createDeathEffect(x, y, color)
    table.insert(effects, {
        type = "death",
        x = x,
        y = y,
        timer = 0.5,
        color = color,
        particles = {}
    })
    
    for i = 1, 12 do
        table.insert(effects[#effects].particles, {
            x = x,
            y = y,
            vx = math.random(-150, 150),
            vy = math.random(-200, -50),
            life = 0.5
        })
    end
end

function updateEffects(dt)
    for i = #effects, 1, -1 do
        local effect = effects[i]
        effect.timer = effect.timer - dt
        
        if effect.type == "death" then
            for j, particle in ipairs(effect.particles) do
                particle.x = particle.x + particle.vx * dt
                particle.y = particle.y + particle.vy * dt
                particle.vy = particle.vy + 400 * dt
                particle.life = particle.life - dt
            end
        elseif effect.type == "go_indicator" then
            -- Blink effect
            effect.blink = math.floor(effect.timer * 4) % 2 == 0
        elseif effect.type == "holy_explosion" then
            effect.radius = effect.radius + (effect.maxRadius - effect.radius) * dt * 8
        end
        
        if effect.timer <= 0 then
            table.remove(effects, i)
        end
    end
end

function drawEffects()
    for _, effect in ipairs(effects) do
        if effect.type == "death" then
            for _, particle in ipairs(effect.particles) do
                if particle.life > 0 then
                    local alpha = particle.life * 2
                    love.graphics.setColor(effect.color[1], effect.color[2], effect.color[3], alpha)
                    love.graphics.circle("fill", particle.x, particle.y, particle.life * 8)
                end
            end
        elseif effect.type == "go_indicator" then
            if effect.blink then
                love.graphics.setColor(1, 1, 0)
                love.graphics.setNewFont(48)
                love.graphics.print("GO!", effect.x, effect.y)
                
                -- Arrow
                love.graphics.polygon("fill", effect.x + 100, effect.y + 24,
                                    effect.x + 130, effect.y + 24,
                                    effect.x + 120, effect.y + 10,
                                    effect.x + 150, effect.y + 24,
                                    effect.x + 120, effect.y + 38,
                                    effect.x + 130, effect.y + 24)
            end
        elseif effect.type == "holy_explosion" then
            local alpha = effect.timer / effect.maxTimer
            love.graphics.setColor(1, 1, 0, alpha * 0.5)
            love.graphics.circle("fill", effect.x, effect.y, effect.radius)
            love.graphics.setColor(1, 1, 1, alpha)
            love.graphics.circle("line", effect.x, effect.y, effect.radius)
            
            -- Cross beams
            love.graphics.setColor(1, 1, 1, alpha * 0.8)
            love.graphics.rectangle("fill", effect.x - 2, effect.y - effect.radius, 4, effect.radius * 2)
            love.graphics.rectangle("fill", effect.x - effect.radius, effect.y - 2, effect.radius * 2, 4)
        end
    end
end

function showGoIndicator()
    local camX = getCameraX() or 0
    local screenWidth = love.graphics.getWidth() / camera.scale
    
    table.insert(effects, {
        type = "go_indicator",
        x = camX + screenWidth/2 - 50,
        y = 100,
        timer = 2,
        blink = false
    })
end