local Player = {
    selectedBountyType = nil,
    cameraX = 0,
    cameraY = 0,
    cameraSpeed = 300,
    buildMode = false,
    selectedBuildingType = nil,
    selectedEntity = nil
}

function Player.load()
    -- Initialization if needed
end

function Player.update(dt)
    -- Camera movement with keyboard - fixed to work with scaled coordinates
    local scale = require('gamestate').cameraScale
    local scaledSpeed = Player.cameraSpeed * dt / scale
    
    if love.keyboard.isDown('w') then
        Player.cameraY = Player.cameraY - scaledSpeed
    end
    if love.keyboard.isDown('s') then
        Player.cameraY = Player.cameraY + scaledSpeed
    end
    if love.keyboard.isDown('a') then
        Player.cameraX = Player.cameraX - scaledSpeed
    end
    if love.keyboard.isDown('d') then
        Player.cameraX = Player.cameraX + scaledSpeed
    end
    
    -- Keep camera within bounds
    local map = require('map')
    local screenWidth = love.graphics.getWidth() / scale
    local screenHeight = love.graphics.getHeight() / scale
    
    Player.cameraX = math.max(0, math.min(Player.cameraX, map.width - screenWidth))
    Player.cameraY = math.max(0, math.min(Player.cameraY, map.height - screenHeight))
end

function Player.mousepressed(x, y, button)
    local scale = require('gamestate').cameraScale
    local worldX = (x / scale) + Player.cameraX
    local worldY = (y / scale) + Player.cameraY
    
    if button == 1 then -- Left click
        if Player.buildMode and Player.selectedBuildingType then
            -- Try to place building
            if require('map').isPassable(worldX, worldY) then
                local canBuild = true
                
                -- Check if location is free of other buildings
                for _, building in ipairs(require('game').getBuildings()) do
                    if building.isBuilt and math.abs(building.x - worldX) < 50 and math.abs(building.y - worldY) < 50 then
                        canBuild = false
                        break
                    end
                end
                
                if canBuild then
                    if require('game').startBuildingConstruction(Player.selectedBuildingType, worldX, worldY) then
                        Player.buildMode = false
                        Player.selectedBuildingType = nil
                    end
                end
            end
        elseif Player.selectedBountyType then
            -- Place a bounty
            local reward = 50 -- Default reward, could be made adjustable
            
            if require('game').spendCoins(reward) then
                local bounty = require('bounty').new(Player.selectedBountyType, worldX, worldY, reward)
                require('game').addBounty(bounty)
            end
        else
            -- Select units or buildings
            Player.selectedEntity = nil
            
            -- Check buildings first
            for _, building in ipairs(require('game').getBuildings()) do
                if building.isBuilt and math.abs(building.x - worldX) < building.width/2 and 
                   math.abs(building.y - worldY) < building.height/2 then
                    Player.selectedEntity = building
                    break
                end
            end
            
            -- Check heroes if no building selected
            if not Player.selectedEntity then
                for _, hero in ipairs(require('game').getHeroes()) do
                    if math.abs(hero.x - worldX) < hero.width/2 and 
                       math.abs(hero.y - worldY) < hero.height/2 then
                        Player.selectedEntity = hero
                        break
                    end
                end
            end
            
            -- Check weedlings if no hero selected
            if not Player.selectedEntity then
                for _, weedling in ipairs(require('game').weedlings) do
                    if math.abs(weedling.x - worldX) < weedling.width/2 and 
                       math.abs(weedling.y - worldY) < weedling.height/2 then
                        Player.selectedEntity = weedling
                        break
                    end
                end
            end
        end
    elseif button == 2 then -- Right click
        -- Cancel modes
        Player.buildMode = false
        Player.selectedBountyType = nil
        Player.selectedBuildingType = nil
        Player.selectedEntity = nil
    end
end

function Player.keypressed(key)
    -- Bounty selection shortcuts
    if key == '1' then
        Player.selectedBountyType = 'attack'
        Player.buildMode = false
    elseif key == '2' then
        Player.selectedBountyType = 'explore'
        Player.buildMode = false
    elseif key == '3' then
        Player.selectedBountyType = 'defend'
        Player.buildMode = false
    elseif key == 'b' then
        Player.buildMode = not Player.buildMode
        Player.selectedBountyType = nil
    elseif key == 'escape' then
        Player.selectedBountyType = nil
        Player.buildMode = false
        Player.selectedEntity = nil
    end
end

function Player.getCamera()
    return Player.cameraX, Player.cameraY
end

return Player