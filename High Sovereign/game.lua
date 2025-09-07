-- game.lua - Fixed syntax error
local Game = {
    heroes = {},
    buildings = {},
    enemies = {},
    bounties = {},
    fogOfWar = {},
    kushCoins = 1000,
    incomeTimer = 0,
    incomeInterval = 5,
    palace = nil,
    weedlings = {},
    kushCollectors = {},
    buildingInProgress = {},
    research = {},
    floatingTexts = {},
    messages = {},
    messageLog = {},
    gameTime = 0,
    victoryCondition = nil,
    defeatCondition = nil,
    initialLairCount = 0,
    economyStats = {
        totalIncome = 0,
        totalExpenses = 0,
        heroMaintenance = 0,
        buildingMaintenance = 0
    }
}

function Game.load()
    -- Initialize based on difficulty
    local difficulty = require('gamestate').difficulty
    if difficulty == "easy" then
        Game.kushCoins = 1500
        Game.incomeInterval = 4
    elseif difficulty == "hard" then
        Game.kushCoins = 500
        Game.incomeInterval = 6
    else
        Game.kushCoins = 1000
        Game.incomeInterval = 5
    end
    
    -- Initialize player
    require('player').load()
    
    -- Initialize message log
    Game:addMessage("Welcome to High Majesty! Place bounties to guide your heroes.")
end

function Game.generateMap()
    require('map').generate()
    
    -- Create palace if it doesn't exist
    if not Game.palace then
        local palaceX = require('map').width / 2
        local palaceY = require('map').height / 2
        Game.palace = require('buildings/palace').new(palaceX, palaceY)
        
        -- Make sure palace is in buildings list
        local palaceInList = false
        for _, building in ipairs(Game.buildings) do
            if building == Game.palace then
                palaceInList = true
                break
            end
        end
        
        if not palaceInList then
            table.insert(Game.buildings, 1, Game.palace)  -- Insert at beginning to ensure it's drawn
        end
        
        print("Palace created at position:", palaceX, palaceY)
    end
    
    -- Position palace at center
    local palaceX = require('map').width / 2
    local palaceY = require('map').height / 2
    Game.palace.x = palaceX
    Game.palace.y = palaceY
    
    -- Clear area around palace
    Game.revealArea(palaceX, palaceY, 15)
    
    -- Create initial guilds near palace
    local guilds = {
        require('buildings/guilds').IndicaKnightGuild(palaceX - 150, palaceY),
        require('buildings/guilds').SativaScoutGuild(palaceX + 150, palaceY)
    }
    
    for _, guild in ipairs(guilds) do
        table.insert(Game.buildings, guild)
    end
    
    -- Create a dispensary and chill lounge
    local dispensary = require('buildings/dispensary').new(palaceX, palaceY - 150)
    local lounge = require('buildings/chill_lounge').new(palaceX, palaceY + 150)
    
    table.insert(Game.buildings, dispensary)
    table.insert(Game.buildings, lounge)
    
    -- Create initial weedlings from palace
    for i = 1, 3 do
        local weedling = require('units/weedling').new(
            palaceX + love.math.random(-50, 50), 
            palaceY + love.math.random(-50, 50)
        )
        table.insert(Game.weedlings, weedling)
    end
    
    -- Create initial kush collector from palace
    local collector = require('units/kush_collector').new(palaceX, palaceY)
    table.insert(Game.kushCollectors, collector)
    
    -- Initialize fog of war
    Game.fogOfWar = {}
    local map = require('map')
    for x = 1, math.ceil(map.width / 32) do
        Game.fogOfWar[x] = {}
        for y = 1, math.ceil(map.height / 32) do
            Game.fogOfWar[x][y] = true
        end
    end
    
    -- Clear initial area around palace
    Game.revealArea(palaceX, palaceY, 15)
    
    -- Generate enemy lairs
    local difficulty = require('gamestate').difficulty
    local lairCount = 3
    
    if difficulty == "easy" then
        lairCount = 2
    elseif difficulty == "hard" then
        lairCount = 5
    end
    
    -- Place lairs in a circle around the palace
    for i = 1, lairCount do
        local angle = (i - 1) * (math.pi * 2 / lairCount) + love.math.random() * 0.3
        local distance = 600 + love.math.random(200, 400)
        
        if difficulty == "easy" then
            distance = distance * 1.3
        elseif difficulty == "hard" then
            distance = distance * 0.8
        end
        
        local lairX = palaceX + math.cos(angle) * distance
        local lairY = palaceY + math.sin(angle) * distance
        
        -- Ensure within map bounds
        lairX = math.max(200, math.min(map.width - 200, lairX))
        lairY = math.max(200, math.min(map.height - 200, lairY))
        
        -- Clear area around lair
        local gridX, gridY = math.floor(lairX / 32), math.floor(lairY / 32)
        for dx = -5, 5 do
            for dy = -5, 5 do
                local checkX, checkY = gridX + dx, gridY + dy
                if checkX >= 1 and checkX <= #map.terrain and 
                   checkY >= 1 and checkY <= #map.terrain[1] then
                    map.terrain[checkX][checkY] = "grass"
                end
            end
        end
        
        -- Create the lair
        local lair = require('enemies/lair').new(lairX, lairY)
        table.insert(Game.buildings, lair)
        
        Game:addMessage("Enemy lair detected in the " .. require('map').getDirectionFromPalace(lairX, lairY) .. "!")
    end
    
    Game.initialLairCount = lairCount
    
    Game:addMessage("Your kingdom has been established. " .. Game.initialLairCount .. " enemy lairs threaten the realm!")
    Game:addMessage("Palace generates Weedlings and Kush Collectors automatically!")
end

function Game.update(dt)
    Game.gameTime = Game.gameTime + dt
    
    -- Update income timer
    Game.incomeTimer = Game.incomeTimer + dt
    if Game.incomeTimer >= Game.incomeInterval then
        Game:processEconomy()
        Game.incomeTimer = 0
    end
    
    -- Update palace if it exists
    if Game.palace and Game.palace.isAlive then
        Game.palace:update(dt)
    end
    
    -- Update all entities
    for i = #Game.heroes, 1, -1 do
        local hero = Game.heroes[i]
        if hero then
            if hero.isAlive then
                hero:update(dt)
            else
                -- Hero died
                Game:addMessage(hero.name .. " has fallen!")
                table.remove(Game.heroes, i)
            end
        end
    end
    
    for i = #Game.enemies, 1, -1 do
        local enemy = Game.enemies[i]
        if enemy then
            if enemy.isAlive then
                enemy:update(dt)
            else
                table.remove(Game.enemies, i)
            end
        end
    end
    
    for _, building in ipairs(Game.buildings) do
        if building and building.update then
            building:update(dt)
        end
    end
    
    for i = #Game.weedlings, 1, -1 do
        local weedling = Game.weedlings[i]
        if weedling then
            if weedling.isAlive then
                weedling:update(dt)
            else
                table.remove(Game.weedlings, i)
            end
        end
    end
    
    for i = #Game.kushCollectors, 1, -1 do
        local collector = Game.kushCollectors[i]
        if collector then
            if collector.isAlive then
                collector:update(dt)
            else
                table.remove(Game.kushCollectors, i)
            end
        end
    end
    
    -- Update buildings in progress
    for i = #Game.buildingInProgress, 1, -1 do
        local construction = Game.buildingInProgress[i]
        if construction then
            construction.progress = (construction.progress or 0) + dt
            
            if construction.progress >= (construction.timeRequired or 10) then
                -- Construction complete
                local building = construction.building
                if building then
                    building.isBuilt = true
                    table.insert(Game.buildings, building)
                    Game:addMessage(building.type .. " construction complete!")
                end
                table.remove(Game.buildingInProgress, i)
            end
        end
    end
    
    -- Update bounties
    for i = #Game.bounties, 1, -1 do
        local bounty = Game.bounties[i]
        if bounty then
            if bounty.update then
                bounty:update(dt)
            end
            if bounty.completed then
                table.remove(Game.bounties, i)
            elseif bounty.expireTime and love.timer.getTime() > bounty.expireTime then
                Game:addMessage("Bounty expired!")
                table.remove(Game.bounties, i)
            end
        end
    end
    
    -- Update floating texts
    for i = #Game.floatingTexts, 1, -1 do
        local text = Game.floatingTexts[i]
        text.lifetime = text.lifetime - dt
        text.x = text.x + text.velocity[1] * dt
        text.y = text.y + text.velocity[2] * dt
        
        if text.lifetime <= 0 then
            table.remove(Game.floatingTexts, i)
        end
    end
    
    -- Update fog of war
    Game.updateFogOfWar()
    
    -- Check victory/defeat conditions
    Game:checkVictoryConditions()
end

function Game:processEconomy()
    local income = 0
    local expenses = 0
    
    -- Base palace income
    if Game.palace and Game.palace.isAlive and not Game.palace.isDestroyed then
        income = income + Game.palace.income
    end
    
    -- Building income and maintenance
    for _, building in ipairs(Game.buildings) do
        if building.isBuilt and not building.isDestroyed then
            -- Maintenance cost
            expenses = expenses + 1
        end
    end
    
    -- Hero maintenance
    for _, hero in ipairs(Game.heroes) do
        expenses = expenses + (2 + hero.level * 0.5)
    end
    
    -- Weedling and collector maintenance
    expenses = expenses + #Game.weedlings * 0.5
    expenses = expenses + #Game.kushCollectors * 0.5
    
    -- Apply income and expenses
    local netIncome = income - expenses
    Game.kushCoins = Game.kushCoins + netIncome
    
    -- Update economy stats
    Game.economyStats.totalIncome = income
    Game.economyStats.totalExpenses = expenses
    Game.economyStats.heroMaintenance = #Game.heroes * 2
    Game.economyStats.buildingMaintenance = #Game.buildings
    
    -- Notify player of economic status
    if netIncome < 0 and Game.kushCoins < 100 then
        Game:addMessage("Warning: Losing " .. math.abs(netIncome) .. " KC per cycle!")
    end
    
    -- Check for bankruptcy
    if Game.kushCoins < 0 then
        Game:addMessage("Treasury is empty! Heroes may desert!")
        
        -- Heroes might leave if not paid
        for i = #Game.heroes, 1, -1 do
            if love.math.random() < 0.1 then
                Game:addMessage(Game.heroes[i].name .. " has deserted due to lack of payment!")
                table.remove(Game.heroes, i)
            end
        end
    end
end

function Game:checkVictoryConditions()
    -- Check defeat conditions first
    if not Game.palace or not Game.palace.isAlive then
        Game.defeatCondition = "Your palace has been destroyed!"
        require('gamestate').endGame(false, Game.defeatCondition)
        return
    end
    
    if Game.kushCoins < -500 then
        Game.defeatCondition = "Your kingdom has gone bankrupt!"
        require('gamestate').endGame(false, Game.defeatCondition)
        return
    end
    
    -- Check victory conditions
    local lairsRemaining = 0
    for _, building in ipairs(Game.buildings) do
        if building.type == "lair" and building.isAlive then
            lairsRemaining = lairsRemaining + 1
        end
    end
    
    if lairsRemaining == 0 and Game.initialLairCount > 0 then
        Game.victoryCondition = "All enemy lairs have been destroyed!"
        require('gamestate').endGame(true, Game.victoryCondition)
        return
    end
    
    -- Alternative victory: Accumulate wealth
    if Game.kushCoins > 10000 then
        Game.victoryCondition = "Your kingdom has achieved legendary wealth!"
        require('gamestate').endGame(true, Game.victoryCondition)
        return
    end
end

function Game.updateFogOfWar()
    if not Game.fogOfWar then return end
    
    -- Darken all tiles first
    for x = 1, #Game.fogOfWar do
        for y = 1, #Game.fogOfWar[1] do
            if Game.fogOfWar[x] and Game.fogOfWar[x][y] == false then
                Game.fogOfWar[x][y] = "explored"
            end
        end
    end
    
    -- Reveal areas around heroes
    for _, hero in ipairs(Game.heroes) do
        if hero and hero.x and hero.y then
            Game.revealArea(hero.x, hero.y, hero.sightRadius or 5)
        end
    end
    
    -- Reveal areas around buildings
    for _, building in ipairs(Game.buildings) do
        if building and building.isBuilt then
            Game.revealArea(building.x, building.y, 3)
        end
    end
    
    -- Always reveal area around palace
    if Game.palace then
        Game.revealArea(Game.palace.x, Game.palace.y, 8)
    end
end

function Game.revealArea(x, y, radius)
    if not Game.fogOfWar then return end
    
    local centerX, centerY = math.floor(x / 32), math.floor(y / 32)
    
    for dx = -radius, radius do
        for dy = -radius, radius do
            if dx*dx + dy*dy <= radius*radius then
                local tx, ty = centerX + dx, centerY + dy
                if tx >= 1 and tx <= #Game.fogOfWar and 
                   ty >= 1 and Game.fogOfWar[tx][ty] ~= nil and
                   ty <= #Game.fogOfWar[1] then
                    Game.fogOfWar[tx][ty] = false
                end
            end
        end
    end
end

function Game.draw()
    -- Draw map
    require('map').draw()
    
    -- Draw buildings (palace should be first in the list)
    for _, building in ipairs(Game.buildings) do
        if building and building.draw then
            -- Check if visible
            local gridX, gridY = math.floor(building.x / 32), math.floor(building.y / 32)
            if gridX >= 1 and gridX <= #Game.fogOfWar and 
               gridY >= 1 and gridY <= #Game.fogOfWar[1] then
                if Game.fogOfWar[gridX][gridY] == false or 
                   Game.fogOfWar[gridX][gridY] == "explored" then
                    building:draw()
                end
            end
        end
    end
    
    -- Draw buildings in progress
    for _, construction in ipairs(Game.buildingInProgress) do
        if construction and construction.building then
            local building = construction.building
            local gridX, gridY = math.floor(building.x / 32), math.floor(building.y / 32)
            if gridX >= 1 and gridX <= #Game.fogOfWar and 
               gridY >= 1 and gridY <= #Game.fogOfWar[1] then
                if Game.fogOfWar[gridX][gridY] == false then
                    building:drawConstruction(construction.progress / construction.timeRequired)
                end
            end
        end
    end
    
    -- Draw enemies
    for _, enemy in ipairs(Game.enemies) do
        if enemy and enemy.draw then
            local gridX, gridY = math.floor(enemy.x / 32), math.floor(enemy.y / 32)
            if gridX >= 1 and gridX <= #Game.fogOfWar and 
               gridY >= 1 and gridY <= #Game.fogOfWar[1] then
                if Game.fogOfWar[gridX][gridY] == false then
                    enemy:draw()
                end
            end
        end
    end
    
    -- Draw heroes
    for _, hero in ipairs(Game.heroes) do
        if hero and hero.draw then
            hero:draw()
        end
    end
    
    -- Draw weedlings
    for _, weedling in ipairs(Game.weedlings) do
        if weedling and weedling.draw then
            local gridX, gridY = math.floor(weedling.x / 32), math.floor(weedling.y / 32)
            if gridX >= 1 and gridX <= #Game.fogOfWar and 
               gridY >= 1 and gridY <= #Game.fogOfWar[1] then
                if Game.fogOfWar[gridX][gridY] == false then
                    weedling:draw()
                end
            end
        end
    end
    
    -- Draw kush collectors
    for _, collector in ipairs(Game.kushCollectors) do
        if collector and collector.draw then
            local gridX, gridY = math.floor(collector.x / 32), math.floor(collector.y / 32)
            if gridX >= 1 and gridX <= #Game.fogOfWar and 
               gridY >= 1 and gridY <= #Game.fogOfWar[1] then
                if Game.fogOfWar[gridX][gridY] == false then
                    collector:draw()
                end
            end
        end
    end
    
    -- Draw bounties
    for _, bounty in ipairs(Game.bounties) do
        if bounty and bounty.draw then
            local gridX, gridY = math.floor(bounty.x / 32), math.floor(bounty.y / 32)
            if gridX >= 1 and gridX <= #Game.fogOfWar and 
               gridY >= 1 and gridY <= #Game.fogOfWar[1] then
                if Game.fogOfWar[gridX][gridY] == false or 
                   Game.fogOfWar[gridX][gridY] == "explored" then
                    bounty:draw()
                end
            end
        end
    end
    
    -- Draw fog of war
    if Game.fogOfWar then
        for x = 1, #Game.fogOfWar do
            for y = 1, #Game.fogOfWar[x] do
                if Game.fogOfWar[x][y] == true then
                    -- Unexplored - full black
                    love.graphics.setColor(0, 0, 0, 0.9)
                    love.graphics.rectangle("fill", (x-1)*32, (y-1)*32, 32, 32)
                elseif Game.fogOfWar[x][y] == "explored" then
                    -- Explored but not visible - semi-transparent
                    love.graphics.setColor(0, 0, 0, 0.5)
                    love.graphics.rectangle("fill", (x-1)*32, (y-1)*32, 32, 32)
                end
            end
        end
    end
    
    -- Draw floating texts
    for _, text in ipairs(Game.floatingTexts) do
        love.graphics.setColor(text.color[1], text.color[2], text.color[3], text.lifetime)
        love.graphics.print(text.text, text.x, text.y)
    end
end

function Game:addMessage(message)
    table.insert(Game.messageLog, {
        text = message,
        time = Game.gameTime
    })
    
    if #Game.messageLog > 100 then
        table.remove(Game.messageLog, 1)
    end
    
    table.insert(Game.messages, {
        text = message,
        lifetime = 5
    })
    
    if #Game.messages > 5 then
        table.remove(Game.messages, 1)
    end
end

function Game.startBuildingConstruction(buildingType, x, y)
    local building
    local cost = 0
    local guilds = require('buildings/guilds')
    
    -- Check prerequisites for guild buildings
    if buildingType:find("guild") then
        local canBuild, reason = guilds.checkPrerequisites(buildingType)
        if not canBuild then
            Game:addMessage(reason)
            return false
        end
    end
    
    -- Create the appropriate building
    if buildingType == "indica_knight_guild" then
        building = guilds.IndicaKnightGuild(x, y)
        cost = 200
    elseif buildingType == "gnome_chomper_guild" then
        building = guilds.GnomeChomperGuild(x, y)
        cost = 300
    elseif buildingType == "dabbler_guild" then
        building = guilds.DabblerGuild(x, y)
        cost = 400
    elseif buildingType == "sativa_scout_guild" then
        building = guilds.SativaScoutGuild(x, y)
        cost = 500
    elseif buildingType == "joint_roller_guild" then
        building = guilds.JointRollerGuild(x, y)
        cost = 600
    elseif buildingType == "psilocyber_guild" then
        building = guilds.PsilocyberStonerGuild(x, y)
        cost = 700
    elseif buildingType == "high_priest_guild" then
        building = guilds.HighPriestGuild(x, y)
        cost = 800
    elseif buildingType == "dispensary" then
        building = require('buildings/dispensary').new(x, y)
        cost = 150
    elseif buildingType == "chill_lounge" then
        building = require('buildings/chill_lounge').new(x, y)
        cost = 150
    elseif buildingType == "blacksmith" then
        building = require('buildings/blacksmith').new(x, y)
        cost = 250
    elseif buildingType == "library" then
        building = require('buildings/library').new(x, y)
        cost = 300
    end
    
    if building and Game.spendCoins(cost) then
        building.isBuilt = false
        local construction = {
            building = building,
            progress = 0,
            timeRequired = 10, -- 10 seconds to build
            assignedWeedling = nil
        }
        table.insert(Game.buildingInProgress, construction)
        
        -- Assign a weedling to build it
        for _, weedling in ipairs(Game.weedlings) do
            if weedling and weedling.isAlive and weedling.state == "idle" then
                weedling:assignConstruction(construction)
                break
            end
        end
        
        Game:addMessage("Construction started: " .. buildingType)
        return true
    else
        if not building then
            Game:addMessage("Unknown building type!")
        else
            Game:addMessage("Not enough Kush Coins! Need " .. cost .. " KC")
        end
    end
    return false
end

function Game.getConstructionProgress(building)
    for _, construction in ipairs(Game.buildingInProgress) do
        if construction.building == building then
            return construction.progress / construction.timeRequired
        end
    end
    return nil
end

function Game.addHero(hero)
    if hero then
        table.insert(Game.heroes, hero)
        Game:addMessage("A new hero has joined: " .. hero.name)
    end
end

function Game.addEnemy(enemy)
    if enemy then
        table.insert(Game.enemies, enemy)
    end
end

function Game.addBounty(bounty)
    if bounty then
        bounty.expireTime = love.timer.getTime() + 120
        table.insert(Game.bounties, bounty)
        Game:addMessage("New " .. bounty.bountyType .. " bounty placed (" .. bounty.reward .. " KC)")
    end
end

function Game.getBuildings()
    return Game.buildings or {}
end

function Game.getHeroes()
    return Game.heroes or {}
end

function Game.getEnemies()
    return Game.enemies or {}
end

function Game.getBounties()
    return Game.bounties or {}
end

function Game.spendCoins(amount)
    if Game.kushCoins >= (amount or 0) then
        Game.kushCoins = Game.kushCoins - amount
        return true
    end
    return false
end

function Game.addCoins(amount)
    Game.kushCoins = Game.kushCoins + (amount or 0)
end

return Game