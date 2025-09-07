-- main.lua
-- Jesus in Hell - Redemption Brawl (Final Fight/Mutation Nation style)
function love.load()
    -- Set up window
    love.window.setMode(800, 600, {resizable = false})
    love.window.setTitle("Jesus in Hell - Redemption Brawl")
    
    -- Create global tables BEFORE loading modules
    _G.camera = {}
    _G.stages = {}
    _G.enemies = {}
    _G.effects = {}
    _G.hazards = {}
    _G.player = {}
    _G.boss = {}
    _G.pickups = {}
    _G.weapons = {}
    
    -- Game state management
    _G.gameState = "title"
    _G.currentStage = 1
    _G.score = 0
    _G.playerLives = 3
    _G.comboCounter = 0
    _G.maxCombo = 0
    _G.coins = 0
    _G.currentWave = 0
    _G.maxWave = 6
    _G.waveEnemiesLeft = 0
    _G.bonusRoundTimer = 0
    
    -- Load modules (they will populate the global tables)
    require("utils")
    require("camera")
    require("stage")
    require("player")
    require("enemy")
    require("boss")
    require("ui")
    require("hazard")
    require("pickup")
    require("weapon")
    
    -- Initialize game components AFTER modules are loaded
    initCamera()
    initUI()
    
    -- Start with title screen
    initTitleScreen()
end

function love.update(dt)
    -- Cap delta time
    dt = math.min(dt, 1/30)
    
    if gameState == "title" then
        updateTitleScreen(dt)
    elseif gameState == "playing" then
        updateCamera(dt)
        updateStage(dt)
        updatePlayer(dt)
        updateEnemies(dt)
        updateBoss(dt)
        updateHazards(dt)
        updatePickups(dt)
        updateWeapons(dt)
        checkCollisions()
        checkWaveProgression()
    elseif gameState == "stage_clear" then
        updateStageClear(dt)
    elseif gameState == "game_over" then
        updateGameOver(dt)
    elseif gameState == "bonus" then
        updateBonusRound(dt)
    elseif gameState == "pause" then
        -- Paused, no updates
    end
end

function love.draw()
    if gameState == "title" then
        drawTitleScreen()
    elseif gameState == "playing" or gameState == "pause" then
        -- Apply camera transformation
        applyCameraTransform()
        
        -- Draw stage background and floor
        drawStage()
        
        -- Draw hazards (below entities)
        drawHazards()
        
        -- Draw pickups
        drawPickups()
        
        -- Draw weapons on ground
        drawGroundWeapons()
        
        -- Sort and draw all entities by Y position (depth sorting)
        local entities = {}
        
        -- Add enemies
        for i, enemy in ipairs(enemies) do
            if enemy.active then
                table.insert(entities, {type = "enemy", obj = enemy, y = enemy.y + enemy.height})
            end
        end
        
        -- Add boss
        if boss.active then
            table.insert(entities, {type = "boss", obj = boss, y = boss.y + boss.height})
        end
        
        -- Add player
        table.insert(entities, {type = "player", obj = player, y = player.y + player.height})
        
        -- Sort by Y position
        table.sort(entities, function(a, b) return a.y < b.y end)
        
        -- Draw sorted entities
        for _, entity in ipairs(entities) do
            if entity.type == "enemy" then
                drawEnemy(entity.obj)
            elseif entity.type == "boss" then
                drawBoss()
            elseif entity.type == "player" then
                drawPlayer()
            end
        end
        
        -- Draw effects (on top)
        drawEffects()
        
        -- Reset camera and draw UI
        resetCameraTransform()
        drawUI()
        
        if gameState == "pause" then
            drawPauseMenu()
        end
    elseif gameState == "stage_clear" then
        drawStageClear()
    elseif gameState == "game_over" then
        drawGameOver()
    elseif gameState == "bonus" then
        drawBonusRound()
    elseif gameState == "ending" then
        drawEnding()
    end
end

function love.keypressed(key)
    if gameState == "title" then
        if key == "return" then
            startGame()
        elseif key == "escape" then
            love.event.quit()
        end
    elseif gameState == "playing" then
        handlePlayerInput(key, true)
        
        if key == "escape" then
            gameState = "pause"
        end
    elseif gameState == "pause" then
        if key == "escape" then
            gameState = "playing"
        elseif key == "q" then
            gameState = "title"
            initTitleScreen()
        end
    elseif gameState == "stage_clear" then
        if key == "return" then
            advanceToNextStage()
        end
    elseif gameState == "game_over" then
        if key == "return" then
            gameState = "title"
            initTitleScreen()
        end
    elseif gameState == "ending" then
        if key == "return" then
            gameState = "title"
            initTitleScreen()
        end
    end
end

function love.keyreleased(key)
    if gameState == "playing" then
        handlePlayerInput(key, false)
    end
end

function startGame()
    gameState = "playing"
    currentStage = 1
    currentWave = 0
    score = 0
    playerLives = 3
    comboCounter = 0
    maxCombo = 0
    coins = 0
    
    -- Initialize camera first
    initCamera()
    
    -- Then initialize stage and player
    initStage(currentStage)
    initPlayer()
    
    -- Start first wave
    nextWave()
    
    -- Ensure player is visible by adjusting camera position
    camera.x = player.x - (love.graphics.getWidth() / camera.scale) / 2
    camera.y = getFloorHeight() - love.graphics.getHeight() / camera.scale + 50
    camera.targetX = camera.x
    camera.targetY = camera.y
end

function advanceToNextStage()
    currentStage = currentStage + 1
    currentWave = 0
    
    if currentStage > 3 then
        -- Game completed
        gameState = "ending"
        initEnding()
    else
        gameState = "playing"
        initStage(currentStage)
        initPlayer()
        nextWave()
    end
end

function checkCollisions()
    -- Player attacks against enemies
    if player.state == "attacking" or player.state == "throwing" then
        for i, enemy in ipairs(enemies) do
            if enemy.active and enemy.state ~= "dying" then
                if checkAttackCollision(player, enemy) then
                    hitEnemy(enemy, player.attackDamage, player.direction)
                end
            end
        end
        
        -- Player attacks against boss
        if boss.active and boss.state ~= "dying" and boss.state ~= "inactive" then
            if checkAttackCollision(player, boss) then
                hitBoss(player.attackDamage, player.direction)
            end
        end
    end
    
    -- Enemy attacks against player
    if player.invulnerable <= 0 then
        for i, enemy in ipairs(enemies) do
            if enemy.active and enemy.state == "attacking" then
                if checkAttackCollision(enemy, player) then
                    damagePlayer(enemy.attackDamage, enemy)
                end
            end
        end
        
        -- Boss attacks
        if boss.active and boss.state == "attacking" then
            if checkAttackCollision(boss, player) then
                damagePlayer(boss.attackDamage or 30, boss)
            end
        end
    end
    
    -- Pickup collisions
    for i = #pickups, 1, -1 do
        local pickup = pickups[i]
        if checkCollision(player, pickup) then
            applyPickup(pickup)
            table.remove(pickups, i)
        end
    end
    
    -- Weapon pickup collisions
    for i = #weapons, 1, -1 do
        local weapon = weapons[i]
        if weapon.onGround and checkCollision(player, weapon) then
            player.weapon = weapon.type
            player.weaponUses = weapon.uses
            table.remove(weapons, i)
        end
    end
    
    -- Hazard collisions
    for _, hazard in ipairs(hazards) do
        if hazard.active then
            -- Player hazard collision
            if checkHazardCollision(hazard, player) then
                handleHazardDamage(hazard, player)
            end
            
            -- Enemy hazard collision
            for _, enemy in ipairs(enemies) do
                if enemy.active and checkHazardCollision(hazard, enemy) then
                    handleHazardDamage(hazard, enemy)
                end
            end
        end
    end
    
    -- Reset combo if too much time has passed
    if comboCounter > 0 and player.state ~= "attacking" then
        if player.comboResetTimer <= 0 then
            comboCounter = 0
        end
    end
end

function checkWaveProgression()
    -- Count active enemies
    local activeEnemies = 0
    for _, enemy in ipairs(enemies) do
        if enemy.active and enemy.state ~= "dying" then
            activeEnemies = activeEnemies + 1
        end
    end
    
    waveEnemiesLeft = activeEnemies
    
    -- Check if wave is cleared
    if isWaveActive() and activeEnemies == 0 then
        if boss.active and boss.state ~= "dying" and boss.state ~= "inactive" then
            -- Boss still active, don't progress
            return
        end
        
        -- Wave cleared
        unlockCamera()
        
        if currentWave >= maxWave then
            -- All waves cleared, spawn boss
            if not boss.active then
                spawnBoss()
            end
        else
            -- Show GO indicator and progress
            showGoIndicator()
            -- Small delay before next wave
            if not player.waveDelay then
                player.waveDelay = 1.5
            end
        end
    end
    
    -- Handle wave delay
    if player.waveDelay then
        player.waveDelay = player.waveDelay - love.timer.getDelta()
        if player.waveDelay <= 0 then
            player.waveDelay = nil
            nextWave()
        end
    end
end

function nextWave()
    currentWave = currentWave + 1
    if currentWave <= maxWave then
        spawnWave(currentStage, currentWave)
    end
end

function hitEnemy(enemy, damage, direction)
    enemy.health = enemy.health - damage
    enemy.state = "hit"
    enemy.hitTimer = 0.2
    
    -- Apply knockback
    enemy.knockback = direction * (10 + player.attackCombo * 5)
    
    -- Hit effects
    player.hitStun = 0.05
    triggerCameraShake(2 + player.attackCombo, 0.1)
    
    -- Update combo counter
    comboCounter = comboCounter + 1
    if comboCounter > maxCombo then
        maxCombo = comboCounter
    end
    
    -- Check if enemy is defeated
    if enemy.health <= 0 then
        enemy.state = "dying"
        enemy.deathTimer = 0.5
        score = score + enemy.points * (1 + comboCounter * 0.1)
        player.superMeter = math.min(player.maxSuperMeter, player.superMeter + 10)
        coins = coins + math.random(1, 3)
        
        -- Chance to drop pickup
        if math.random() < 0.3 then
            createPickup(enemy.x + enemy.width/2, enemy.y + enemy.height)
        end
    end
end

function hitBoss(damage, direction)
    boss.health = boss.health - damage
    boss.state = "hit"
    boss.hitTimer = 0.3
    
    -- Boss takes less knockback
    boss.knockback = direction * 5
    
    -- Effects
    player.hitStun = 0.08
    triggerCameraShake(5, 0.2)
    
    comboCounter = comboCounter + 1
    if comboCounter > maxCombo then
        maxCombo = comboCounter
    end
    
    -- Check boss phases
    updateBossPhase()
    
    if boss.health <= 0 then
        boss.state = "dying"
        boss.deathTimer = 2
        score = score + boss.points
        coins = coins + 50
        player.superMeter = player.maxSuperMeter
        
        -- Trigger stage clear after delay
        gameState = "stage_clear"
        initStageClear()
    end
end

function damagePlayer(damage, source)
    if player.invulnerable > 0 or player.state == "dodging" then return end
    
    player.health = player.health - damage
    player.state = "hit"
    player.attackCooldown = 0.5
    player.invulnerable = 1.5
    player.hitFlashTimer = 0.3
    
    -- Knockback away from enemy
    local knockbackDir = (player.x - source.x) > 0 and 1 or -1
    player.knockback = knockbackDir * 8
    
    -- Reset combo
    comboCounter = 0
    
    -- Drop weapon if holding one
    if player.weapon and player.weapon ~= "none" then
        dropWeapon()
    end
    
    -- Camera shake
    triggerCameraShake(5, 0.2)
    
    -- Check for death
    if player.health <= 0 then
        playerLives = playerLives - 1
        
        if playerLives <= 0 then
            gameState = "game_over"
            initGameOver()
        else
            -- Respawn with full health
            player.health = player.maxHealth
            player.invulnerable = 3
            player.x = getCameraX() + 100
        end
    end
end

function checkAttackCollision(attacker, target)
    local attackRange = attacker.attackRange or 50
    
    -- Check if targets are on similar Y plane (beat 'em up style)
    if math.abs(attacker.y - target.y) > 40 then
        return false
    end
    
    -- Check horizontal attack range based on direction
    if attacker.direction == 1 then
        -- Attacking right
        return target.x > attacker.x + attacker.width - 10 and
               target.x < attacker.x + attacker.width + attackRange
    else
        -- Attacking left
        return target.x + target.width > attacker.x - attackRange and
               target.x + target.width < attacker.x + 10
    end
end

function checkCollision(a, b)
    return a.x < b.x + b.width and
           a.x + a.width > b.x and
           a.y < b.y + b.height and
           a.y + a.height > b.y
end

function drawPauseMenu()
    -- Darken screen
    love.graphics.setColor(0, 0, 0, 0.7)
    love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
    
    -- Pause menu
    love.graphics.setColor(1, 1, 1)
    love.graphics.setNewFont(40)
    love.graphics.print("PAUSED", 330, 200)
    
    love.graphics.setNewFont(20)
    love.graphics.print("Press ESC to Resume", 290, 300)
    love.graphics.print("Press Q to Quit to Title", 280, 350)
    
    -- Show controls
    love.graphics.print("Controls:", 100, 450)
    love.graphics.print("Arrow Keys - Move", 100, 480)
    love.graphics.print("Z - Attack  X - Jump  C - Special  V - Throw", 100, 510)
end

function initEnding()
    -- Victory screen initialization
    endingTimer = 8
end

function updateEnding(dt)
    endingTimer = endingTimer - dt
    if endingTimer <= 0 then
        gameState = "title"
        initTitleScreen()
    end
end

function drawEnding()
    -- Victory screen
    love.graphics.setColor(0.1, 0.1, 0.2)
    love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
    
    love.graphics.setColor(1, 1, 1)
    love.graphics.setNewFont(50)
    love.graphics.print("HELL REDEEMED!", 200, 100)
    
    love.graphics.setNewFont(30)
    love.graphics.print("Jesus has saved the damned!", 180, 200)
    
    love.graphics.setNewFont(20)
    love.graphics.print("Final Score: " .. score, 320, 300)
    love.graphics.print("Max Combo: " .. maxCombo, 320, 330)
    love.graphics.print("Souls Saved: " .. coins, 320, 360)
    
    -- Draw Jesus ascending with light rays
    local jesusY = 450 - (8 - endingTimer) * 40
    
    -- Light rays
    love.graphics.setColor(1, 1, 0.5, 0.3)
    for i = 1, 8 do
        local angle = i * math.pi / 4
        local x1 = 400 + math.cos(angle) * 500
        local y1 = jesusY + math.sin(angle) * 500
        love.graphics.polygon("fill", 400, jesusY, x1, y1, x1 + 20, y1)
    end
    
    -- Jesus
    love.graphics.setColor(1, 1, 1)
    love.graphics.rectangle("fill", 380, jesusY, 40, 80)
    
    -- Halo
    love.graphics.setColor(1, 1, 0)
    love.graphics.circle("line", 400, jesusY - 10, 20)
    love.graphics.setColor(1, 1, 0, 0.5)
    love.graphics.circle("fill", 400, jesusY - 10, 20)
end