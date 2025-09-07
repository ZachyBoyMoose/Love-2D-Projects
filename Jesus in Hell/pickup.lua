-- pickup.lua
-- Pickups and healing items
pickups = {}

local pickupTypes = {
    -- Stage 1 pickups
    rosary = {
        width = 20, height = 20,
        healAmount = 20,
        color = {0.8, 0.8, 0.8},
        glow = {1, 1, 0},
        icon = "cross"
    },
    bread_fish = {
        width = 30, height = 25,
        healAmount = 50,
        color = {0.8, 0.7, 0.5},
        glow = {1, 1, 0.5},
        icon = "food"
    },
    
    -- Stage 2 pickups
    martini = {
        width = 15, height = 25,
        healAmount = 25,
        color = {0.9, 0.9, 0.9},
        glow = {1, 0.5, 0.5},
        icon = "glass"
    },
    miracle_loaf = {
        width = 35, height = 20,
        healAmount = 75,
        color = {0.9, 0.8, 0.6},
        glow = {1, 1, 0.3},
        icon = "loaf"
    },
    crown_thorns = {
        width = 30, height = 30,
        powerUp = "dash",
        duration = 10,
        color = {0.5, 0.3, 0.2},
        glow = {1, 0, 0},
        icon = "crown"
    },
    
    -- Stage 3 pickups
    chalice = {
        width = 20, height = 30,
        healAmount = 40,
        color = {0.9, 0.9, 0.1},
        glow = {1, 1, 0},
        icon = "chalice"
    },
    holy_upper = {
        width = 25, height = 25,
        powerUp = "damage_boost",
        duration = 15,
        color = {1, 1, 1},
        glow = {1, 1, 0},
        icon = "fist"
    },
    spirit_bomb = {
        width = 30, height = 30,
        superMeter = 100,
        color = {1, 1, 0},
        glow = {1, 1, 1},
        icon = "orb"
    }
}

function initPickups()
    pickups = {}
end

function createPickup(x, y, specificType)
    local type = specificType
    
    -- Random pickup if not specified
    if not type then
        local randomTypes = {"rosary", "martini", "chalice"}
        if currentStage == 1 then
            randomTypes = {"rosary", "bread_fish"}
        elseif currentStage == 2 then
            randomTypes = {"martini", "crown_thorns"}
        elseif currentStage == 3 then
            randomTypes = {"chalice", "holy_upper"}
        end
        type = randomTypes[math.random(#randomTypes)]
    end
    
    local def = pickupTypes[type]
    if not def then return end
    
    local pickup = {
        type = type,
        x = x - def.width/2,
        y = y - def.height,
        width = def.width,
        height = def.height,
        bounce = -200,
        timer = 0,
        collected = false
    }
    
    -- Copy properties
    for k, v in pairs(def) do
        if not pickup[k] then
            pickup[k] = v
        end
    end
    
    table.insert(pickups, pickup)
    return pickup
end

function updatePickups(dt)
    for i = #pickups, 1, -1 do
        local pickup = pickups[i]
        
        if pickup.collected then
            table.remove(pickups, i)
        else
            pickup.timer = pickup.timer + dt
            
            -- Bounce physics
            if pickup.bounce then
                pickup.bounce = pickup.bounce + 400 * dt
                pickup.y = pickup.y + pickup.bounce * dt
                
                if pickup.y >= getFloorHeight() - pickup.height then
                    pickup.y = getFloorHeight() - pickup.height
                    pickup.bounce = pickup.bounce * -0.5
                    
                    if math.abs(pickup.bounce) < 10 then
                        pickup.bounce = nil
                    end
                end
            end
            
            -- Float animation
            if not pickup.bounce then
                pickup.y = getFloorHeight() - pickup.height + math.sin(pickup.timer * 3) * 5
            end
            
            -- Remove after time
            if pickup.timer > 15 then
                table.remove(pickups, i)
            end
        end
    end
end

function drawPickups()
    for _, pickup in ipairs(pickups) do
        if not pickup.collected then
            love.graphics.push()
            love.graphics.translate(pickup.x + pickup.width/2, pickup.y + pickup.height/2)
            
            -- Glow effect
            local glowSize = 1 + math.sin(pickup.timer * 5) * 0.2
            love.graphics.setColor(pickup.glow[1], pickup.glow[2], pickup.glow[3], 0.3)
            love.graphics.circle("fill", 0, 0, pickup.width * glowSize)
            
            -- Draw pickup icon
            love.graphics.setColor(pickup.color)
            
            if pickup.icon == "cross" then
                -- Rosary cross
                love.graphics.rectangle("fill", -2, -10, 4, 20)
                love.graphics.rectangle("fill", -8, -5, 16, 4)
                
            elseif pickup.icon == "food" then
                -- Bread and fish
                love.graphics.ellipse("fill", -5, -5, 10, 5)
                love.graphics.polygon("fill", 0, 5, 10, 2, 10, 8, 5, 10)
                
            elseif pickup.icon == "glass" then
                -- Martini glass
                love.graphics.polygon("fill", -8, -10, 8, -10, 5, 0, -5, 0)
                love.graphics.rectangle("fill", -1, 0, 2, 8)
                love.graphics.rectangle("fill", -5, 8, 10, 2)
                
            elseif pickup.icon == "loaf" then
                -- Miracle loaf
                love.graphics.ellipse("fill", 0, 0, 15, 8)
                love.graphics.setColor(0.7, 0.6, 0.4)
                for i = -2, 2 do
                    love.graphics.line(i * 5, -5, i * 5, 5)
                end
                
            elseif pickup.icon == "crown" then
                -- Crown of thorns
                love.graphics.circle("line", 0, 0, 12)
                for i = 0, 7 do
                    local angle = i * math.pi / 4
                    local x1 = math.cos(angle) * 10
                    local y1 = math.sin(angle) * 10
                    local x2 = math.cos(angle) * 15
                    local y2 = math.sin(angle) * 15
                    love.graphics.line(x1, y1, x2, y2)
                end
                
            elseif pickup.icon == "chalice" then
                -- Holy chalice
                love.graphics.polygon("fill", -8, -10, 8, -10, 6, 0, -6, 0)
                love.graphics.rectangle("fill", -2, 0, 4, 10)
                love.graphics.ellipse("fill", 0, 10, 8, 3)
                
            elseif pickup.icon == "fist" then
                -- Holy upper fist
                love.graphics.circle("fill", 0, 0, 10)
                love.graphics.setColor(1, 1, 0)
                for i = 0, 4 do
                    local angle = i * math.pi * 2 / 5
                    love.graphics.line(0, 0, math.cos(angle) * 12, math.sin(angle) * 12)
                end
                
            elseif pickup.icon == "orb" then
                -- Spirit bomb orb
                love.graphics.circle("fill", 0, 0, 12)
                love.graphics.setColor(1, 1, 1, 0.5)
                love.graphics.circle("fill", 0, 0, 15)
                
            else
                -- Generic pickup
                love.graphics.rectangle("fill", -pickup.width/2, -pickup.height/2, pickup.width, pickup.height)
            end
            
            love.graphics.pop()
            
            -- Flashing effect when about to disappear
            if pickup.timer > 12 then
                if math.floor(pickup.timer * 8) % 2 == 0 then
                    love.graphics.setColor(1, 1, 1, 0.5)
                    love.graphics.rectangle("fill", pickup.x, pickup.y, pickup.width, pickup.height)
                end
            end
        end
    end
end

function applyPickup(pickup)
    pickup.collected = true
    
    -- Apply effects
    if pickup.healAmount then
        player.health = math.min(player.maxHealth, player.health + pickup.healAmount)
        -- Heal effect
        createHealEffect(player.x + player.width/2, player.y)
    end
    
    if pickup.superMeter then
        player.superMeter = math.min(player.maxSuperMeter, player.superMeter + pickup.superMeter)
        -- Power effect
        createPowerEffect(player.x + player.width/2, player.y)
    end
    
    if pickup.powerUp then
        applyPowerUp(pickup.powerUp, pickup.duration)
    end
    
    -- Score bonus
    score = score + 100
end

function applyPowerUp(type, duration)
    if type == "dash" then
        player.dashPower = true
        player.dashTimer = duration
    elseif type == "damage_boost" then
        player.damageBoost = 2
        player.boostTimer = duration
    end
end

function createHealEffect(x, y)
    table.insert(effects, {
        type = "heal",
        x = x,
        y = y,
        timer = 1,
        particles = {}
    })
    
    for i = 1, 8 do
        table.insert(effects[#effects].particles, {
            x = x,
            y = y,
            vx = math.cos(i * math.pi / 4) * 50,
            vy = math.sin(i * math.pi / 4) * 50,
            life = 1
        })
    end
end

function createPowerEffect(x, y)
    table.insert(effects, {
        type = "power",
        x = x,
        y = y,
        timer = 1,
        radius = 10
    })
end

function createWavePickup(pickupData, cameraX, screenWidth)
    local x = cameraX + screenWidth/2
    local y = getFloorHeight() - 100
    
    if pickupData.type == "crate" then
        -- Create breakable crate
        createBreakableCrate(x, y, pickupData.contains)
    elseif pickupData.type == "chest" then
        -- Create chest
        createBreakableChest(x, y, pickupData.contains)
    elseif pickupData.type == "bone_chest" then
        -- Create bone chest
        createBoneChest(x, y, pickupData.contains)
    elseif pickupData.type == "slot_machine" then
        -- Create slot machine
        createSlotMachine(x, y, pickupData.contains)
    end
end

function createBreakableCrate(x, y, contents)
    table.insert(pickups, {
        type = "container",
        containerType = "crate",
        x = x,
        y = y,
        width = 40,
        height = 40,
        health = 1,
        contents = contents,
        color = {0.6, 0.4, 0.2}
    })
end

function createBreakableChest(x, y, contents)
    table.insert(pickups, {
        type = "container",
        containerType = "chest",
        x = x,
        y = y,
        width = 50,
        height = 35,
        health = 2,
        contents = contents,
        color = {0.8, 0.6, 0.2}
    })
end

function createBoneChest(x, y, contents)
    table.insert(pickups, {
        type = "container",
        containerType = "bone_chest",
        x = x,
        y = y,
        width = 45,
        height = 40,
        health = 2,
        contents = contents,
        color = {0.9, 0.9, 0.8}
    })
end

function createSlotMachine(x, y, contents)
    table.insert(pickups, {
        type = "container",
        containerType = "slot_machine",
        x = x,
        y = y,
        width = 60,
        height = 80,
        health = 3,
        contents = contents,
        color = {0.9, 0.9, 0.1}
    })
end