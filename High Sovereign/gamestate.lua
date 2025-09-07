local GameState = {
    currentState = "menu",
    difficulty = "normal",
    cameraScale = 1.0,
    victoryMessage = "",
    defeatMessage = ""
}

function GameState.load()
    -- Initialize different state managers
    require('menu').load()
    require('game').load()
end

function GameState.update(dt)
    if GameState.currentState == "menu" then
        require('menu').update(dt)
    elseif GameState.currentState == "gameplay" then
        require('game').update(dt)
        require('player').update(dt)
    elseif GameState.currentState == "victory" then
        -- Victory screen update
    elseif GameState.currentState == "defeat" then
        -- Defeat screen update
    end
end

function GameState.draw()
    love.graphics.push()
    
    if GameState.currentState == "menu" then
        love.graphics.scale(GameState.cameraScale, GameState.cameraScale)
        require('menu').draw()
    elseif GameState.currentState == "gameplay" then
        love.graphics.scale(GameState.cameraScale, GameState.cameraScale)
        
        -- Apply camera transform
        local player = require('player')
        love.graphics.translate(-player.cameraX, -player.cameraY)
        
        -- Draw game world
        require('game').draw()
        
        love.graphics.pop()
        love.graphics.push()
        
        -- Draw UI without camera transform
        require('ui').draw()
    elseif GameState.currentState == "victory" then
        GameState.drawVictoryScreen()
    elseif GameState.currentState == "defeat" then
        GameState.drawDefeatScreen()
    end
    
    love.graphics.pop()
end

function GameState.drawVictoryScreen()
    -- Victory background
    love.graphics.setColor(0, 0.2, 0, 1)
    love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
    
    -- Victory text
    love.graphics.setColor(1, 1, 0)
    love.graphics.setFont(love.graphics.newFont(48))
    love.graphics.printf("VICTORY!", 0, 200, love.graphics.getWidth(), "center")
    
    love.graphics.setColor(1, 1, 1)
    love.graphics.setFont(love.graphics.newFont(24))
    love.graphics.printf(GameState.victoryMessage, 0, 300, love.graphics.getWidth(), "center")
    
    -- Stats
    local game = require('game')
    love.graphics.setFont(love.graphics.newFont(18))
    love.graphics.printf("Final Statistics", 0, 400, love.graphics.getWidth(), "center")
    love.graphics.printf("Time: " .. math.floor(game.gameTime / 60) .. " minutes", 0, 430, love.graphics.getWidth(), "center")
    love.graphics.printf("Heroes: " .. #game.heroes, 0, 450, love.graphics.getWidth(), "center")
    love.graphics.printf("Kush Coins: " .. math.floor(game.kushCoins), 0, 470, love.graphics.getWidth(), "center")
    
    -- Return to menu button
    love.graphics.setColor(0.3, 0.3, 0.3)
    love.graphics.rectangle("fill", love.graphics.getWidth()/2 - 100, 550, 200, 50)
    love.graphics.setColor(1, 1, 1)
    love.graphics.printf("Return to Menu", love.graphics.getWidth()/2 - 100, 565, 200, "center")
end

function GameState.drawDefeatScreen()
    -- Defeat background
    love.graphics.setColor(0.2, 0, 0, 1)
    love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
    
    -- Defeat text
    love.graphics.setColor(1, 0, 0)
    love.graphics.setFont(love.graphics.newFont(48))
    love.graphics.printf("DEFEAT", 0, 200, love.graphics.getWidth(), "center")
    
    love.graphics.setColor(1, 1, 1)
    love.graphics.setFont(love.graphics.newFont(24))
    love.graphics.printf(GameState.defeatMessage, 0, 300, love.graphics.getWidth(), "center")
    
    -- Stats
    local game = require('game')
    love.graphics.setFont(love.graphics.newFont(18))
    love.graphics.printf("You survived for " .. math.floor(game.gameTime / 60) .. " minutes", 0, 400, love.graphics.getWidth(), "center")
    
    -- Return to menu button
    love.graphics.setColor(0.3, 0.3, 0.3)
    love.graphics.rectangle("fill", love.graphics.getWidth()/2 - 100, 500, 200, 50)
    love.graphics.setColor(1, 1, 1)
    love.graphics.printf("Return to Menu", love.graphics.getWidth()/2 - 100, 515, 200, "center")
end

function GameState.mousepressed(x, y, button)
    if GameState.currentState == "menu" then
        require('menu').mousepressed(x, y, button)
    elseif GameState.currentState == "gameplay" then
        require('player').mousepressed(x, y, button)
        require('ui').mousepressed(x, y, button)
    elseif GameState.currentState == "victory" or GameState.currentState == "defeat" then
        -- Check if clicked return to menu button
        if x >= love.graphics.getWidth()/2 - 100 and x <= love.graphics.getWidth()/2 + 100 then
            if (GameState.currentState == "victory" and y >= 550 and y <= 600) or
               (GameState.currentState == "defeat" and y >= 500 and y <= 550) then
                GameState.returnToMenu()
            end
        end
    end
end

function GameState.keypressed(key)
    if GameState.currentState == "menu" then
        require('menu').keypressed(key)
    elseif GameState.currentState == "gameplay" then
        require('player').keypressed(key)
        
        -- Debug keys
        if key == "f1" then
            -- Give resources
            require('game').kushCoins = require('game').kushCoins + 1000
            require('game'):addMessage("Debug: Added 1000 KC")
        elseif key == "f2" then
            -- Spawn hero at palace
            local palace = require('game').palace
            if palace then
                local hero = require('heroes/indica_knight').new(palace.x, palace.y)
                require('game').addHero(hero)
            end
        elseif key == "f3" then
            -- Reveal map
            local fogOfWar = require('game').fogOfWar
            for x = 1, #fogOfWar do
                for y = 1, #fogOfWar[1] do
                    fogOfWar[x][y] = false
                end
            end
            require('game'):addMessage("Debug: Map revealed")
        end
    elseif GameState.currentState == "victory" or GameState.currentState == "defeat" then
        if key == "escape" or key == "return" then
            GameState.returnToMenu()
        end
    end
end

function GameState.wheelmoved(x, y)
    if GameState.currentState == "gameplay" then
        -- Zoom in/out with mouse wheel
        local oldScale = GameState.cameraScale
        GameState.cameraScale = math.max(0.5, math.min(2.0, GameState.cameraScale + y * 0.1))
        
        -- Adjust camera position to zoom towards mouse
        if oldScale ~= GameState.cameraScale then
            local player = require('player')
            local mouseX, mouseY = love.mouse.getPosition()
            local worldMouseX = (mouseX / oldScale) + player.cameraX
            local worldMouseY = (mouseY / oldScale) + player.cameraY
            
            local newWorldMouseX = (mouseX / GameState.cameraScale) + player.cameraX
            local newWorldMouseY = (mouseY / GameState.cameraScale) + player.cameraY
            
            player.cameraX = player.cameraX + (worldMouseX - newWorldMouseX)
            player.cameraY = player.cameraY + (worldMouseY - newWorldMouseY)
        end
    end
end

function GameState.startGame()
    GameState.currentState = "gameplay"
    
    -- Reset game state
    local game = require('game')
    game.heroes = {}
    game.buildings = {}
    game.enemies = {}
    game.bounties = {}
    game.weedlings = {}
    game.kushCollectors = {}
    game.buildingInProgress = {}
    game.floatingTexts = {}
    game.messages = {}
    game.messageLog = {}
    game.gameTime = 0
    
    -- Set initial resources based on difficulty
    if GameState.difficulty == "easy" then
        game.kushCoins = 1500
        game.incomeInterval = 4
    elseif GameState.difficulty == "normal" then
        game.kushCoins = 1000
        game.incomeInterval = 5
    elseif GameState.difficulty == "hard" then
        game.kushCoins = 500
        game.incomeInterval = 6
    end
    
    -- Generate new map
    require('game').generateMap()
    
    -- Reset player camera
    local player = require('player')
    player.cameraX = require('game').palace.x - love.graphics.getWidth() / 2
    player.cameraY = require('game').palace.y - love.graphics.getHeight() / 2
end

function GameState.endGame(victory, message)
    if victory then
        GameState.currentState = "victory"
        GameState.victoryMessage = message
    else
        GameState.currentState = "defeat"
        GameState.defeatMessage = message
    end
end

function GameState.returnToMenu()
    GameState.currentState = "menu"
    GameState.cameraScale = 1.0
end

function GameState.setDifficulty(difficulty)
    GameState.difficulty = difficulty
end

function GameState.quitGame()
    love.event.quit()
end

return GameState