local Menu = {
    buttons = {},
    selectedDifficulty = "normal"
}

function Menu.load()
    -- Create menu buttons
    Menu.buttons = {
        {
            text = "Start New Kingdom",
            x = 350,
            y = 250,
            width = 300,
            height = 50,
            action = function() 
                require('gamestate').startGame() 
            end
        },
        {
            text = "Difficulty: " .. Menu.selectedDifficulty,
            x = 350,
            y = 320,
            width = 300,
            height = 50,
            action = function() 
                Menu.cycleDifficulty() 
            end
        },
        {
            text = "Quit",
            x = 350,
            y = 390,
            width = 300,
            height = 50,
            action = function() 
                require('gamestate').quitGame() 
            end
        }
    }
end

function Menu.update(dt)
    -- Menu doesn't need update logic for now
end

function Menu.draw()
    -- Draw background
    love.graphics.setColor(0.1, 0.1, 0.1)
    love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
    
    -- Draw title
    love.graphics.setColor(0.5, 0, 0.5)
    love.graphics.setFont(love.graphics.newFont(36))
    love.graphics.print("HIGH MAJESTY", 350, 150)
    
    -- Draw buttons
    for _, button in ipairs(Menu.buttons) do
        love.graphics.setColor(0.3, 0.3, 0.3)
        love.graphics.rectangle("fill", button.x, button.y, button.width, button.height)
        
        love.graphics.setColor(1, 1, 1)
        love.graphics.setFont(love.graphics.newFont(24))
        love.graphics.print(button.text, button.x + 20, button.y + 10)
    end
end

function Menu.mousepressed(x, y, button)
    if button == 1 then -- Left click
        for _, btn in ipairs(Menu.buttons) do
            if x >= btn.x and x <= btn.x + btn.width and
               y >= btn.y and y <= btn.y + btn.height then
                btn.action()
                -- Update difficulty button text
                if btn.text:find("Difficulty") then
                    btn.text = "Difficulty: " .. Menu.selectedDifficulty
                end
            end
        end
    end
end

function Menu.keypressed(key)
    -- Menu keyboard controls
    if key == "escape" then
        require('gamestate').quitGame()
    end
end

function Menu.cycleDifficulty()
    local difficulties = {"easy", "normal", "hard"}
    for i, diff in ipairs(difficulties) do
        if diff == Menu.selectedDifficulty then
            Menu.selectedDifficulty = difficulties[i % #difficulties + 1]
            require('gamestate').setDifficulty(Menu.selectedDifficulty)
            break
        end
    end
end

return Menu