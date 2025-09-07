-- ui.lua - Enhanced UI with tech tree requirements
local UI = {
    buildMenuOpen = false,
    buildOptions = {},
    selectedTab = "economy",
    minimapScale = 0.05,
    messageDisplayTime = 5
}

function UI.initBuildOptions()
    -- Initialize build options with tech tree order
    UI.buildOptions = {
        -- Tier 1
        {"indica_knight_guild", "Indica Knight Guild", 200, 1, nil},
        -- Tier 2
        {"gnome_chomper_guild", "Gnome Chompers' Mine", 300, 2, "indica_knight_guild"},
        -- Tier 3
        {"dabbler_guild", "Dabblers' Den", 400, 3, "gnome_chomper_guild"},
        -- Tier 4
        {"sativa_scout_guild", "Sativa Scout Post", 500, 4, "dabbler_guild"},
        -- Tier 5
        {"joint_roller_guild", "Joint Rollers' Circle", 600, 5, "sativa_scout_guild"},
        -- Tier 6
        {"psilocyber_guild", "Enlightened Ents Lodge", 700, 6, "joint_roller_guild"},
        -- Tier 7
        {"high_priest_guild", "Temple of High Priest", 800, 7, "psilocyber_guild"},
        -- Support buildings (no tier)
        {"dispensary", "Dispensary", 150, 0, nil},
        {"chill_lounge", "Chill Lounge", 150, 0, nil},
        {"blacksmith", "The Grinder", 250, 0, nil},
        {"library", "Seed Vault", 300, 0, nil}
    }
end

-- Initialize on load
UI.initBuildOptions()

function UI.drawBuildMenu()
    local x = 260
    local y = 80
    local width = 350
    local itemHeight = 50
    local height = 60 + #UI.buildOptions * itemHeight
    
    -- Draw background with border
    love.graphics.setColor(0.1, 0.1, 0.1, 0.95)
    love.graphics.rectangle("fill", x, y, width, height)
    love.graphics.setColor(0.5, 0.5, 0.5)
    love.graphics.setLineWidth(2)
    love.graphics.rectangle("line", x, y, width, height)
    love.graphics.setLineWidth(1)
    
    -- Title
    love.graphics.setColor(1, 1, 1)
    love.graphics.setFont(love.graphics.newFont(16))
    love.graphics.print("Build Menu - Tech Tree", x + 10, y + 10)
    love.graphics.setFont(love.graphics.newFont(10))
    love.graphics.print("(Buildings unlock in order - Right-click to cancel)", x + 10, y + 30)
    
    -- Draw tech tree progression line
    love.graphics.setColor(0.3, 0.3, 0.3)
    love.graphics.setLineWidth(2)
    local lineX = x + 15
    local startY = y + 60
    local endY = startY + (7 * itemHeight)  -- 7 tiers
    love.graphics.line(lineX, startY, lineX, endY)
    love.graphics.setLineWidth(1)
    
    -- Draw building options with tier indicators
    love.graphics.setFont(love.graphics.newFont(12))
    for i, option in ipairs(UI.buildOptions) do
        local optionY = y + 55 + (i-1) * itemHeight
        local game = require('game')
        local guilds = require('buildings/guilds')
        
        -- Check prerequisites
        local canBuild, reason = true, ""
        if option[5] then  -- Has prerequisite
            canBuild, reason = guilds.checkPrerequisites(option[1])
        end
        
        local canAfford = game.kushCoins >= option[3]
        local isAvailable = canBuild and canAfford
        
        -- Highlight if mouse is over
        local mx, my = love.mouse.getPosition()
        if mx >= x and mx <= x + width and my >= optionY and my <= optionY + itemHeight - 5 then
            if isAvailable then
                love.graphics.setColor(0.3, 0.3, 0.3, 0.8)
            else
                love.graphics.setColor(0.2, 0.1, 0.1, 0.8)
            end
            love.graphics.rectangle("fill", x + 5, optionY, width - 10, itemHeight - 5)
        end
        
        -- Draw tier indicator for guild buildings
        if option[4] > 0 then
            love.graphics.setColor(1, 1, 1)
            love.graphics.circle("fill", lineX, optionY + itemHeight/2, 5)
            love.graphics.setColor(0, 0, 0)
            love.graphics.setFont(love.graphics.newFont(8))
            love.graphics.print(tostring(option[4]), lineX - 2, optionY + itemHeight/2 - 5)
        end
        
        -- Building name
        love.graphics.setFont(love.graphics.newFont(13))
        if isAvailable then
            love.graphics.setColor(1, 1, 1)
        elseif not canBuild then
            love.graphics.setColor(0.5, 0.3, 0.3)
        else
            love.graphics.setColor(0.5, 0.5, 0.5)
        end
        
        local nameX = option[4] > 0 and (x + 30) or (x + 10)
        love.graphics.print(option[2], nameX, optionY + 5)
        
        -- Tier label
        if option[4] > 0 then
            love.graphics.setColor(0.7, 0.7, 0.7)
            love.graphics.setFont(love.graphics.newFont(9))
            love.graphics.print("Tier " .. option[4], nameX, optionY + 20)
        end
        
        -- Cost
        if canAfford then
            love.graphics.setColor(1, 1, 0)
        else
            love.graphics.setColor(1, 0, 0)
        end
        love.graphics.setFont(love.graphics.newFont(12))
        love.graphics.print(option[3] .. " KC", x + width - 60, optionY + 5)
        
        -- Prerequisite or description
        love.graphics.setColor(0.6, 0.6, 0.6)
        love.graphics.setFont(love.graphics.newFont(9))
        
        if not canBuild and reason ~= "" then
            love.graphics.setColor(1, 0.5, 0.5)
            love.graphics.print(reason, nameX, optionY + 33)
        else
            local desc = ""
            if option[1]:find("guild") then
                desc = "Recruits heroes"
            elseif option[1] == "dispensary" then
                desc = "Heroes buy equipment"
            elseif option[1] == "chill_lounge" then
                desc = "Heroes rest and heal"
            elseif option[1] == "blacksmith" then
                desc = "Weapon upgrades"
            elseif option[1] == "library" then
                desc = "Global upgrades"
            end
            love.graphics.print(desc, nameX, optionY + 33)
        end
        
        -- Lock icon if unavailable
        if not canBuild then
            love.graphics.setColor(1, 0.5, 0.5)
            love.graphics.setFont(love.graphics.newFont(16))
            love.graphics.print("🔒", x + width - 85, optionY + 5)
        end
    end
end

function UI.mousepressed(x, y, button)
    local player = require('player')
    local game = require('game')
    
    if player.buildMode and button == 1 then
        -- Check if clicked on build menu
        local menuX = 260
        local menuY = 80
        local menuWidth = 350
        local itemHeight = 50
        
        if x >= menuX and x <= menuX + menuWidth then
            local optionIndex = math.floor((y - menuY - 55) / itemHeight) + 1
            if optionIndex >= 1 and optionIndex <= #UI.buildOptions then
                local option = UI.buildOptions[optionIndex]
                local guilds = require('buildings/guilds')
                
                -- Check if can build this
                local canBuild = true
                local reason = ""
                
                if option[5] then  -- Has prerequisite
                    canBuild, reason = guilds.checkPrerequisites(option[1])
                end
                
                if not canBuild then
                    game:addMessage(reason)
                elseif game.kushCoins >= option[3] then
                    player.selectedBuildingType = option[1]
                else
                    game:addMessage("Not enough Kush Coins! Need " .. option[3] .. " KC")
                end
            end
        end
    end
    
    -- Check if clicked on entity buttons
    if player.selectedEntity then
        local buttonX = love.graphics.getWidth() - 270
        local buttonY = 60 + 250 - 35
        
        -- Upgrade button
        if player.selectedEntity.upgradeCost and button == 1 then
            if x >= buttonX + 10 and x <= buttonX + 120 and
               y >= buttonY and y <= buttonY + 25 then
                player.selectedEntity:upgrade()
            end
        end
        
        -- Recruit button
        if player.selectedEntity.recruitCost and button == 1 then
            if x >= buttonX + 130 and x <= buttonX + 240 and
               y >= buttonY and y <= buttonY + 25 then
                player.selectedEntity:recruit()
            end
        end
    end
end

-- The rest of the UI functions remain the same
function UI.draw()
    local game = require('game')
    local player = require('player')
    local scale = require('gamestate').cameraScale
    
    -- Draw main UI panel with better spacing
    UI.drawMainPanel()
    
    -- Draw minimap in bottom right
    UI.drawMiniMap()
    
    -- Draw messages in bottom left
    UI.drawMessages()
    
    -- Draw resource and economy info at top
    UI.drawEconomyInfo()
    
    -- Draw hero list on left side
    UI.drawHeroList()
    
    -- Draw selected entity info on right
    if player.selectedEntity then
        UI.drawEntityInfo(player.selectedEntity)
    end
    
    -- Draw build mode UI
    if player.buildMode then
        UI.drawBuildMenu()
        UI.drawBuildingGhost()
    end
    
    -- Draw bounty mode indicator with clear labels
    if player.selectedBountyType then
        UI.drawBountyIndicator(player.selectedBountyType)
    end
    
    -- Draw controls help at bottom
    UI.drawControls()
end

function UI.drawMainPanel()
    -- Top bar background - increased height
    love.graphics.setColor(0, 0, 0, 0.8)
    love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), 50)
    
    -- Left panel background - better spacing
    love.graphics.setColor(0, 0, 0, 0.6)
    love.graphics.rectangle("fill", 0, 50, 220, 350)
end

function UI.drawEconomyInfo()
    local game = require('game')
    
    -- Draw Kush Coins with larger, clearer icon
    love.graphics.setColor(1, 1, 0)
    love.graphics.circle("fill", 25, 25, 10)
    love.graphics.setColor(0, 0, 0)
    love.graphics.setFont(love.graphics.newFont(12))
    love.graphics.print("KC", 18, 18)
    
    -- Draw coin amount with better spacing
    love.graphics.setColor(1, 1, 1)
    love.graphics.setFont(love.graphics.newFont(16))
    love.graphics.print(tostring(math.floor(game.kushCoins)), 45, 18)
    
    -- Draw income/expense info with color coding
    local netIncome = game.economyStats.totalIncome - game.economyStats.totalExpenses
    if netIncome >= 0 then
        love.graphics.setColor(0, 1, 0)
        love.graphics.print("+" .. netIncome .. "/cycle", 150, 18)
    else
        love.graphics.setColor(1, 0, 0)
        love.graphics.print(netIncome .. "/cycle", 150, 18)
    end
    
    -- Draw timer bar for next income cycle
    local cycleProgress = game.incomeTimer / game.incomeInterval
    love.graphics.setColor(0.3, 0.3, 0.3)
    love.graphics.rectangle("fill", 250, 20, 100, 10)
    love.graphics.setColor(0.8, 0.8, 0.2)
    love.graphics.rectangle("fill", 250, 20, 100 * cycleProgress, 10)
    love.graphics.setColor(1, 1, 1)
    love.graphics.setFont(love.graphics.newFont(10))
    love.graphics.print("Next Income", 255, 8)
    
    -- Palace status indicator
    if game.palace then
        if game.palace.hp < game.palace.maxHp * 0.3 then
            love.graphics.setColor(1, 0, 0, 0.5 + math.sin(love.timer.getTime() * 5) * 0.5)
            love.graphics.setFont(love.graphics.newFont(14))
            love.graphics.print("⚠ PALACE UNDER ATTACK ⚠", 400, 18)
        end
    end
    
    -- Detailed economy breakdown with better spacing
    love.graphics.setFont(love.graphics.newFont(12))
    love.graphics.setColor(0.9, 0.9, 0.9)
    love.graphics.print("Economy Details:", 10, 60)
    
    love.graphics.setColor(0.7, 0.7, 0.7)
    love.graphics.print("Income: " .. game.economyStats.totalIncome .. " KC", 10, 80)
    love.graphics.print("Expenses: " .. game.economyStats.totalExpenses .. " KC", 10, 95)
    love.graphics.print("Heroes: " .. #game.heroes .. " (-" .. game.economyStats.heroMaintenance .. " KC)", 10, 110)
    love.graphics.print("Buildings: " .. #game.buildings, 10, 125)
    
    -- Weedlings and Collectors count
    love.graphics.print("Weedlings: " .. #game.weedlings .. "/" .. (game.palace and game.palace.maxWeedlings or 0), 10, 140)
    love.graphics.print("Collectors: " .. #game.kushCollectors .. "/" .. (game.palace and game.palace.maxCollectors or 0), 10, 155)
    
    -- Victory progress with clear labeling
    local lairCount = 0
    for _, building in ipairs(game.buildings) do
        if building.type == "lair" and building.isAlive then
            lairCount = lairCount + 1
        end
    end
    
    love.graphics.setColor(1, 0.5, 0)
    love.graphics.setFont(love.graphics.newFont(14))
    love.graphics.print("Enemy Lairs: " .. lairCount .. "/" .. game.initialLairCount, 10, 175)
    
    -- Game time with better formatting
    love.graphics.setColor(0.7, 0.7, 0.7)
    love.graphics.setFont(love.graphics.newFont(12))
    local minutes = math.floor(game.gameTime / 60)
    local seconds = math.floor(game.gameTime % 60)
    love.graphics.print(string.format("Time: %d:%02d", minutes, seconds), 10, 195)
end

function UI.drawEntityInfo(entity)
    local x = love.graphics.getWidth() - 270
    local y = 60
    local width = 260
    local height = 280
    
    -- Draw background with border
    love.graphics.setColor(0.1, 0.1, 0.1, 0.95)
    love.graphics.rectangle("fill", x, y, width, height)
    love.graphics.setColor(0.5, 0.5, 0.5)
    love.graphics.rectangle("line", x, y, width, height)
    
    love.graphics.setColor(1, 1, 1)
    love.graphics.setFont(love.graphics.newFont(14))
    
    -- Entity type and name
    if entity.name then
        love.graphics.print(entity.name, x + 10, y + 10)
        love.graphics.setFont(love.graphics.newFont(11))
        love.graphics.print("Type: " .. (entity.type or "Unknown"), x + 10, y + 28)
    else
        love.graphics.print("Type: " .. (entity.type or "Unknown"), x + 10, y + 10)
    end
    
    -- Show if destroyed
    if entity.isDestroyed then
        love.graphics.setColor(1, 0, 0)
        love.graphics.setFont(love.graphics.newFont(14))
        love.graphics.print("DESTROYED", x + width - 80, y + 10)
        love.graphics.setColor(1, 1, 1)
        love.graphics.setFont(love.graphics.newFont(11))
        love.graphics.print("Repair Cost: " .. (entity.repairCost or 0) .. " KC", x + 10, y + 45)
    end
    
    -- Health
    if entity.hp and entity.maxHp then
        love.graphics.setFont(love.graphics.newFont(12))
        love.graphics.print("HP: " .. math.floor(entity.hp) .. "/" .. math.floor(entity.maxHp), x + 10, y + 45)
        
        -- Health bar
        love.graphics.setColor(0.2, 0, 0)
        love.graphics.rectangle("fill", x + 10, y + 62, width - 20, 8)
        love.graphics.setColor(0, 1, 0)
        love.graphics.rectangle("fill", x + 10, y + 62, (width - 20) * (entity.hp / entity.maxHp), 8)
    end
    
    -- Guild-specific info
    if entity.type and entity.type:find("guild") then
        love.graphics.setColor(1, 1, 1)
        love.graphics.setFont(love.graphics.newFont(12))
        love.graphics.print("Guild Level: " .. (entity.level or 1) .. "/" .. (entity.maxLevel or 3), x + 10, y + 75)
        love.graphics.print("Tier: " .. (entity.tier or 1), x + 150, y + 75)
        love.graphics.print("Heroes: " .. (entity.currentHeroes or 0) .. "/" .. (entity.maxHeroes or 0), x + 10, y + 90)
        
        -- Show if can function
        if not entity:canFunction() then
            love.graphics.setColor(1, 0, 0)
            love.graphics.print("NON-FUNCTIONAL", x + 10, y + 105)
        end
        
        -- Show housed heroes
        if entity.housedHeroes and #entity.housedHeroes > 0 then
            love.graphics.setColor(1, 1, 1)
            love.graphics.print("Housed Heroes:", x + 10, y + 120)
            love.graphics.setColor(0.7, 0.7, 0.7)
            love.graphics.setFont(love.graphics.newFont(10))
            for i = 1, math.min(3, #entity.housedHeroes) do
                local hero = entity.housedHeroes[i]
                love.graphics.print("• " .. hero.name .. " (L" .. hero.level .. ")", x + 20, y + 120 + i * 15)
            end
        end
    end
    
    -- Tax information for buildings
    if entity.taxAmount and entity.taxAmount > 0 then
        love.graphics.setColor(1, 1, 0)
        love.graphics.setFont(love.graphics.newFont(12))
        love.graphics.print("Tax Ready: " .. math.floor(entity.taxAmount) .. " KC", x + 10, y + 200)
    end
    
    -- Building-specific buttons (only if not destroyed)
    if not entity.isDestroyed then
        if entity.upgradeCost and entity.upgradeCost > 0 then
            -- Check if entity has maxLevel, default to 999 if not
            local maxLevel = entity.maxLevel or 999
            if entity.level and entity.level < maxLevel then
                local buttonY = y + height - 35
                love.graphics.setColor(0.3, 0.3, 0.3)
                love.graphics.rectangle("fill", x + 10, buttonY, 110, 25)
                love.graphics.setColor(1, 1, 1)
                love.graphics.setFont(love.graphics.newFont(11))
                love.graphics.print("Upgrade (" .. entity.upgradeCost .. " KC)", x + 15, buttonY + 5)
            end
        end
        
        if entity.type and entity.type:find("guild") and entity.recruitCost then
            local buttonY = y + height - 35
            love.graphics.setColor(0.3, 0.3, 0.3)
            love.graphics.rectangle("fill", x + 130, buttonY, 110, 25)
            love.graphics.setColor(1, 1, 1)
            love.graphics.setFont(love.graphics.newFont(11))
            love.graphics.print("Recruit (" .. entity.recruitCost .. " KC)", x + 135, buttonY + 5)
        end
    end
end

function UI.drawMiniMap()
    local game = require('game')
    local player = require('player')
    local map = require('map')
    local scale = UI.minimapScale
    local width = 200
    local height = 200
    local x = love.graphics.getWidth() - width - 10
    local y = love.graphics.getHeight() - height - 10
    
    -- Draw background with border
    love.graphics.setColor(0, 0, 0, 0.9)
    love.graphics.rectangle("fill", x - 3, y - 3, width + 6, height + 6)
    love.graphics.setColor(0.5, 0.5, 0.5)
    love.graphics.rectangle("line", x - 3, y - 3, width + 6, height + 6)
    
    -- Draw terrain (simplified for performance)
    for tx = 1, #map.terrain, 4 do
        for ty = 1, #map.terrain[1], 4 do
            local mx = x + (tx * 32 * scale)
            local my = y + (ty * 32 * scale)
            
            -- Color based on fog of war
            local fogValue = game.fogOfWar[tx] and game.fogOfWar[tx][ty]
            
            if fogValue == true then
                -- Unexplored
                love.graphics.setColor(0, 0, 0, 1)
            elseif fogValue == "explored" then
                -- Explored but not visible
                if map.terrain[tx][ty] == "water" then
                    love.graphics.setColor(0, 0, 0.3, 1)
                elseif map.terrain[tx][ty] == "bog" then
                    love.graphics.setColor(0.1, 0.1, 0, 1)
                else
                    love.graphics.setColor(0, 0.2, 0, 1)
                end
            else
                -- Currently visible
                if map.terrain[tx][ty] == "water" then
                    love.graphics.setColor(0, 0, 0.6, 1)
                elseif map.terrain[tx][ty] == "bog" then
                    love.graphics.setColor(0.3, 0.3, 0, 1)
                else
                    love.graphics.setColor(0, 0.4, 0, 1)
                end
            end
            
            love.graphics.rectangle("fill", mx, my, 4, 4)
        end
    end
    
    -- Draw buildings with clear icons
    for _, building in ipairs(game.buildings) do
        local bx = x + (building.x * scale)
        local by = y + (building.y * scale)
        
        if building.type == "palace" then
            love.graphics.setColor(0.5, 0, 0.5)
            love.graphics.circle("fill", bx, by, 4)
            love.graphics.setColor(1, 1, 1)
            love.graphics.print("P", bx - 3, by - 4)
        elseif building.type == "lair" then
            love.graphics.setColor(1, 0, 0)
            love.graphics.rectangle("fill", bx - 3, by - 3, 6, 6)
            love.graphics.setColor(0, 0, 0)
            love.graphics.print("L", bx - 3, by - 4)
        elseif building.type:find("guild") then
            love.graphics.setColor(0, 0.5, 1)
            love.graphics.rectangle("fill", bx - 2, by - 2, 4, 4)
        else
            love.graphics.setColor(0.5, 0.5, 0.5)
            love.graphics.rectangle("fill", bx - 1, by - 1, 2, 2)
        end
    end
    
    -- Draw heroes as bright dots
    for _, hero in ipairs(game.heroes) do
        local hx = x + (hero.x * scale)
        local hy = y + (hero.y * scale)
        
        love.graphics.setColor(1, 1, 0)
        love.graphics.circle("fill", hx, hy, 2)
    end
    
    -- Draw enemies as red dots
    for _, enemy in ipairs(game.enemies) do
        local ex = x + (enemy.x * scale)
        local ey = y + (enemy.y * scale)
        
        love.graphics.setColor(1, 0, 0)
        love.graphics.circle("fill", ex, ey, 1)
    end
    
    -- Draw bounties with clear markers
    for _, bounty in ipairs(game.bounties) do
        local bx = x + (bounty.x * scale)
        local by = y + (bounty.y * scale)
        
        if bounty.bountyType == "attack" then
            love.graphics.setColor(1, 0, 0, 0.8)
        elseif bounty.bountyType == "explore" then
            love.graphics.setColor(1, 1, 0, 0.8)
        else -- defend
            love.graphics.setColor(0, 0, 1, 0.8)
        end
        love.graphics.circle("line", bx, by, 3)
    end
    
    -- Draw camera viewport
    local screenWidth = love.graphics.getWidth() / require('gamestate').cameraScale
    local screenHeight = love.graphics.getHeight() / require('gamestate').cameraScale
    local vx = x + (player.cameraX * scale)
    local vy = y + (player.cameraY * scale)
    local vw = screenWidth * scale
    local vh = screenHeight * scale
    
    love.graphics.setColor(1, 1, 1, 0.5)
    love.graphics.setLineWidth(2)
    love.graphics.rectangle("line", vx, vy, vw, vh)
    love.graphics.setLineWidth(1)
end

function UI.drawHeroList()
    local game = require('game')
    local y = 215
    
    love.graphics.setColor(1, 1, 1)
    love.graphics.setFont(love.graphics.newFont(14))
    love.graphics.print("Heroes (" .. #game.heroes .. "/" .. "∞)", 10, y)
    y = y + 20
    
    -- Show first 6 heroes with better spacing
    love.graphics.setFont(love.graphics.newFont(11))
    for i = 1, math.min(6, #game.heroes) do
        local hero = game.heroes[i]
        
        -- Hero name and level
        love.graphics.setColor(0.9, 0.9, 0.9)
        love.graphics.print(hero.name .. " (L" .. hero.level .. ")", 10, y)
        
        -- Hero state with color coding
        local stateColor = {0.5, 0.5, 0.5}
        local stateText = hero.state
        
        if hero.state == "fighting" then
            stateColor = {1, 0, 0}
            stateText = "Fighting!"
        elseif hero.state == "pursuing_bounty" then
            stateColor = {1, 1, 0}
            stateText = "On Quest"
        elseif hero.state == "resting" then
            stateColor = {0, 0.5, 1}
            stateText = "Resting"
        elseif hero.state == "fleeing" then
            stateColor = {1, 0.5, 0}
            stateText = "Fleeing!"
        elseif hero.state == "shopping" then
            stateColor = {0.5, 1, 0.5}
            stateText = "Shopping"
        end
        
        love.graphics.setColor(stateColor[1], stateColor[2], stateColor[3])
        love.graphics.print(stateText, 130, y)
        
        -- Health and focus bars
        local barWidth = 80
        local barHeight = 4
        
        -- Health bar
        love.graphics.setColor(0.2, 0, 0)
        love.graphics.rectangle("fill", 10, y + 14, barWidth, barHeight)
        love.graphics.setColor(0, 1, 0)
        love.graphics.rectangle("fill", 10, y + 14, barWidth * (hero.hp / hero.maxHp), barHeight)
        
        -- Focus bar
        love.graphics.setColor(0, 0, 0.2)
        love.graphics.rectangle("fill", 95, y + 14, barWidth, barHeight)
        love.graphics.setColor(0, 0.5, 1)
        love.graphics.rectangle("fill", 95, y + 14, barWidth * (hero.focus / hero.maxFocus), barHeight)
        
        y = y + 25
    end
    
    if #game.heroes > 6 then
        love.graphics.setColor(0.5, 0.5, 0.5)
        love.graphics.print("... and " .. (#game.heroes - 6) .. " more heroes", 10, y)
    end
end

function UI.drawMessages()
    local game = require('game')
    local x = 10
    local y = love.graphics.getHeight() - 120
    local maxWidth = 450
    
    -- Draw message background if there are messages
    if #game.messages > 0 then
        love.graphics.setColor(0, 0, 0, 0.7)
        love.graphics.rectangle("fill", x - 5, y - 5, maxWidth, #game.messages * 18 + 10)
    end
    
    -- Draw messages with fade effect
    love.graphics.setFont(love.graphics.newFont(12))
    for i, message in ipairs(game.messages) do
        local alpha = message.lifetime / UI.messageDisplayTime
        love.graphics.setColor(1, 1, 1, alpha)
        love.graphics.print(message.text, x, y + (i-1) * 18)
        
        -- Update message lifetime
        message.lifetime = message.lifetime - love.timer.getDelta()
    end
    
    -- Remove expired messages
    for i = #game.messages, 1, -1 do
        if game.messages[i].lifetime <= 0 then
            table.remove(game.messages, i)
        end
    end
end

function UI.drawBuildingGhost()
    local player = require('player')
    local scale = require('gamestate').cameraScale
    
    if not player.selectedBuildingType then return end
    
    local mouseX, mouseY = love.mouse.getPosition()
    local worldX = (mouseX / scale) + player.cameraX
    local worldY = (mouseY / scale) + player.cameraY
    
    -- Check if placement is valid
    local isValid = require('map').isPassable(worldX, worldY)
    local game = require('game')
    
    -- Check distance from other buildings
    for _, building in ipairs(game.getBuildings()) do
        if building.isBuilt and math.abs(building.x - worldX) < 50 and math.abs(building.y - worldY) < 50 then
            isValid = false
            break
        end
    end
    
    -- Draw ghost building
    if isValid then
        love.graphics.setColor(0, 1, 0, 0.5)
    else
        love.graphics.setColor(1, 0, 0, 0.5)
    end
    
    love.graphics.rectangle("fill", worldX - 22, worldY - 22, 45, 45)
    love.graphics.setColor(1, 1, 1, 0.5)
    love.graphics.rectangle("line", worldX - 22, worldY - 22, 45, 45)
    
    -- Show placement status
    love.graphics.setColor(1, 1, 1)
    love.graphics.setFont(love.graphics.newFont(10))
    if isValid then
        love.graphics.print("Click to build", worldX - 30, worldY - 35)
    else
        love.graphics.print("Invalid location!", worldX - 35, worldY - 35)
    end
end

function UI.drawBountyIndicator(bountyType)
    local scale = require('gamestate').cameraScale
    local mouseX, mouseY = love.mouse.getPosition()
    local worldX = (mouseX / scale) + require('player').cameraX
    local worldY = (mouseY / scale) + require('player').cameraY
    
    -- Draw bounty flag preview with clear type indication
    local color = {1, 1, 1}
    local text = ""
    
    if bountyType == 'attack' then
        color = {1, 0, 0, 0.8}
        text = "ATTACK"
    elseif bountyType == 'explore' then
        color = {1, 1, 0, 0.8}
        text = "EXPLORE"
    elseif bountyType == 'defend' then
        color = {0, 0, 1, 0.8}
        text = "DEFEND"
    end
    
    love.graphics.setColor(color[1], color[2], color[3], color[4])
    
    -- Draw flag pole
    love.graphics.setLineWidth(3)
    love.graphics.line(worldX, worldY, worldX, worldY - 30)
    love.graphics.setLineWidth(1)
    
    -- Draw flag
    local flagPoints = {
        worldX, worldY - 30,
        worldX + 25, worldY - 25,
        worldX + 25, worldY - 15,
        worldX, worldY - 10
    }
    love.graphics.polygon("fill", flagPoints)
    
    -- Draw bounty type text
    love.graphics.setColor(1, 1, 1)
    love.graphics.setFont(love.graphics.newFont(10))
    love.graphics.print(text, worldX + 30, worldY - 28)
    
    -- Show cost
    love.graphics.setColor(1, 1, 0)
    love.graphics.print("50 KC", worldX + 30, worldY - 15)
    
    -- Instructions
    love.graphics.setColor(1, 1, 1, 0.8)
    love.graphics.print("Click to place bounty", worldX - 50, worldY + 10)
end

function UI.drawControls()
    local y = love.graphics.getHeight() - 25
    
    love.graphics.setColor(0, 0, 0, 0.7)
    love.graphics.rectangle("fill", 0, y - 5, love.graphics.getWidth(), 30)
    
    love.graphics.setColor(0.9, 0.9, 0.9)
    love.graphics.setFont(love.graphics.newFont(11))
    love.graphics.print("[1] Attack Bounty  [2] Explore Bounty  [3] Defend Bounty  [B] Build Mode  [WASD] Move Camera  [Scroll] Zoom  [ESC] Cancel", 10, y)
end

return UI