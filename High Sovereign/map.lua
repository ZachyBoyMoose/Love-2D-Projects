-- map.lua - Improved map generation with better lair placement
local Map = {
    width = 4096,
    height = 4096,
    terrain = {}
}

function Map.generate()
    -- Generate terrain
    for x = 1, Map.width / 32 do
        Map.terrain[x] = {}
        for y = 1, Map.height / 32 do
            local value = love.math.random()
            
            -- Less water/bog for better playability
            if value < 0.05 then
                Map.terrain[x][y] = "water"
            elseif value < 0.1 then
                Map.terrain[x][y] = "bog"
            else
                Map.terrain[x][y] = "grass"
            end
        end
    end
    
    local game = require('game')
    
    -- Ensure player starting area is clear and large
    local startX, startY = math.floor(Map.width / 32 / 2), math.floor(Map.height / 32 / 2)
    for dx = -15, 15 do
        for dy = -15, 15 do
            local x, y = startX + dx, startY + dy
            if x >= 1 and x <= #Map.terrain and y >= 1 and y <= #Map.terrain[1] then
                Map.terrain[x][y] = "grass"
            end
        end
    end
    
    -- Place player palace at center
    local palaceX, palaceY = Map.width / 2, Map.height / 2
    if game.palace then
        game.palace.x = palaceX
        game.palace.y = palaceY
    else
        -- Create palace if it doesn't exist
        game.palace = require('buildings/palace').new(palaceX, palaceY)
        table.insert(game.buildings, game.palace)
    end
    
    -- Clear area around palace
    game.revealArea(palaceX, palaceY, 15)
    
    -- Place enemy lairs strategically
    local difficulty = require('gamestate').difficulty
    local lairCount = 3
    
    if difficulty == "easy" then
        lairCount = 2
    elseif difficulty == "normal" then
        lairCount = 3
    elseif difficulty == "hard" then
        lairCount = 5
    end
    
    print("Generating " .. lairCount .. " enemy lairs for " .. difficulty .. " difficulty...")
    
    -- Place lairs in a circle around the palace
    for i = 1, lairCount do
        local angle = (i - 1) * (math.pi * 2 / lairCount) + love.math.random() * 0.3
        local distance = 600 + love.math.random(200, 400)
        
        -- Adjust distance based on difficulty
        if difficulty == "easy" then
            distance = distance * 1.3
        elseif difficulty == "hard" then
            distance = distance * 0.8
        end
        
        local lairX = palaceX + math.cos(angle) * distance
        local lairY = palaceY + math.sin(angle) * distance
        
        -- Ensure within map bounds
        lairX = math.max(200, math.min(Map.width - 200, lairX))
        lairY = math.max(200, math.min(Map.height - 200, lairY))
        
        -- Clear area around lair
        local gridX, gridY = math.floor(lairX / 32), math.floor(lairY / 32)
        for dx = -5, 5 do
            for dy = -5, 5 do
                local checkX, checkY = gridX + dx, gridY + dy
                if checkX >= 1 and checkX <= #Map.terrain and 
                   checkY >= 1 and checkY <= #Map.terrain[1] then
                    Map.terrain[checkX][checkY] = "grass"
                end
            end
        end
        
        -- Create the lair
        local lair = require('enemies/lair').new(lairX, lairY)
        table.insert(game.buildings, lair)
        
        print("Created lair " .. i .. " at position: " .. math.floor(lairX) .. ", " .. math.floor(lairY))
        
        -- Add a message about the lair
        game:addMessage("Enemy lair detected in the " .. Map.getDirectionFromPalace(lairX, lairY) .. "!")
    end
    
    -- Update initial lair count for victory condition
    game.initialLairCount = lairCount
    
    -- Create some initial roaming enemies
    local roamingEnemies = 3
    if difficulty == "hard" then
        roamingEnemies = 6
    end
    
    for i = 1, roamingEnemies do
        local enemyX = palaceX + love.math.random(-800, 800)
        local enemyY = palaceY + love.math.random(-800, 800)
        
        -- Ensure not too close to palace
        if math.abs(enemyX - palaceX) > 200 or math.abs(enemyY - palaceY) > 200 then
            local gridX, gridY = math.floor(enemyX / 32), math.floor(enemyY / 32)
            if gridX >= 1 and gridX <= #Map.terrain and 
               gridY >= 1 and gridY <= #Map.terrain[1] and
               Map.terrain[gridX][gridY] == "grass" then
                
                local enemy
                if love.math.random() < 0.5 then
                    enemy = require('enemies/buzzkill_beetle').new(enemyX, enemyY)
                else
                    enemy = require('enemies/harvester_golem').new(enemyX, enemyY)
                end
                game.addEnemy(enemy)
            end
        end
    end
    
    print("Map generation complete. " .. lairCount .. " lairs created, " .. #game.enemies .. " enemies spawned.")
    game:addMessage("Your kingdom faces " .. lairCount .. " enemy lairs! Build your forces quickly!")
end

function Map.getDirectionFromPalace(x, y)
    local game = require('game')
    if not game.palace then return "unknown direction" end
    
    local dx = x - game.palace.x
    local dy = y - game.palace.y
    
    local angle = math.atan2(dy, dx)
    local octant = math.floor((angle + math.pi) / (math.pi / 4)) % 8
    
    local directions = {
        "East", "Northeast", "North", "Northwest",
        "West", "Southwest", "South", "Southeast"
    }
    
    return directions[octant + 1] or "unknown direction"
end

function Map.isPassable(x, y)
    local gridX, gridY = math.floor(x / 32), math.floor(y / 32)
    
    if gridX < 1 or gridX > #Map.terrain or 
       gridY < 1 or gridY > #Map.terrain[1] then
        return false
    end
    
    return Map.terrain[gridX][gridY] == "grass"
end

function Map.draw()
    -- Only draw visible portions of the map for performance
    local player = require('player')
    local scale = require('gamestate').cameraScale
    local screenWidth = love.graphics.getWidth() / scale
    local screenHeight = love.graphics.getHeight() / scale
    
    local startX = math.max(1, math.floor(player.cameraX / 32))
    local endX = math.min(#Map.terrain, math.ceil((player.cameraX + screenWidth) / 32))
    local startY = math.max(1, math.floor(player.cameraY / 32))
    local endY = math.min(#Map.terrain[1], math.ceil((player.cameraY + screenHeight) / 32))
    
    -- Draw terrain
    for x = startX, endX do
        for y = startY, endY do
            local screenX = (x - 1) * 32
            local screenY = (y - 1) * 32
            
            if Map.terrain[x][y] == "grass" then
                love.graphics.setColor(0.2, 0.4, 0.2)
            elseif Map.terrain[x][y] == "water" then
                love.graphics.setColor(0.2, 0.2, 0.6)
            elseif Map.terrain[x][y] == "bog" then
                love.graphics.setColor(0.3, 0.4, 0.3)
            end
            
            love.graphics.rectangle("fill", screenX, screenY, 32, 32)
            
            -- Add subtle grid lines
            love.graphics.setColor(0, 0, 0, 0.1)
            love.graphics.rectangle("line", screenX, screenY, 32, 32)
        end
    end
end

return Map