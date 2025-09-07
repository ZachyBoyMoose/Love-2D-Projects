-- hazard.lua
-- Stage-specific hazards
hazards = {}

function initHazards()
    hazards = {}
    
    if currentStage == 1 then
        -- Sewer grates that burst with steam
        for i = 0, 4 do
            table.insert(hazards, {
                type = "sewer_burst",
                x = 300 + i * 600,
                y = getFloorHeight(),
                width = 50,
                height = 100,
                active = true,
                damage = 15,
                timer = math.random(2, 4),
                cooldown = math.random(3, 5),
                maxCooldown = math.random(3, 5),
                warning = false,
                warningTimer = 0
            })
        end
        
        -- Flaming trash areas
        for i = 0, 3 do
            table.insert(hazards, {
                type = "fire_zone",
                x = 500 + i * 800,
                y = getFloorHeight() - 20,
                width = 80,
                height = 40,
                active = true,
                damage = 5,
                timer = 0
            })
        end
    elseif currentStage == 2 then
        -- Coin conveyor rivers
        for i = 0, 5 do
            table.insert(hazards, {
                type = "coin_river",
                x = 200 + i * 600,
                y = getFloorHeight() + 10,
                width = 300,
                height = 20,
                active = true,
                damage = 0,
                direction = i % 2 == 0 and 1 or -1,
                speed = 100
            })
        end
        
        -- Roulette wheels that can fling
        for i = 0, 3 do
            table.insert(hazards, {
                type = "roulette_wheel",
                x = 450 + i * 700,
                y = getFloorHeight() + 20,
                width = 80,
                height = 80,
                active = true,
                damage = 10,
                spin = 0,
                spinSpeed = 3
            })
        end
    elseif currentStage == 3 then
        -- Lava vents
        for i = 0, 3 do
            table.insert(hazards, {
                type = "lava_vent",
                x = 400 + i * 800,
                y = getFloorHeight() + 10,
                width = 150,
                height = 50,
                active = true,
                damage = 50,
                timer = 0,
                erupting = false,
                eruptTimer = 0,
                warningTimer = 0
            })
        end
        
        -- Bone pendulums
        for i = 0, 2 do
            table.insert(hazards, {
                type = "bone_pendulum",
                x = 700 + i * 900,
                y = 200,
                width = 50,
                height = 50,
                active = true,
                damage = 25,
                angle = 0,
                swingSpeed = 1.5,
                ropeLength = 150
            })
        end
    end
end

function updateHazards(dt)
    for i, hazard in ipairs(hazards) do
        if hazard.active then
            updateHazard(hazard, dt)
        end
    end
end

function updateHazard(hazard, dt)
    if hazard.type == "sewer_burst" then
        hazard.timer = hazard.timer - dt
        
        -- Warning phase
        if hazard.timer <= 1 and not hazard.warning then
            hazard.warning = true
            hazard.warningTimer = 1
        end
        
        if hazard.warning then
            hazard.warningTimer = hazard.warningTimer - dt
        end
        
        -- Burst phase
        if hazard.timer <= 0 then
            if hazard.timer > -0.5 then
                -- Damage during burst
                hazard.height = 100
            else
                -- Reset
                hazard.timer = hazard.maxCooldown
                hazard.warning = false
                hazard.height = 0
                triggerCameraShake(3, 0.2)
            end
        end
        
    elseif hazard.type == "coin_river" then
        -- Move anything on the conveyor
        -- Handled in collision detection
        
    elseif hazard.type == "roulette_wheel" then
        hazard.spin = hazard.spin + hazard.spinSpeed * dt
        
    elseif hazard.type == "lava_vent" then
        hazard.timer = hazard.timer + dt
        
        -- Eruption cycle
        if hazard.timer > 4 then
            if not hazard.erupting then
                hazard.erupting = true
                hazard.eruptTimer = 1.5
                hazard.warningTimer = 0.5
            end
        end
        
        if hazard.erupting then
            hazard.warningTimer = hazard.warningTimer - dt
            hazard.eruptTimer = hazard.eruptTimer - dt
            
            if hazard.eruptTimer <= 0 then
                hazard.erupting = false
                hazard.timer = 0
            end
        end
        
    elseif hazard.type == "bone_pendulum" then
        hazard.angle = math.sin(love.timer.getTime() * hazard.swingSpeed) * math.pi / 3
        -- Update position based on angle
        local pendulumX = hazard.x + math.sin(hazard.angle) * hazard.ropeLength
        local pendulumY = hazard.y + math.cos(hazard.angle) * hazard.ropeLength
        hazard.currentX = pendulumX
        hazard.currentY = pendulumY
    end
end

function drawHazards()
    for i, hazard in ipairs(hazards) do
        if hazard.active then
            drawHazard(hazard)
        end
    end
end

function drawHazard(hazard)
    if hazard.type == "sewer_burst" then
        -- Grate
        love.graphics.setColor(0.2, 0.2, 0.2)
        love.graphics.rectangle("fill", hazard.x, hazard.y, hazard.width, 10)
        
        -- Grate holes
        love.graphics.setColor(0, 0, 0)
        for i = 0, 4 do
            love.graphics.rectangle("fill", hazard.x + 5 + i * 9, hazard.y + 2, 6, 6)
        end
        
        -- Warning steam
        if hazard.warning and hazard.warningTimer > 0 then
            love.graphics.setColor(0.7, 0.7, 0.7, 0.5 * hazard.warningTimer)
            for s = 0, 2 do
                love.graphics.circle("fill", hazard.x + 10 + s * 15, hazard.y - 10 - s * 5, 5)
            end
        end
        
        -- Steam burst
        if hazard.timer <= 0 and hazard.timer > -0.5 then
            love.graphics.setColor(0.8, 0.8, 0.8, 0.7)
            love.graphics.rectangle("fill", hazard.x, hazard.y - 100, hazard.width, 100)
            
            -- Hot steam particles
            for p = 0, 5 do
                local px = hazard.x + math.random(hazard.width)
                local py = hazard.y - math.random(100)
                love.graphics.circle("fill", px, py, math.random(3, 8))
            end
        end
        
    elseif hazard.type == "fire_zone" then
        -- Burning area
        for f = 0, 3 do
            local flameX = hazard.x + f * 20
            local flameHeight = 20 + math.sin(love.timer.getTime() * 8 + f) * 10
            love.graphics.setColor(1, 0.5, 0, 0.8)
            love.graphics.polygon("fill",
                flameX, hazard.y + hazard.height,
                flameX + 10, hazard.y + hazard.height - flameHeight,
                flameX + 20, hazard.y + hazard.height
            )
            love.graphics.setColor(1, 0.8, 0, 0.6)
            love.graphics.polygon("fill",
                flameX + 5, hazard.y + hazard.height,
                flameX + 10, hazard.y + hazard.height - flameHeight * 0.7,
                flameX + 15, hazard.y + hazard.height
            )
        end
        
    elseif hazard.type == "coin_river" then
        -- Conveyor effect
        love.graphics.setColor(0.9, 0.9, 0.1, 0.4)
        love.graphics.rectangle("fill", hazard.x, hazard.y, hazard.width, hazard.height)
        
        -- Moving coins
        love.graphics.setColor(0.8, 0.8, 0)
        for c = 0, 15 do
            local coinX = hazard.x + (c * 20 + love.timer.getTime() * hazard.speed * hazard.direction) % hazard.width
            love.graphics.circle("fill", coinX, hazard.y + 10, 5)
            love.graphics.setColor(0.6, 0.6, 0)
            love.graphics.print("$", coinX - 3, hazard.y + 5)
            love.graphics.setColor(0.8, 0.8, 0)
        end
        
        -- Direction arrow
        love.graphics.setColor(1, 1, 0, 0.5)
        local arrowX = hazard.x + hazard.width / 2
        if hazard.direction > 0 then
            love.graphics.polygon("fill",
                arrowX - 20, hazard.y + 10,
                arrowX + 20, hazard.y + 10,
                arrowX + 10, hazard.y + 5,
                arrowX + 30, hazard.y + 10,
                arrowX + 10, hazard.y + 15
            )
        else
            love.graphics.polygon("fill",
                arrowX + 20, hazard.y + 10,
                arrowX - 20, hazard.y + 10,
                arrowX - 10, hazard.y + 5,
                arrowX - 30, hazard.y + 10,
                arrowX - 10, hazard.y + 15
            )
        end
        
    elseif hazard.type == "roulette_wheel" then
        -- Spinning wheel is drawn in stage
        
    elseif hazard.type == "lava_vent" then
        -- Lava pool
        love.graphics.setColor(0.8, 0.1, 0.1)
        love.graphics.ellipse("fill", hazard.x + hazard.width/2, hazard.y + hazard.height/2, hazard.width/2, hazard.height/2)
        
        -- Warning bubbles
        if hazard.warningTimer > 0 then
            love.graphics.setColor(1, 0.5, 0)
            for b = 0, 3 do
                local bubbleSize = 5 + (0.5 - hazard.warningTimer) * 10
                love.graphics.circle("fill", 
                    hazard.x + hazard.width/4 + b * hazard.width/4,
                    hazard.y + hazard.height/2,
                    bubbleSize
                )
            end
        end
        
        -- Eruption
        if hazard.erupting and hazard.eruptTimer > 0 then
            love.graphics.setColor(1, 0.3, 0.1)
            local eruptHeight = 150 * (hazard.eruptTimer / 1.5)
            love.graphics.rectangle("fill", hazard.x, hazard.y - eruptHeight, hazard.width, eruptHeight)
            
            -- Lava drops
            for d = 0, 8 do
                local dropX = hazard.x + math.random(hazard.width)
                local dropY = hazard.y - math.random(eruptHeight)
                love.graphics.circle("fill", dropX, dropY, math.random(3, 8))
            end
        end
        
    elseif hazard.type == "bone_pendulum" then
        -- Pendulum is drawn in stage, this just shows danger zone
        if hazard.currentX and hazard.currentY then
            -- Danger indicator
            local alpha = 0.3 + math.abs(math.sin(love.timer.getTime() * 3)) * 0.2
            love.graphics.setColor(1, 0, 0, alpha)
            love.graphics.circle("fill", hazard.currentX, hazard.currentY, hazard.width/2)
        end
    end
end

function checkHazardCollision(hazard, entity)
    if hazard.type == "bone_pendulum" and hazard.currentX and hazard.currentY then
        -- Use current pendulum position
        local dist = math.sqrt((entity.x + entity.width/2 - hazard.currentX)^2 + 
                              (entity.y + entity.height/2 - hazard.currentY)^2)
        return dist < hazard.width/2 + entity.width/2
    else
        -- Standard box collision
        return entity.x < hazard.x + hazard.width and
               entity.x + entity.width > hazard.x and
               entity.y < hazard.y + hazard.height and
               entity.y + entity.height > hazard.y
    end
end

function handleHazardDamage(hazard, entity)
    if hazard.type == "sewer_burst" then
        if hazard.timer <= 0 and hazard.timer > -0.5 then
            -- Apply damage and knockback during burst
            if entity == player and player.invulnerable <= 0 then
                player.health = player.health - hazard.damage
                player.knockback = -10
                player.invulnerable = 1
            elseif entity.health then
                entity.health = entity.health - hazard.damage
                entity.knockback = -10
            end
        end
        
    elseif hazard.type == "fire_zone" then
        -- Continuous damage while in fire
        if entity == player and player.invulnerable <= 0 then
            player.health = player.health - hazard.damage * love.timer.getDelta()
            if math.random() < 0.01 then
                player.invulnerable = 0.5
            end
        elseif entity.health then
            entity.health = entity.health - hazard.damage * love.timer.getDelta()
        end
        
    elseif hazard.type == "coin_river" then
        -- Push entity along conveyor
        entity.x = entity.x + hazard.direction * hazard.speed * love.timer.getDelta()
        
    elseif hazard.type == "roulette_wheel" then
        -- Fling entity if on wheel
        local angle = hazard.spin
        local flingX = math.cos(angle) * 15
        local flingY = math.sin(angle) * 15
        
        if entity == player then
            player.knockback = flingX
            if math.random() < 0.05 then
                player.jumpVelocity = -200
                player.isGrounded = false
            end
        else
            entity.knockback = flingX
        end
        
    elseif hazard.type == "lava_vent" then
        if hazard.erupting and hazard.eruptTimer > 0 then
            -- Massive damage from lava
            if entity == player and player.invulnerable <= 0 then
                player.health = player.health - hazard.damage
                player.invulnerable = 2
                player.knockback = math.random(-20, 20)
                player.jumpVelocity = -300
                player.isGrounded = false
            elseif entity.health then
                entity.health = entity.health - hazard.damage
                entity.state = "dying"
            end
        end
        
    elseif hazard.type == "bone_pendulum" then
        -- Knock entity away from pendulum
        if entity == player and player.invulnerable <= 0 then
            player.health = player.health - hazard.damage
            player.invulnerable = 1.5
            local knockDir = (player.x - hazard.currentX) > 0 and 1 or -1
            player.knockback = knockDir * 20
            player.jumpVelocity = -250
            player.isGrounded = false
        elseif entity.health then
            entity.health = entity.health - hazard.damage
            entity.knockback = ((entity.x - hazard.currentX) > 0 and 1 or -1) * 20
        end
    end
end

function createWaveHazard(hazardType, cameraX, screenWidth)
    if hazardType == "sewer_burst" then
        table.insert(hazards, {
            type = "sewer_burst",
            x = cameraX + screenWidth/2,
            y = getFloorHeight(),
            width = 50,
            height = 100,
            active = true,
            damage = 15,
            timer = 2,
            cooldown = 4,
            maxCooldown = 4,
            warning = false,
            warningTimer = 0
        })
    elseif hazardType == "coin_river" then
        table.insert(hazards, {
            type = "coin_river",
            x = cameraX + 100,
            y = getFloorHeight() + 10,
            width = screenWidth - 200,
            height = 20,
            active = true,
            damage = 0,
            direction = math.random() > 0.5 and 1 or -1,
            speed = 120
        })
    elseif hazardType == "roulette_wheel" then
        table.insert(hazards, {
            type = "roulette_wheel",
            x = cameraX + screenWidth/2 - 40,
            y = getFloorHeight() + 20,
            width = 80,
            height = 80,
            active = true,
            damage = 10,
            spin = 0,
            spinSpeed = 4
        })
    elseif hazardType == "lava_vent" then
        table.insert(hazards, {
            type = "lava_vent",
            x = cameraX + screenWidth/2 - 75,
            y = getFloorHeight() + 10,
            width = 150,
            height = 50,
            active = true,
            damage = 50,
            timer = 2,
            erupting = false,
            eruptTimer = 0,
            warningTimer = 0
        })
    elseif hazardType == "bone_pendulum" then
        table.insert(hazards, {
            type = "bone_pendulum",
            x = cameraX + screenWidth/2,
            y = 200,
            width = 50,
            height = 50,
            active = true,
            damage = 25,
            angle = 0,
            swingSpeed = 2,
            ropeLength = 150
        })
    end
end