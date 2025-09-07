-- stage.lua
-- Three detailed stages: Limbo Back Alley, Greed Strip, Throne District
stages = {
    {
        name = "Limbo Back Alley",
        backgroundColor = {0.15, 0.1, 0.2},
        floorColor = {0.35, 0.3, 0.35},
        width = 4500,
        floorHeight = 450,
        wallColor = {0.25, 0.2, 0.25},
        detailsColor = {0.5, 0.4, 0.5},
    },
    {
        name = "Greed Strip - Inferno Casino", 
        backgroundColor = {0.3, 0.15, 0.1},
        floorColor = {0.7, 0.6, 0.3},
        width = 5000,
        floorHeight = 450,
        wallColor = {0.6, 0.3, 0.2},
        detailsColor = {0.9, 0.8, 0.4},
    },
    {
        name = "Throne District",
        backgroundColor = {0.2, 0.05, 0.05},
        floorColor = {0.5, 0.15, 0.15},
        width = 5500,
        floorHeight = 450,
        wallColor = {0.4, 0.1, 0.1},
        detailsColor = {0.7, 0.3, 0.3},
    }
}

currentStage = 1
stageScroll = 0

function initStage(stageNumber)
    currentStage = stageNumber
    stageScroll = 0
    
    -- Initialize stage-specific elements
    initEnemies()
    initBoss()
    initHazards()
    initPickups()
    initWeapons()
    
    -- Initialize camera position
    initCamera()
end

function updateStage(dt)
    -- Update stage scroll for parallax
    stageScroll = getCameraX() or 0
end

function drawStage()
    local stage = stages[currentStage]
    local scale = getCameraScale() or 1.5
    local screenHeight = love.graphics.getHeight() / scale
    
    -- Draw background gradient
    for i = 0, screenHeight do
        local fade = i / screenHeight
        love.graphics.setColor(
            stage.backgroundColor[1] * (1 - fade * 0.3),
            stage.backgroundColor[2] * (1 - fade * 0.3),
            stage.backgroundColor[3] * (1 - fade * 0.3)
        )
        love.graphics.rectangle("fill", 0, i, stage.width, 1)
    end
    
    -- Draw stage-specific background
    if currentStage == 1 then
        drawLimboBackground()
    elseif currentStage == 2 then
        drawCasinoBackground()
    elseif currentStage == 3 then
        drawThroneBackground()
    end
    
    -- Draw floor
    love.graphics.setColor(stage.floorColor)
    love.graphics.rectangle("fill", 0, stage.floorHeight, stage.width, 200)
    
    -- Draw floor details
    love.graphics.setColor(stage.detailsColor[1] * 0.8, stage.detailsColor[2] * 0.8, stage.detailsColor[3] * 0.8)
    for i = 0, stage.width / 100 do
        if i % 2 == 0 then
            love.graphics.rectangle("fill", i * 100, stage.floorHeight, 100, 3)
        end
        -- Cracks
        if i % 5 == 0 then
            love.graphics.line(i * 100, stage.floorHeight, i * 100 + 20, stage.floorHeight + 10)
        end
    end
    
    -- Draw stage-specific foreground elements
    if currentStage == 1 then
        drawLimboForeground()
    elseif currentStage == 2 then
        drawCasinoForeground()
    elseif currentStage == 3 then
        drawThroneForeground()
    end
end

function drawLimboBackground()
    local stage = stages[1]
    local parallax = stageScroll * 0.3
    
    -- Background buildings
    love.graphics.setColor(stage.wallColor)
    for i = 0, 30 do
        local x = i * 200 - parallax % 200
        local height = 200 + math.sin(i * 0.5) * 50
        love.graphics.rectangle("fill", x, stage.floorHeight - height, 150, height)
        
        -- Windows
        love.graphics.setColor(0.1, 0.1, 0.15)
        for w = 0, 3 do
            for h = 0, 4 do
                love.graphics.rectangle("fill", x + 20 + w * 35, stage.floorHeight - height + 20 + h * 40, 25, 30)
            end
        end
        love.graphics.setColor(stage.wallColor)
    end
    
    -- Neon "REPENT?" signs
    for i = 0, 10 do
        local x = i * 450 - parallax * 0.5 % 450
        local flicker = math.random() > 0.1
        if flicker then
            love.graphics.setColor(1, 0.2, 0.2)
            love.graphics.print("REPENT?", x, 150, 0, 2, 2)
            -- Glow effect
            love.graphics.setColor(1, 0.2, 0.2, 0.3)
            love.graphics.circle("fill", x + 50, 160, 30)
        end
    end
end

function drawLimboForeground()
    local stage = stages[1]
    
    -- Trash cans with fire
    for i = 0, 20 do
        local x = i * 220
        
        -- Trash can
        love.graphics.setColor(0.25, 0.25, 0.25)
        love.graphics.rectangle("fill", x, stage.floorHeight - 60, 40, 60)
        love.graphics.setColor(0.35, 0.35, 0.35)
        love.graphics.rectangle("fill", x - 2, stage.floorHeight - 62, 44, 5)
        
        -- Fire
        local flicker = math.sin(love.timer.getTime() * 10 + i) * 0.3 + 0.7
        love.graphics.setColor(1, 0.6 * flicker, 0)
        for f = 0, 2 do
            local flameHeight = 15 + math.sin(love.timer.getTime() * 5 + f + i) * 5
            love.graphics.polygon("fill",
                x + 10 + f * 10, stage.floorHeight - 60,
                x + 15 + f * 10, stage.floorHeight - 60 - flameHeight,
                x + 20 + f * 10, stage.floorHeight - 60
            )
        end
    end
    
    -- Bone dumpsters
    for i = 0, 8 do
        local x = i * 500 + 100
        love.graphics.setColor(0.3, 0.25, 0.2)
        love.graphics.rectangle("fill", x, stage.floorHeight - 80, 80, 80)
        
        -- Bones sticking out
        love.graphics.setColor(0.9, 0.9, 0.8)
        love.graphics.rectangle("fill", x + 10, stage.floorHeight - 85, 4, 20)
        love.graphics.circle("fill", x + 12, stage.floorHeight - 85, 4)
        love.graphics.rectangle("fill", x + 50, stage.floorHeight - 90, 3, 25)
    end
    
    -- Sewer grates (hazard indicators)
    love.graphics.setColor(0.15, 0.15, 0.15)
    for i = 0, 15 do
        local x = i * 300
        love.graphics.rectangle("fill", x, stage.floorHeight, 50, 10)
        for g = 0, 4 do
            love.graphics.setColor(0, 0, 0)
            love.graphics.rectangle("fill", x + 5 + g * 9, stage.floorHeight + 2, 6, 6)
        end
    end
    
    -- Graffiti
    love.graphics.setColor(0.7, 0.1, 0.1, 0.7)
    love.graphics.print("ABANDON HOPE", 300, 250, -0.1, 1.5, 1.5)
    love.graphics.print("DAMNED", 800, 280, 0.1, 2, 2)
    love.graphics.print("NO SALVATION", 1500, 240, -0.05, 1.3, 1.3)
end

function drawCasinoBackground()
    local stage = stages[2]
    local parallax = stageScroll * 0.4
    
    -- Casino buildings with neon
    for i = 0, 20 do
        local x = i * 250 - parallax % 250
        
        -- Building
        love.graphics.setColor(stage.wallColor)
        love.graphics.rectangle("fill", x, 100, 200, 350)
        
        -- Neon casino sign
        local neonPulse = math.sin(love.timer.getTime() * 3 + i) * 0.3 + 0.7
        love.graphics.setColor(1, 1, 0, neonPulse)
        love.graphics.rectangle("line", x + 20, 120, 160, 60)
        love.graphics.setColor(1, 0, 1, neonPulse)
        love.graphics.print("CASINO", x + 50, 140, 0, 2, 2)
        
        -- Flashing lights
        for l = 0, 5 do
            local lightOn = math.floor(love.timer.getTime() * 5 + l) % 3 == 0
            if lightOn then
                love.graphics.setColor(1, math.random(), 0)
                love.graphics.circle("fill", x + 30 + l * 30, 200, 5)
            end
        end
    end
    
    -- "ALL BETS DAMNED" banner
    love.graphics.setColor(0.8, 0, 0)
    for i = 0, 5 do
        local x = i * 800 - parallax * 0.6 % 800
        love.graphics.rectangle("fill", x, 50, 700, 40)
        love.graphics.setColor(1, 1, 0)
        love.graphics.print("ALL BETS DAMNED", x + 200, 60, 0, 2, 2)
    end
end

function drawCasinoForeground()
    local stage = stages[2]
    
    -- Slot machines
    for i = 0, 30 do
        local x = i * 160
        
        -- Machine body
        love.graphics.setColor(0.8, 0.7, 0.1)
        love.graphics.rectangle("fill", x, stage.floorHeight - 100, 60, 100)
        
        -- Screen
        love.graphics.setColor(0.1, 0.1, 0.1)
        love.graphics.rectangle("fill", x + 10, stage.floorHeight - 90, 40, 30)
        
        -- Spinning reels
        local spin = math.floor(love.timer.getTime() * 10 + i) % 4
        love.graphics.setColor(1, 1, 1)
        local symbols = {"7", "$", "!", "X"}
        love.graphics.print(symbols[spin + 1], x + 15, stage.floorHeight - 85)
        love.graphics.print(symbols[(spin + 1) % 4 + 1], x + 25, stage.floorHeight - 85)
        love.graphics.print(symbols[(spin + 2) % 4 + 1], x + 35, stage.floorHeight - 85)
        
        -- Lever
        love.graphics.setColor(0.5, 0.5, 0.5)
        love.graphics.rectangle("fill", x + 55, stage.floorHeight - 70, 5, 40)
        love.graphics.setColor(1, 0, 0)
        love.graphics.circle("fill", x + 57, stage.floorHeight - 70, 8)
    end
    
    -- Roulette wheels on floor
    for i = 0, 10 do
        local x = i * 450 + 200
        love.graphics.setColor(0.2, 0.5, 0.2)
        love.graphics.circle("fill", x, stage.floorHeight + 20, 40)
        
        -- Spinning effect
        local spin = love.timer.getTime() * 2 + i
        love.graphics.setColor(1, 0, 0)
        for r = 0, 7 do
            if r % 2 == 0 then
                local angle = r * math.pi / 4 + spin
                love.graphics.arc("fill", x, stage.floorHeight + 20, 38, angle, angle + math.pi/4)
            end
        end
        
        -- Center
        love.graphics.setColor(0.9, 0.9, 0.1)
        love.graphics.circle("fill", x, stage.floorHeight + 20, 10)
    end
    
    -- Floating coins
    for i = 0, 40 do
        local x = i * 120 + math.sin(love.timer.getTime() * 2 + i) * 30
        local y = 320 + math.cos(love.timer.getTime() * 3 + i * 0.5) * 40
        love.graphics.setColor(0.9, 0.9, 0.1)
        love.graphics.circle("fill", x, y, 6)
        love.graphics.setColor(0.7, 0.7, 0)
        love.graphics.print("$", x - 3, y - 5)
    end
    
    -- Molten gold on floor
    love.graphics.setColor(1, 0.8, 0, 0.6)
    for i = 0, 20 do
        local x = i * 250
        love.graphics.ellipse("fill", x, stage.floorHeight + 5, 30, 8)
    end
end

function drawThroneBackground()
    local stage = stages[3]
    local parallax = stageScroll * 0.2
    
    -- Massive spine pillars
    for i = 0, 10 do
        local x = i * 500 - parallax % 500
        
        -- Vertebrae column
        love.graphics.setColor(0.8, 0.8, 0.7)
        for v = 0, 15 do
            local size = 30 - v * 0.5
            love.graphics.circle("fill", x, 100 + v * 25, size)
            
            -- Spinal processes
            love.graphics.setColor(0.6, 0.6, 0.5)
            love.graphics.polygon("fill",
                x - size, 100 + v * 25,
                x - size - 10, 95 + v * 25,
                x - size, 90 + v * 25
            )
            love.graphics.polygon("fill",
                x + size, 100 + v * 25,
                x + size + 10, 95 + v * 25,
                x + size, 90 + v * 25
            )
            love.graphics.setColor(0.8, 0.8, 0.7)
        end
    end
    
    -- Stained glass skull windows
    for i = 0, 15 do
        local x = i * 350 - parallax * 0.5 % 350
        
        -- Window frame
        love.graphics.setColor(0.3, 0.3, 0.3)
        love.graphics.rectangle("fill", x, 150, 80, 120)
        
        -- Skull shape
        love.graphics.setColor(0.8, 0.2, 0.2, 0.7)
        love.graphics.circle("fill", x + 40, 190, 30)
        
        -- Eye sockets
        love.graphics.setColor(0, 0, 0)
        love.graphics.circle("fill", x + 30, 185, 8)
        love.graphics.circle("fill", x + 50, 185, 8)
        
        -- Glowing effect
        local glow = math.sin(love.timer.getTime() * 2 + i) * 0.3 + 0.5
        love.graphics.setColor(1, 0, 0, glow)
        love.graphics.circle("fill", x + 30, 185, 4)
        love.graphics.circle("fill", x + 50, 185, 4)
    end
    
    -- Storm of souls in background
    love.graphics.setColor(0.5, 0.5, 0.6, 0.3)
    for i = 0, 50 do
        local x = (i * 100 + love.timer.getTime() * 50) % (stages[3].width + 100) - 50
        local y = 50 + math.sin(love.timer.getTime() + i) * 100
        love.graphics.circle("fill", x, y, 3 + math.sin(i) * 2)
    end
end

function drawThroneForeground()
    local stage = stages[3]
    
    -- Bone platforms
    for i = 0, 12 do
        local x = i * 400
        
        -- Ribcage platform
        love.graphics.setColor(0.9, 0.9, 0.8)
        for r = 0, 5 do
            love.graphics.arc("line", x + r * 15, stage.floorHeight - 20, 60 - r * 5, 0, math.pi)
        end
    end
    
    -- Lava pits with bubbles
    for i = 0, 8 do
        local x = i * 600 + 200
        
        -- Lava pool
        love.graphics.setColor(0.9, 0.2, 0.1)
        love.graphics.ellipse("fill", x, stage.floorHeight + 30, 100, 20)
        
        -- Bubbles
        for b = 0, 3 do
            local bubbleY = math.sin(love.timer.getTime() * 3 + b + i) * 10
            love.graphics.setColor(1, 0.5, 0)
            love.graphics.circle("fill", x - 50 + b * 35, stage.floorHeight + 30 + bubbleY, 5)
        end
        
        -- Glow
        love.graphics.setColor(1, 0.3, 0.1, 0.3)
        love.graphics.ellipse("fill", x, stage.floorHeight + 30, 120, 30)
    end
    
    -- Swinging bone pendulums (visual only, hazards handle collision)
    for i = 0, 6 do
        local x = i * 700 + 350
        local swing = math.sin(love.timer.getTime() * 1.5 + i) * 100
        
        -- Chain
        love.graphics.setColor(0.4, 0.4, 0.4)
        love.graphics.line(x, 100, x + swing, 350)
        
        -- Skull weight
        love.graphics.setColor(0.9, 0.9, 0.8)
        love.graphics.circle("fill", x + swing, 350, 25)
        
        -- Eye sockets
        love.graphics.setColor(0, 0, 0)
        love.graphics.circle("fill", x + swing - 8, 345, 5)
        love.graphics.circle("fill", x + swing + 8, 345, 5)
    end
    
    -- Throne in the distance (if near end of stage)
    if getCameraX() and getCameraX() > stage.width - 1500 then
        local throneX = stage.width - 400
        
        -- Throne
        love.graphics.setColor(0.2, 0, 0)
        love.graphics.rectangle("fill", throneX, 200, 250, 250)
        
        -- Throne details
        love.graphics.setColor(0.1, 0, 0)
        love.graphics.rectangle("fill", throneX + 50, 220, 150, 180)
        
        -- Spikes on throne
        love.graphics.setColor(0.4, 0.4, 0.4)
        for s = 0, 4 do
            love.graphics.polygon("fill",
                throneX + 50 * s, 200,
                throneX + 25 + 50 * s, 150,
                throneX + 50 + 50 * s, 200
            )
        end
        
        -- Flames around throne
        for f = -3, 3 do
            local flameX = throneX + 125 + f * 40
            local flameHeight = 30 + math.sin(love.timer.getTime() * 5 + f) * 10
            love.graphics.setColor(1, 0.5, 0)
            love.graphics.polygon("fill",
                flameX - 10, stage.floorHeight,
                flameX, stage.floorHeight - flameHeight,
                flameX + 10, stage.floorHeight
            )
            love.graphics.setColor(1, 0.8, 0)
            love.graphics.polygon("fill",
                flameX - 5, stage.floorHeight,
                flameX, stage.floorHeight - flameHeight * 0.7,
                flameX + 5, stage.floorHeight
            )
        end
        
        -- "FINAL JUDGMENT" text
        love.graphics.setColor(1, 0, 0)
        love.graphics.print("FINAL JUDGMENT", throneX + 20, 100, 0, 2, 2)
    end
end

function getFloorHeight()
    if stages and stages[currentStage] then
        return stages[currentStage].floorHeight
    end
    return 450
end

function getCurrentStageWidth()
    if stages and stages[currentStage] then
        return stages[currentStage].width
    end
    return 4000
end