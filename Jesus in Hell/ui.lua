-- ui.lua
-- Complete UI system
local titleTimer = 0
local titleState = "press_start"
local stageClearTimer = 0
local gameOverTimer = 0

function initUI()
    -- UI initialization
end

function drawUI()
    -- Health bar background
    love.graphics.setColor(0.2, 0.2, 0.2)
    love.graphics.rectangle("fill", 20, 20, 204, 24)
    
    -- Health bar
    local healthWidth = (player.health / player.maxHealth) * 200
    local healthColor = {0, 1, 0}
    if player.health < player.maxHealth * 0.3 then
        healthColor = {1, 0, 0}
    elseif player.health < player.maxHealth * 0.6 then
        healthColor = {1, 1, 0}
    end
    love.graphics.setColor(healthColor)
    love.graphics.rectangle("fill", 22, 22, healthWidth, 20)
    
    -- Health bar border
    love.graphics.setColor(1, 1, 1)
    love.graphics.rectangle("line", 20, 20, 204, 24)
    love.graphics.print("HEALTH", 25, 24)
    
    -- Super meter background
    love.graphics.setColor(0.2, 0.2, 0.2)
    love.graphics.rectangle("fill", 20, 50, 204, 14)
    
    -- Super meter
    local superWidth = (player.superMeter / player.maxSuperMeter) * 200
    if player.superMeter >= player.maxSuperMeter then
        -- Flashing when full
        local flash = math.sin(love.timer.getTime() * 10) * 0.5 + 0.5
        love.graphics.setColor(1, 1, flash)
    else
        love.graphics.setColor(1, 1, 0)
    end
    love.graphics.rectangle("fill", 22, 52, superWidth, 10)
    
    -- Super meter border
    love.graphics.setColor(1, 1, 1)
    love.graphics.rectangle("line", 20, 50, 204, 14)
    love.graphics.print("SUPER", 25, 48)
    
    -- Score
    love.graphics.setColor(1, 1, 1)
    love.graphics.setNewFont(16)
    love.graphics.print("SCORE: " .. string.format("%08d", score), 250, 20)
    
    -- Lives
    love.graphics.print("LIVES:", 250, 45)
    for i = 1, playerLives do
        -- Draw cross for each life
        love.graphics.setColor(1, 0.8, 0)
        local x = 300 + i * 25
        love.graphics.rectangle("fill", x, 45, 3, 15)
        love.graphics.rectangle("fill", x - 5, 50, 13, 3)
    end
    
    -- Coins/Souls
    love.graphics.setColor(0.9, 0.9, 0.1)
    love.graphics.print("SOULS: " .. coins, 450, 20)
    
    -- Stage info
    love.graphics.setColor(1, 1, 1)
    love.graphics.print(stages[currentStage].name, 450, 45)
    
    -- Wave indicator
    if currentWave > 0 and currentWave <= maxWave then
        love.graphics.print("WAVE " .. currentWave .. "/" .. maxWave, 620, 20)
    elseif boss.active then
        love.graphics.setColor(1, 0, 0)
        love.graphics.print("BOSS FIGHT!", 620, 20)
    end
    
    -- Combo counter
    if comboCounter > 0 then
        local comboSize = 1 + comboCounter * 0.1
        love.graphics.push()
        love.graphics.translate(650, 80)
        love.graphics.scale(comboSize, comboSize)
        love.graphics.setColor(1, 1, 0)
        love.graphics.print("COMBO x" .. comboCounter, -30, -10)
        love.graphics.pop()
    end
    
    -- Weapon indicator
    if player.weapon and player.weapon ~= "none" then
        love.graphics.setColor(1, 1, 1)
        love.graphics.print("WEAPON: " .. string.upper(string.gsub(player.weapon, "_", " ")), 20, 70)
        love.graphics.print("USES: " .. player.weaponUses, 20, 88)
    end
    
    -- Power-up timers
    local powerY = 110
    if player.dashPower and player.dashTimer then
        love.graphics.setColor(1, 0, 1)
        love.graphics.print("DASH: " .. math.floor(player.dashTimer), 20, powerY)
        powerY = powerY + 18
    end
    if player.damageBoost and player.boostTimer then
        love.graphics.setColor(1, 0.5, 0)
        love.graphics.print("POWER: " .. math.floor(player.boostTimer), 20, powerY)
    end
    
    -- Debug info (remove in final)
    if DEBUG_MODE then
        love.graphics.setColor(1, 1, 1)
        love.graphics.print("FPS: " .. love.timer.getFPS(), 10, 580)
    end
end

function initTitleScreen()
    titleTimer = 0
    titleState = "press_start"
end

function updateTitleScreen(dt)
    titleTimer = titleTimer + dt
    if titleTimer > 2 then
        titleTimer = 0
        titleState = titleState == "press_start" and "attract" or "press_start"
    end
end

function drawTitleScreen()
    -- Hellish background
    for i = 0, love.graphics.getHeight() do
        local fade = i / love.graphics.getHeight()
        love.graphics.setColor(0.2 * fade, 0.05 * fade, 0.05 * fade)
        love.graphics.rectangle("fill", 0, i, love.graphics.getWidth(), 1)
    end
    
    -- Animated flames at bottom
    for i = 0, 20 do
        local flameHeight = 100 + math.sin(love.timer.getTime() * 3 + i) * 30
        love.graphics.setColor(1, 0.5, 0, 0.7)
        love.graphics.polygon("fill",
            i * 40, love.graphics.getHeight(),
            i * 40 + 20, love.graphics.getHeight() - flameHeight,
            i * 40 + 40, love.graphics.getHeight()
        )
        love.graphics.setColor(1, 0.8, 0, 0.5)
        love.graphics.polygon("fill",
            i * 40 + 10, love.graphics.getHeight(),
            i * 40 + 20, love.graphics.getHeight() - flameHeight * 0.7,
            i * 40 + 30, love.graphics.getHeight()
        )
    end
    
    -- Title
    love.graphics.setColor(1, 1, 1)
    love.graphics.setNewFont(60)
    love.graphics.print("JESUS IN HELL", 180, 100)
    
    -- Subtitle with glow
    love.graphics.setNewFont(30)
    local glowIntensity = math.sin(love.timer.getTime() * 2) * 0.3 + 0.7
    love.graphics.setColor(1, 1, 0, glowIntensity)
    love.graphics.print("REDEMPTION BRAWL", 230, 170)
    
    -- Cross
    love.graphics.setColor(1, 1, 0)
    love.graphics.rectangle("fill", 395, 230, 10, 80)
    love.graphics.rectangle("fill", 370, 250, 60, 10)
    
    -- Halo
    love.graphics.setColor(1, 1, 0, 0.5)
    love.graphics.circle("line", 400, 230, 25)
    love.graphics.circle("fill", 400, 230, 25)
    
    -- Press start prompt
    if titleState == "press_start" then
        love.graphics.setColor(1, 1, 1)
        love.graphics.setNewFont(24)
        if math.floor(titleTimer * 2) % 2 == 0 then
            love.graphics.print("PRESS ENTER TO START", 240, 400)
        end
        
        -- Controls
        love.graphics.setNewFont(16)
        love.graphics.print("CONTROLS:", 100, 480)
        love.graphics.print("Arrow Keys - Move", 100, 500)
        love.graphics.print("Z - Attack  X - Jump  C - Special  V - Grab/Throw", 100, 520)
        love.graphics.print("Shift - Dodge  ESC - Pause", 100, 540)
    end
    
    -- Attract mode demo
    if titleState == "attract" then
        drawAttractDemo()
    end
    
    -- Copyright
    love.graphics.setNewFont(14)
    love.graphics.setColor(0.7, 0.7, 0.7)
    love.graphics.print("© 2024 Divine Punishment Games", 280, 570)
end

function drawAttractDemo()
    -- Animated demo scene
    local demoTime = love.timer.getTime() * 2
    
    -- Jesus sprite
    love.graphics.setColor(1, 1, 1)
    local jesusX = 250 + math.sin(demoTime) * 30
    love.graphics.rectangle("fill", jesusX, 350, 40, 80)
    
    -- Halo
    love.graphics.setColor(1, 1, 0, 0.5)
    love.graphics.circle("fill", jesusX + 20, 340, 15)
    
    -- Demon enemies
    for i = 1, 3 do
        local enemyX = 400 + i * 60 + math.cos(demoTime + i) * 20
        love.graphics.setColor(0.8, 0.2, 0.2)
        love.graphics.rectangle("fill", enemyX, 360, 35, 70)
        
        -- Horns
        love.graphics.setColor(0.4, 0.1, 0.1)
        love.graphics.polygon("fill", enemyX + 5, 360, enemyX + 10, 350, enemyX + 15, 360)
        love.graphics.polygon("fill", enemyX + 20, 360, enemyX + 25, 350, enemyX + 30, 360)
    end
    
    -- Attack effect
    if math.floor(demoTime) % 2 == 0 then
        love.graphics.setColor(1, 1, 0, 0.6)
        love.graphics.circle("fill", jesusX + 60, 380, 30)
        love.graphics.print("POW!", jesusX + 45, 370)
    end
    
    -- High score display
    love.graphics.setColor(1, 1, 1)
    love.graphics.setNewFont(20)
    love.graphics.print("HIGH SCORE: 99999999", 270, 450)
end

function initStageClear()
    stageClearTimer = 3
end

function updateStageClear(dt)
    stageClearTimer = stageClearTimer - dt
end

function drawStageClear()
    -- Darken background
    love.graphics.setColor(0, 0, 0, 0.7)
    love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
    
    -- Victory fanfare
    love.graphics.setColor(1, 1, 0)
    love.graphics.setNewFont(60)
    love.graphics.print("STAGE CLEAR!", 200, 150)
    
    -- Stage name
    love.graphics.setColor(1, 1, 1)
    love.graphics.setNewFont(30)
    love.graphics.print(stages[currentStage].name .. " PURIFIED!", 200, 230)
    
    -- Stats
    love.graphics.setNewFont(20)
    love.graphics.print("SCORE: " .. score, 300, 300)
    love.graphics.print("MAX COMBO: " .. maxCombo, 300, 330)
    love.graphics.print("SOULS SAVED: " .. coins, 300, 360)
    
    -- Bonus calculation
    local timeBonus = math.floor(stageClearTimer * 1000)
    local healthBonus = math.floor(player.health / player.maxHealth * 5000)
    love.graphics.print("TIME BONUS: " .. timeBonus, 300, 400)
    love.graphics.print("HEALTH BONUS: " .. healthBonus, 300, 430)
    
    -- Next stage preview
    if currentStage < 3 then
        love.graphics.setColor(0.8, 0.8, 0.8)
        love.graphics.print("NEXT: " .. stages[currentStage + 1].name, 250, 480)
    else
        love.graphics.setColor(1, 0, 0)
        love.graphics.print("PREPARE FOR FINAL JUDGMENT!", 230, 480)
    end
    
    -- Continue prompt
    if stageClearTimer < 1 then
        love.graphics.setColor(1, 1, 1)
        if math.floor(stageClearTimer * 4) % 2 == 0 then
            love.graphics.print("PRESS ENTER TO CONTINUE", 260, 530)
        end
    end
end

function initGameOver()
    gameOverTimer = 5
end

function updateGameOver(dt)
    gameOverTimer = gameOverTimer - dt
end

function drawGameOver()
    -- Dark overlay
    love.graphics.setColor(0.1, 0, 0, 0.8)
    love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
    
    -- Game over text with flame effect
    love.graphics.setColor(1, 0, 0)
    love.graphics.setNewFont(80)
    love.graphics.print("GAME OVER", 180, 150)
    
    -- Flames around text
    for i = -3, 3 do
        local flameX = 400 + i * 50
        local flameY = 230
        local flameHeight = 30 + math.sin(love.timer.getTime() * 5 + i) * 10
        love.graphics.setColor(1, 0.5, 0, 0.7)
        love.graphics.polygon("fill",
            flameX - 10, flameY,
            flameX, flameY - flameHeight,
            flameX + 10, flameY
        )
    end
    
    -- Stats
    love.graphics.setColor(1, 1, 1)
    love.graphics.setNewFont(30)
    love.graphics.print("FINAL SCORE: " .. score, 280, 300)
    love.graphics.print("SOULS SAVED: " .. coins, 280, 340)
    love.graphics.print("MAX COMBO: " .. maxCombo, 280, 380)
    
    -- Taunt message
    love.graphics.setColor(0.8, 0.8, 0.8)
    love.graphics.setNewFont(20)
    local tauntMessages = {
        "THE DAMNED REMAIN UNSAVED...",
        "HELL'S GRIP TIGHTENS...",
        "REDEMPTION DENIED...",
        "THE DEVIL LAUGHS..."
    }
    love.graphics.print(tauntMessages[math.floor(gameOverTimer) % #tauntMessages + 1], 250, 440)
    
    -- Continue prompt
    if gameOverTimer < 2 then
        love.graphics.setColor(1, 1, 1)
        if math.floor(gameOverTimer * 4) % 2 == 0 then
            love.graphics.print("PRESS ENTER TO RETURN TO TITLE", 230, 500)
        end
    end
end

function initBonusRound()
    bonusRoundTimer = 30
end

function updateBonusRound(dt)
    bonusRoundTimer = bonusRoundTimer - dt
    if bonusRoundTimer <= 0 then
        gameState = "playing"
    end
end

function drawBonusRound()
    -- Special bonus round screen
    love.graphics.setColor(0.2, 0.2, 0.5)
    love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
    
    love.graphics.setColor(1, 1, 0)
    love.graphics.setNewFont(50)
    love.graphics.print("BONUS ROUND!", 230, 200)
    
    love.graphics.setNewFont(30)
    love.graphics.print("SAVE AS MANY SOULS AS POSSIBLE!", 150, 280)
    
    love.graphics.setNewFont(40)
    love.graphics.print("TIME: " .. math.floor(bonusRoundTimer), 350, 350)
end