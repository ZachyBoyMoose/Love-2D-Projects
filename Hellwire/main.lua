-- main.lua (FIXED)
local Config = require('lib.config')
local ConfigTerrifying = require('lib.config_terrifying')
local State = require('lib.state')
local Player = require('lib.player')
local Enemies = require('lib.enemies')
local EnemiesTerrifying = require('lib.enemies_terrifying')
local Collisions = require('lib.collisions')
local CollisionsTerrifying = require('lib.collisions_terrifying')
local Drawing = require('lib.drawing')
local DrawingTerrifying = require('lib.drawing_terrifying')
local UI = require('lib.ui')
local InitLevels = require('lib.init_levels')

function love.load()
    love.window.setTitle("Hellwire: Rail to Oblivion")
    love.window.setMode(Config.screenWidth, Config.screenHeight)
    
    -- Load both regular and terrifying assets
    Config.loadAssets()
    ConfigTerrifying.loadTerrifyingAssets()
    
    InitLevels.initializeLevels()
    
    State.gameState = "title"
    State.camera = {x = 0, y = 0, targetX = 0, targetY = 0}
    
    -- Initialize obstacles array if it doesn't exist
    State.obstacles = State.obstacles or {}
end

function love.update(dt)
    if State.gameState == "playing" then
        State.levelTimer = State.levelTimer + dt
        Player.updateGondola(dt)
        
        -- Use the terrifying enemies system for new enemy types
        EnemiesTerrifying.updateEnemies(dt)
        
        -- Check collisions with new enemy types
        CollisionsTerrifying.checkGondolaCollisions()
        
        local hangX = State.gondola.x + math.sin(State.gondola.swingAngle) * State.gondola.cableLength
        local hangY = State.gondola.y + math.cos(State.gondola.swingAngle) * State.gondola.cableLength
        State.camera.targetX = hangX - Config.screenWidth / 2
        State.camera.targetY = hangY - Config.screenHeight / 2
        
        State.camera.x = State.camera.x + (State.camera.targetX - State.camera.x) * 0.1
        State.camera.y = State.camera.y + (State.camera.targetY - State.camera.y) * 0.1
    end
end

function love.draw()
    if State.gameState == "title" then
        UI.drawTitleScreen()
    elseif State.gameState == "levelSelect" then
        UI.drawLevelSelect()
    elseif State.gameState == "playing" or State.gameState == "paused" then
        -- Use the terrifying drawing system
        DrawingTerrifying.drawGameWorld()
        UI.drawHUD()
    elseif State.gameState == "gameOver" then
        UI.drawGameOver()
    elseif State.gameState == "levelComplete" then
        UI.drawLevelComplete()
    end
end

function love.keypressed(key)
    if State.gameState == "title" then
        if key == "return" then
            State.loadLevel(1)
        elseif key == "l" then
            State.gameState = "levelSelect"
        elseif key == "escape" then
            love.event.quit()
        end
    elseif State.gameState == "levelSelect" then
        if key == "escape" then
            State.gameState = "title"
        end
        local num = tonumber(key)
        if num and num >= 1 and num <= 9 then
            State.loadLevel(num)
        end
    elseif State.gameState == "playing" then
        if key == "escape" then
            State.gameState = "paused"
        elseif key == "r" then
            State.loadLevel(State.currentLevel)
        end
    elseif State.gameState == "paused" then
        if key == "escape" then
            State.gameState = "playing"
        elseif key == "q" then
            State.gameState = "title"
        end
    elseif State.gameState == "gameOver" then
        if key == "r" then
            State.loadLevel(State.currentLevel)
        elseif key == "escape" then
            State.gameState = "title"
        end
    elseif State.gameState == "levelComplete" then
        if key == "space" and State.currentLevel < 30 then
            State.loadLevel(State.currentLevel + 1)
        elseif key == "r" then
            State.loadLevel(State.currentLevel)
        elseif key == "escape" then
            State.gameState = "title"
        end
    end
end

function love.mousepressed(x, y, button)
    if State.gameState == "levelSelect" and button == 1 then
        for i = 1, 30 do
            local lx = ((i - 1) % 6) * 120 + 100
            local ly = math.floor((i - 1) / 6) * 80 + 100
            if x >= lx - 40 and x <= lx + 40 and y >= ly - 20 and y <= ly + 20 then
                if State.levels[i] then
                    State.loadLevel(i)
                end
            end
        end
    end
end