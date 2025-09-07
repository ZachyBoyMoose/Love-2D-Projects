-- player.lua
-- Jesus player character with throws, weapons, and special moves
player = {
    x = 100,
    y = 0,
    width = 40,
    height = 80,
    speed = 200,
    health = 100,
    maxHealth = 100,
    state = "idle",
    direction = 1,
    attackCooldown = 0,
    attackCombo = 0,
    attackDamage = 10,
    jumpVelocity = 0,
    jumpHeight = -400,
    isGrounded = true,
    superMeter = 0,
    maxSuperMeter = 100,
    invulnerable = 0,
    knockback = 0,
    comboResetTimer = 0,
    hitStun = 0,
    hitFlashTimer = 0,
    attackRange = 60,
    grabbedEnemy = nil,
    throwCooldown = 0,
    weapon = "none",
    weaponUses = 0,
    dodgeTimer = 0,
    specialMove = "none",
    animFrame = 0,
    animTimer = 0,
    walkFrame = 0,
    depth = 0,
    canMove = true,
}

function initPlayer()
    local stage = stages[currentStage]
    player.x = 100
    player.y = stage.floorHeight - player.height
    player.depth = 0
    player.health = player.maxHealth
    player.state = "idle"
    player.direction = 1
    player.attackCooldown = 0
    player.attackCombo = 0
    player.jumpVelocity = 0
    player.isGrounded = true
    player.superMeter = 0
    player.invulnerable = 0
    player.knockback = 0
    player.comboResetTimer = 0
    player.hitStun = 0
    player.hitFlashTimer = 0
    player.grabbedEnemy = nil
    player.throwCooldown = 0
    player.weapon = "none"
    player.weaponUses = 0
    player.dodgeTimer = 0
    player.animFrame = 0
    player.animTimer = 0
    player.walkFrame = 0
    player.canMove = true
    
    -- Ensure player is on screen
    if player.y < getFloorHeight() - player.height then
        player.y = getFloorHeight() - player.height
    end
end

function updatePlayer(dt)
    -- Update animation timer
    player.animTimer = player.animTimer + dt
    if player.animTimer > 0.1 then
        player.animTimer = 0
        player.animFrame = (player.animFrame + 1) % 4
    end
    
    -- Update invulnerability
    if player.invulnerable > 0 then
        player.invulnerable = player.invulnerable - dt
    end
    
    -- Update hit stun
    if player.hitStun > 0 then
        player.hitStun = player.hitStun - dt
        return
    end
    
    -- Update throw cooldown
    if player.throwCooldown > 0 then
        player.throwCooldown = player.throwCooldown - dt
    end
    
    -- Update dodge timer
    if player.dodgeTimer > 0 then
        player.dodgeTimer = player.dodgeTimer - dt
        if player.dodgeTimer <= 0 then
            player.state = "idle"
            player.canMove = true
        end
    end
    
    -- Update combo timer
    if player.comboResetTimer > 0 then
        player.comboResetTimer = player.comboResetTimer - dt
        if player.comboResetTimer <= 0 then
            player.attackCombo = 0
        end
    end
    
    -- Apply knockback
    if player.knockback ~= 0 then
        player.x = player.x + player.knockback * dt * 60
        player.knockback = player.knockback * (1 - dt * 10)
        if math.abs(player.knockback) < 1 then player.knockback = 0 end
    end
    
    -- Update jump physics
    if not player.isGrounded then
        player.jumpVelocity = player.jumpVelocity + 800 * dt
        player.y = player.y + player.jumpVelocity * dt
        
        if player.y >= getFloorHeight() - player.height then
            player.y = getFloorHeight() - player.height
            player.isGrounded = true
            player.jumpVelocity = 0
            if player.state == "jumping" then
                player.state = "idle"
            end
        end
    end
    
    -- State machine
    if player.state == "attacking" then
        updateAttackState(dt)
    elseif player.state == "throwing" then
        updateThrowState(dt)
    elseif player.state == "grabbing" then
        updateGrabState(dt)
    elseif player.state == "hit" then
        updateHitState(dt)
    elseif player.state == "dodging" then
        -- Dodge movement handled above
    else
        if player.canMove then
            updateMovement(dt)
        end
    end
    
    -- Constrain to stage bounds
    constrainPlayerPosition()
    
    -- Build super meter gradually
    if player.state == "idle" or player.state == "walking" then
        player.superMeter = math.min(player.maxSuperMeter, player.superMeter + dt * 2)
    end
end

function updateMovement(dt)
    local moveX = 0
    local moveY = 0
    
    -- Get input
    if love.keyboard.isDown("left") then
        moveX = -1
        player.direction = -1
        player.walkFrame = (player.walkFrame + dt * 10) % 4
    elseif love.keyboard.isDown("right") then
        moveX = 1
        player.direction = 1
        player.walkFrame = (player.walkFrame + dt * 10) % 4
    end
    
    if love.keyboard.isDown("up") then
        moveY = -1
    elseif love.keyboard.isDown("down") then
        moveY = 1
    end
    
    -- Apply movement
    player.x = player.x + moveX * player.speed * dt
    player.depth = player.depth + moveY * 50 * dt
    
    -- Update state
    if moveX ~= 0 or moveY ~= 0 then
        player.state = "walking"
    else
        player.state = "idle"
        player.walkFrame = 0
    end
end

function updateAttackState(dt)
    player.attackCooldown = player.attackCooldown - dt
    
    if player.attackCooldown <= 0 then
        player.state = "idle"
        player.comboResetTimer = 0.5
        player.canMove = true
    end
end

function updateThrowState(dt)
    player.attackCooldown = player.attackCooldown - dt
    
    if player.attackCooldown <= 0 then
        player.state = "idle"
        player.canMove = true
    end
end

function updateGrabState(dt)
    if player.grabbedEnemy and player.grabbedEnemy.active then
        -- Move enemy with player
        player.grabbedEnemy.x = player.x + (player.direction * 30)
        player.grabbedEnemy.y = player.y
    else
        player.state = "idle"
        player.grabbedEnemy = nil
        player.canMove = true
    end
end

function updateHitState(dt)
    player.attackCooldown = player.attackCooldown - dt
    
    if player.attackCooldown <= 0 then
        player.state = "idle"
        player.canMove = true
    end
end

function constrainPlayerPosition()
    local stageWidth = getCurrentStageWidth()
    local floorHeight = getFloorHeight()
    
    -- Horizontal constraints
    player.x = math.max(0, math.min(stageWidth - player.width, player.x))
    
    -- Depth constraints (Y-axis movement in beat-em-up)
    player.depth = math.max(-50, math.min(50, player.depth))
    
    -- Update Y position based on floor and depth
    player.y = floorHeight - player.height + player.depth
end

function drawPlayer()
    -- Skip drawing if invulnerable and blinking
    if player.invulnerable > 0 and math.floor(player.invulnerable * 10) % 2 == 0 then
        return
    end
    
    love.graphics.push()
    love.graphics.translate(player.x, player.y)
    
    -- Flip based on direction
    if player.direction == -1 then
        love.graphics.scale(-1, 1)
        love.graphics.translate(-player.width, 0)
    end
    
    -- Flash white when hit
    if player.hitFlashTimer > 0 then
        love.graphics.setColor(1, 1, 1)
        player.hitFlashTimer = player.hitFlashTimer - 0.016
    else
        love.graphics.setColor(1, 1, 1)
    end
    
    drawPlayerSprite()
    
    -- Draw weapon if equipped
    if player.weapon ~= "none" and player.state == "attacking" then
        drawPlayerWeapon()
    end
    
    love.graphics.pop()
end

function drawPlayerSprite()
    -- Body (white robe)
    love.graphics.setColor(1, 1, 1)
    love.graphics.rectangle("fill", player.width/4, 25, player.width/2, player.height*0.45)
    
    -- Red sash
    love.graphics.setColor(0.8, 0, 0)
    love.graphics.rectangle("fill", player.width/4 - 2, player.height*0.5, player.width/2 + 4, 6)
    
    -- Lower robe
    love.graphics.setColor(1, 1, 1)
    love.graphics.polygon("fill", 
        player.width/4, player.height*0.5 + 6,
        player.width*3/4, player.height*0.5 + 6,
        player.width*3/4 + 5, player.height - 5,
        player.width/4 - 5, player.height - 5
    )
    
    -- Head
    love.graphics.setColor(0.9, 0.8, 0.7)
    love.graphics.circle("fill", player.width/2, 15, 10)
    
    -- Hair
    love.graphics.setColor(0.4, 0.3, 0.2)
    love.graphics.arc("fill", player.width/2, 15, 11, -math.pi, 0)
    
    -- Beard
    love.graphics.setColor(0.4, 0.3, 0.2)
    love.graphics.polygon("fill",
        player.width/2 - 6, 20,
        player.width/2 + 6, 20,
        player.width/2, 28
    )
    
    -- Eyes
    love.graphics.setColor(0, 0, 0)
    love.graphics.circle("fill", player.width/2 - 3, 13, 1)
    love.graphics.circle("fill", player.width/2 + 3, 13, 1)
    
    -- Halo (glowing)
    local haloGlow = 0.7 + math.sin(love.timer.getTime() * 3) * 0.3
    love.graphics.setColor(1, 1, 0, haloGlow)
    love.graphics.circle("line", player.width/2, -5, 12)
    love.graphics.setColor(1, 1, 0, haloGlow * 0.3)
    love.graphics.circle("fill", player.width/2, -5, 12)
    
    -- Arms based on state
    love.graphics.setColor(0.9, 0.8, 0.7)
    if player.state == "attacking" then
        -- Punch animation based on combo
        local punchExtend = 20 + player.attackCombo * 10
        love.graphics.rectangle("fill", player.width - 5, 30, punchExtend, 6)
        love.graphics.circle("fill", player.width + punchExtend - 5, 33, 4)
    elseif player.state == "grabbing" then
        -- Grabbing pose
        love.graphics.rectangle("fill", player.width - 10, 28, 15, 6)
        love.graphics.rectangle("fill", player.width - 10, 36, 15, 6)
    elseif player.state == "walking" then
        -- Walking arm swing
        local armSwing = math.sin(player.walkFrame * math.pi / 2) * 10
        love.graphics.rectangle("fill", 5, 30 + armSwing, 6, 20)
        love.graphics.rectangle("fill", player.width - 11, 30 - armSwing, 6, 20)
    else
        -- Normal arms
        love.graphics.rectangle("fill", 5, 30, 6, 20)
        love.graphics.rectangle("fill", player.width - 11, 30, 6, 20)
    end
    
    -- Hands
    love.graphics.circle("fill", 8, 50, 3)
    love.graphics.circle("fill", player.width - 8, 50, 3)
    
    -- Legs with walking animation
    love.graphics.setColor(0.9, 0.8, 0.7)
    if player.state == "walking" then
        local legOffset = math.sin(player.walkFrame * math.pi) * 5
        love.graphics.rectangle("fill", player.width/3 - 2, player.height*0.7, 4, player.height*0.25 - legOffset)
        love.graphics.rectangle("fill", player.width*2/3 - 2, player.height*0.7, 4, player.height*0.25 + legOffset)
    else
        love.graphics.rectangle("fill", player.width/3 - 2, player.height*0.7, 4, player.height*0.25)
        love.graphics.rectangle("fill", player.width*2/3 - 2, player.height*0.7, 4, player.height*0.25)
    end
    
    -- Sandals
    love.graphics.setColor(0.4, 0.3, 0.2)
    love.graphics.rectangle("fill", player.width/3 - 4, player.height - 4, 8, 4)
    love.graphics.rectangle("fill", player.width*2/3 - 4, player.height - 4, 8, 4)
end

function drawPlayerWeapon()
    if player.weapon == "thorned_knuckle" then
        love.graphics.setColor(0.5, 0.3, 0.2)
        love.graphics.rectangle("fill", player.width, 28, 10, 10)
        -- Thorns
        love.graphics.setColor(0.7, 0.7, 0.7)
        for i = 0, 2 do
            love.graphics.polygon("fill", 
                player.width + 10 + i*3, 30,
                player.width + 12 + i*3, 28,
                player.width + 11 + i*3, 33
            )
        end
    elseif player.weapon == "holy_staff" then
        love.graphics.setColor(0.8, 0.6, 0.3)
        love.graphics.rectangle("fill", player.width, 25, 40, 4)
        -- Cross at end
        love.graphics.setColor(1, 1, 0)
        love.graphics.rectangle("fill", player.width + 35, 20, 3, 15)
        love.graphics.rectangle("fill", player.width + 30, 25, 13, 3)
    end
end

function handlePlayerInput(key, pressed)
    if pressed then
        -- Prevent input during hit stun or certain states
        if player.hitStun > 0 or not player.canMove then return end
        
        if key == "z" and player.state ~= "hit" then
            performAttack()
        elseif key == "x" and player.isGrounded and player.state ~= "hit" then
            performJump()
        elseif key == "c" and player.superMeter >= player.maxSuperMeter then
            performSuper()
        elseif key == "v" and player.throwCooldown <= 0 then
            attemptGrab()
        elseif key == "lshift" and player.state == "idle" or player.state == "walking" then
            performDodge()
        end
    end
end

function performAttack()
    if player.state == "grabbing" and player.grabbedEnemy then
        -- Throw the grabbed enemy
        throwEnemy()
        return
    end
    
    if player.state == "attacking" and player.comboResetTimer > 0 then
        -- Continue combo
        player.attackCombo = math.min(player.attackCombo + 1, 3)
    else
        -- Start new combo
        player.attackCombo = 1
    end
    
    player.state = "attacking"
    player.attackCooldown = 0.3
    player.comboResetTimer = 0
    player.canMove = false
    
    -- Weapon modifier
    local weaponBonus = 0
    if player.weapon == "thorned_knuckle" then
        weaponBonus = 10
    elseif player.weapon == "holy_staff" then
        weaponBonus = 15
        player.attackRange = 80
    end
    
    -- Different damage for combo hits
    if player.attackCombo == 1 then
        player.attackDamage = 10 + weaponBonus
    elseif player.attackCombo == 2 then
        player.attackDamage = 15 + weaponBonus
    else
        player.attackDamage = 25 + weaponBonus
        triggerCameraShake(5, 0.2)
    end
    
    -- Use up weapon durability
    if player.weapon ~= "none" then
        player.weaponUses = player.weaponUses - 1
        if player.weaponUses <= 0 then
            player.weapon = "none"
            player.attackRange = 60
        end
    end
end

function performJump()
    player.state = "jumping"
    player.isGrounded = false
    player.jumpVelocity = player.jumpHeight
end

function performDodge()
    player.state = "dodging"
    player.dodgeTimer = 0.3
    player.invulnerable = 0.3
    player.canMove = false
    
    -- Quick backstep
    player.knockback = -player.direction * 15
end

function attemptGrab()
    -- Check for nearby enemy
    for _, enemy in ipairs(enemies) do
        if enemy.active and enemy.state ~= "dying" then
            local dist = math.abs(player.x - enemy.x)
            local yDist = math.abs(player.y - enemy.y)
            
            if dist < 50 and yDist < 30 and not enemy.ungrabable then
                -- Grab the enemy
                player.state = "grabbing"
                player.grabbedEnemy = enemy
                enemy.state = "grabbed"
                player.throwCooldown = 1.0
                player.canMove = false
                return
            end
        end
    end
    
    -- No enemy to grab, do a grab animation
    player.state = "grabbing"
    player.attackCooldown = 0.2
    player.canMove = false
end

function throwEnemy()
    if not player.grabbedEnemy then return end
    
    local enemy = player.grabbedEnemy
    player.state = "throwing"
    player.attackCooldown = 0.4
    
    -- Throw the enemy
    enemy.state = "thrown"
    enemy.knockback = player.direction * 30
    enemy.jumpVelocity = -200
    enemy.isGrounded = false
    enemy.health = enemy.health - 20
    
    -- Check if it hits other enemies
    for _, otherEnemy in ipairs(enemies) do
        if otherEnemy ~= enemy and otherEnemy.active then
            local dist = math.abs(enemy.x - otherEnemy.x)
            if dist < 100 then
                otherEnemy.health = otherEnemy.health - 15
                otherEnemy.state = "hit"
                otherEnemy.knockback = player.direction * 15
            end
        end
    end
    
    player.grabbedEnemy = nil
    triggerCameraShake(8, 0.3)
end

function performSuper()
    player.state = "super"
    player.attackCooldown = 1
    player.invulnerable = 1
    player.canMove = false
    activateSuperMove()
end

function activateSuperMove()
    -- Divine Wrath - holy explosion
    createHolyExplosion(player.x + player.width/2, player.y + player.height/2)
    
    -- Damage all enemies on screen
    for i, enemy in ipairs(enemies) do
        if enemy.active and enemy.state ~= "dying" then
            if isOnScreen(enemy.x, enemy.y, enemy.width, enemy.height) then
                local damage = 50
                enemy.health = enemy.health - damage
                enemy.knockback = (enemy.x - player.x) > 0 and 20 or -20
                enemy.state = "hit"
                
                if enemy.health <= 0 then
                    enemy.state = "dying"
                    score = score + enemy.points
                end
            end
        end
    end
    
    -- Damage boss if on screen
    if boss.active and boss.state ~= "dying" then
        if isOnScreen(boss.x, boss.y, boss.width, boss.height) then
            boss.health = boss.health - 100
            boss.knockback = (boss.x - player.x) > 0 and 15 or -15
            boss.state = "hit"
            updateBossPhase()
            
            if boss.health <= 0 then
                boss.state = "dying"
                score = score + boss.points
                gameState = "stage_clear"
                initStageClear()
            end
        end
    end
    
    triggerCameraShake(20, 0.8)
    player.superMeter = 0
end

function dropWeapon()
    if player.weapon ~= "none" then
        createGroundWeapon(player.weapon, player.x, player.y + player.height, player.weaponUses)
        player.weapon = "none"
        player.weaponUses = 0
        player.attackRange = 60
    end
end

function createHolyExplosion(x, y)
    table.insert(effects, {
        type = "holy_explosion",
        x = x,
        y = y,
        radius = 10,
        maxRadius = 200,
        timer = 0.8,
        maxTimer = 0.8
    })
end