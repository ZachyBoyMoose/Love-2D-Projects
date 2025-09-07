local Config = require('lib.config')
local State = require('lib.state')

local UI = {}

function UI.drawHUD()
    if Config.assets.ui_hud_panel then
        love.graphics.draw(Config.assets.ui_hud_panel, 5, 5)
    end
    
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("Level " .. State.currentLevel .. ": " .. (State.levels[State.currentLevel] and State.levels[State.currentLevel].name or ""), 10, 10)
    love.graphics.print("Souls: " .. State.souls .. "/" .. State.maxSouls, 10, 30)
    love.graphics.print(string.format("Time: %.1f", State.levelTimer), 10, 50)
    
    if State.gameState == "paused" then
        love.graphics.setColor(0, 0, 0, 0.7)
        love.graphics.rectangle("fill", 0, 0, Config.screenWidth, Config.screenHeight)
        love.graphics.setColor(1, 1, 1)
        love.graphics.printf("PAUSED", 0, Config.screenHeight/2 - 30, Config.screenWidth, "center")
        love.graphics.printf("Press ESC to Resume", 0, Config.screenHeight/2, Config.screenWidth, "center")
    end
end

function UI.drawTitleScreen()
    if Config.assets.bg_title_screen then
        love.graphics.draw(Config.assets.bg_title_screen, 0, 0)
    end
    
    love.graphics.setColor(0.9, 0.2, 0.1)
    love.graphics.setFont(love.graphics.newFont(32))
    love.graphics.printf("HELLWIRE", 0, 120, Config.screenWidth, "center")
    love.graphics.setFont(love.graphics.newFont(20))
    love.graphics.printf("Rail to Oblivion", 0, 160, Config.screenWidth, "center")
    
    love.graphics.setFont(love.graphics.newFont(14))
    love.graphics.setColor(1, 1, 1)
    love.graphics.printf("Press ENTER to Start", 0, 300, Config.screenWidth, "center")
    love.graphics.printf("Press L for Level Select", 0, 330, Config.screenWidth, "center")
    love.graphics.printf("Press ESC to Quit", 0, 360, Config.screenWidth, "center")
    
    love.graphics.setColor(0.7, 0.7, 0.7)
    love.graphics.printf("Controls:", 0, 440, Config.screenWidth, "center")
    love.graphics.printf("UP/DOWN = Accelerate/Brake", 0, 460, Config.screenWidth, "center")
    love.graphics.printf("LEFT/RIGHT = Influence Swing", 0, 480, Config.screenWidth, "center")
    
    love.graphics.setFont(love.graphics.newFont(12))
end

function UI.drawLevelSelect()
    if Config.assets.bg_level_select then
        love.graphics.draw(Config.assets.bg_level_select, 0, 0)
    end
    
    love.graphics.setColor(1, 1, 1)
    love.graphics.setFont(love.graphics.newFont(24))
    love.graphics.printf("LEVEL SELECT", 0, 30, Config.screenWidth, "center")
    
    love.graphics.setFont(love.graphics.newFont(12))
    
    for i = 1, 30 do
        local x = ((i - 1) % 6) * 120 + 100
        local y = math.floor((i - 1) / 6) * 80 + 100
        
        if State.levels[i] and Config.assets.ui_level_button then
            love.graphics.draw(Config.assets.ui_level_button, x - 40, y - 20)
            
            if i % 5 == 0 and i % 10 ~= 0 then
                love.graphics.setColor(0.8, 0.6, 0.2)
            elseif i % 10 == 0 then
                love.graphics.setColor(0.9, 0.2, 0.2)
            else
                love.graphics.setColor(0.9, 0.9, 0.8)
            end
            
            love.graphics.printf(tostring(i), x - 40, y - 10, 80, "center")
            love.graphics.setFont(love.graphics.newFont(8))
            love.graphics.printf(State.levels[i].name, x - 40, y + 5, 80, "center")
            love.graphics.setFont(love.graphics.newFont(12))
        end
    end
    
    love.graphics.setColor(1, 1, 1)
    love.graphics.printf("Click a level or press ESC to return", 0, 520, Config.screenWidth, "center")
end

function UI.drawGameOver()
    if Config.assets.bg_game_over then
        love.graphics.draw(Config.assets.bg_game_over, 0, 0)
    end
    
    love.graphics.setColor(0.8, 0.1, 0.1)
    love.graphics.setFont(love.graphics.newFont(32))
    love.graphics.printf("GAME OVER", 0, 200, Config.screenWidth, "center")
    
    love.graphics.setFont(love.graphics.newFont(16))
    love.graphics.setColor(1, 1, 1)
    love.graphics.printf("You lost all souls!", 0, 250, Config.screenWidth, "center")
    love.graphics.printf("Press R to Retry", 0, 300, Config.screenWidth, "center")
    love.graphics.printf("Press ESC for Menu", 0, 330, Config.screenWidth, "center")
    
    love.graphics.setFont(love.graphics.newFont(12))
end

function UI.drawLevelComplete()
    if Config.assets.bg_level_complete then
        love.graphics.draw(Config.assets.bg_level_complete, 0, 0)
    end
    
    love.graphics.setColor(0.2, 0.9, 0.2)
    love.graphics.setFont(love.graphics.newFont(32))
    love.graphics.printf("LEVEL COMPLETE!", 0, 180, Config.screenWidth, "center")
    
    love.graphics.setFont(love.graphics.newFont(16))
    love.graphics.setColor(1, 1, 1)
    love.graphics.printf("Souls saved: " .. State.souls .. "/" .. State.maxSouls, 0, 250, Config.screenWidth, "center")
    love.graphics.printf(string.format("Time: %.1f seconds", State.levelTimer), 0, 280, Config.screenWidth, "center")
    
    if State.currentLevel < 30 then
        love.graphics.printf("Press SPACE for Next Level", 0, 330, Config.screenWidth, "center")
    else
        love.graphics.setColor(1, 1, 0)
        love.graphics.printf("CONGRATULATIONS!", 0, 330, Config.screenWidth, "center")
        love.graphics.printf("You escaped Hell with the souls!", 0, 360, Config.screenWidth, "center")
    end
    love.graphics.setColor(1, 1, 1)
    love.graphics.printf("Press R to Retry", 0, 400, Config.screenWidth, "center")
    love.graphics.printf("Press ESC for Menu", 0, 430, Config.screenWidth, "center")
    
    love.graphics.setFont(love.graphics.newFont(12))
end

return UI